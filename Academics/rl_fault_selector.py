import random
import json
from collections import defaultdict

# ============================================================
# Project parameters
# ============================================================
N = 8
NUM_PES = N * N
PE_SUM_WIDTH = 34

MAX_CYCLE = 25

# RL hyperparameters
EPISODES = 80
MAX_STEPS = 8
ALPHA = 0.5
GAMMA = 0.9
EPSILON = 0.25

# Keep fault set small
MAX_FAULTS_IN_SET = 5

# ============================================================
# Golden design behavior for the known input case
# A lanes = 7, 15, 25, 100
# B lanes = 9, 15, 12, 3
# Approx products:
# 7*9     = 63  -> 48
# 15*15   = 225 -> 224
# 25*12   = 300 -> 288
# 100*3   = 300 -> 288
# Expected PE output = 880
# ============================================================

GOLDEN_PE_VALUE = 880


def canonical_state(fault_set):
    """
    Convert fault_set list into a hashable sorted tuple.
    Each fault is represented as:
    (fault_pe_id, fault_bit_pos, fault_cycle)
    """
    return tuple(sorted(fault_set))


def generate_candidate_faults():
    """
    Candidate set initialization.
    Instead of trying all 54,400 possible locations,
    we choose a reduced candidate set.

    For a better RIFT-like method, we prioritize:
    - corner PEs
    - farthest PE PE[7][7]
    - MSB/mid-level bits
    - useful fault cycles
    """

    candidate_pes = [
        0,    # PE[0][0]
        7,    # PE[0][7]
        56,   # PE[7][0]
        63,   # PE[7][7]
        27,   # PE[3][3]
        36,   # PE[4][4]
        42,   # PE[5][2]
        49    # PE[6][1]
    ]

    candidate_bits = [
        4, 5, 6, 7, 8, 9, 10, 11, 12,
        13, 14, 15, 16, 20, 24, 28, 32, 33
    ]

    candidate_cycles = [
        5, 8, 10, 12, 15, 18, 20
    ]

    candidates = []

    for pe in candidate_pes:
        for bit in candidate_bits:
            for cyc in candidate_cycles:
                candidates.append((pe, bit, cyc))

    return candidates


def apply_faults_and_evaluate(fault_set):
    """
    Python DUT evaluator.

    In the current RTL fault hook:
    pe_sum_flat = clean_pe_sum_flat XOR fault_mask

    So if we flip bit k of PE output, the PE output changes by XORing 2^k.
    """

    clean_outputs = [GOLDEN_PE_VALUE for _ in range(NUM_PES)]
    faulty_outputs = clean_outputs[:]

    for pe_id, bit_pos, fault_cycle in fault_set:
        if 0 <= pe_id < NUM_PES and 0 <= bit_pos < PE_SUM_WIDTH:
            faulty_outputs[pe_id] ^= (1 << bit_pos)

    total_error = 0
    mismatched_pes = 0

    for i in range(NUM_PES):
        err = abs(faulty_outputs[i] - clean_outputs[i])
        total_error += err

        if err != 0:
            mismatched_pes += 1

    return total_error, mismatched_pes, faulty_outputs


def reward_function(fault_set):
    """
    Reward should be high when:
    - output error is high
    - fault set size is small

    Penalize too many faults.
    """

    if len(fault_set) == 0:
        return 0.0

    total_error, mismatched_pes, _ = apply_faults_and_evaluate(fault_set)

    reward = total_error / len(fault_set)

    if len(fault_set) > MAX_FAULTS_IN_SET:
        reward -= 5000

    return reward


def choose_action(state, candidates, q_table):
    """
    Epsilon-greedy action selection.
    Action can be:
    - add one candidate fault
    - remove one existing fault
    """

    state_set = set(state)

    actions = []

    # Add actions
    for fault in candidates:
        if fault not in state_set:
            actions.append(("add", fault))

    # Remove actions
    for fault in state_set:
        actions.append(("remove", fault))

    if not actions:
        return None

    # Exploration
    if random.random() < EPSILON:
        return random.choice(actions)

    # Exploitation
    best_action = None
    best_q = float("-inf")

    for action in actions:
        q = q_table[(state, action)]
        if q > best_q:
            best_q = q
            best_action = action

    return best_action


def apply_action(state, action):
    """
    Apply add/remove action to current state.
    """
    state_set = set(state)

    action_type, fault = action

    if action_type == "add":
        state_set.add(fault)
    elif action_type == "remove":
        state_set.discard(fault)

    return canonical_state(state_set)


def train_rl_agent():
    candidates = generate_candidate_faults()

    q_table = defaultdict(float)

    best_fault_set = tuple()
    best_reward = float("-inf")

    print("=================================================")
    print(" RIFT-Style RL Fault Selection Started")
    print("=================================================")
    print(f"Candidate fault count = {len(candidates)}")
    print(f"Episodes = {EPISODES}")
    print(f"Max steps per episode = {MAX_STEPS}")
    print("=================================================")

    for episode in range(EPISODES):
        state = canonical_state([])

        for step in range(MAX_STEPS):
            action = choose_action(state, candidates, q_table)

            if action is None:
                break

            next_state = apply_action(state, action)

            reward = reward_function(next_state)

            # Q-learning update
            future_q_values = []

            for fault in candidates:
                if fault not in set(next_state):
                    future_action = ("add", fault)
                    future_q_values.append(q_table[(next_state, future_action)])

            for fault in set(next_state):
                future_action = ("remove", fault)
                future_q_values.append(q_table[(next_state, future_action)])

            max_future_q = max(future_q_values) if future_q_values else 0.0

            old_q = q_table[(state, action)]

            q_table[(state, action)] = old_q + ALPHA * (
                reward + GAMMA * max_future_q - old_q
            )

            if reward > best_reward and len(next_state) > 0:
                best_reward = reward
                best_fault_set = next_state

            state = next_state

        if episode % 10 == 0:
            print(
                f"Episode {episode:03d} | "
                f"Best Reward = {best_reward:.2f} | "
                f"Best Fault Count = {len(best_fault_set)}"
            )

    print("=================================================")
    print(" RL Training Completed")
    print("=================================================")
    print(f"Best reward = {best_reward:.2f}")
    print(f"Best fault count = {len(best_fault_set)}")
    print("Best fault set:")

    for fault in best_fault_set:
        print(f"  PE_ID={fault[0]} BIT={fault[1]} CYCLE={fault[2]}")

    return best_fault_set, best_reward


def export_fault_set_to_json(fault_set, filename="rift_fault_set.json"):
    fault_list = []

    for pe_id, bit_pos, cycle in fault_set:
        fault_list.append({
            "fault_pe_id": int(pe_id),
            "fault_bit_pos": int(bit_pos),
            "fault_cycle": int(cycle)
        })

    with open(filename, "w") as f:
        json.dump(fault_list, f, indent=4)

    print("=================================================")
    print(f"Exported fault set to {filename}")
    print("=================================================")


def generate_uvm_sequence_from_json(
    json_file="rift_fault_set.json",
    sv_file="generated_rift_fault_seq.sv"
):
    with open(json_file, "r") as f:
        fault_list = json.load(f)

    with open(sv_file, "w") as f:
        f.write("// Auto-generated RIFT-style UVM fault sequence\n")
        f.write("// Generated from Python RL fault selector\n\n")

        f.write("class generated_rift_fault_seq extends uvm_sequence #(accel_txn);\n\n")
        f.write("    `uvm_object_utils(generated_rift_fault_seq)\n\n")

        f.write("    function new(string name = \"generated_rift_fault_seq\");\n")
        f.write("        super.new(name);\n")
        f.write("    endfunction\n\n")

        f.write("    virtual task body();\n")
        f.write("        accel_txn tx;\n\n")

        for idx, fault in enumerate(fault_list):
            f.write(f"        // Fault {idx}\n")
            f.write(f"        tx = accel_txn::type_id::create(\"tx_fault_{idx}\");\n")
            f.write("        start_item(tx);\n\n")

            f.write("        for (int i = 0; i < N; i++) begin\n")
            f.write("            tx.row_a_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd7;\n")
            f.write("            tx.row_a_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;\n")
            f.write("            tx.row_a_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd25;\n")
            f.write("            tx.row_a_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd100;\n\n")

            f.write("            tx.col_b_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd9;\n")
            f.write("            tx.col_b_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;\n")
            f.write("            tx.col_b_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd12;\n")
            f.write("            tx.col_b_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd3;\n")
            f.write("        end\n\n")

            f.write("        tx.inject_fault  = 1'b1;\n")
            f.write(f"        tx.fault_pe_id   = 6'd{fault['fault_pe_id']};\n")
            f.write(f"        tx.fault_bit_pos = 6'd{fault['fault_bit_pos']};\n")
            f.write(f"        tx.fault_cycle   = {fault['fault_cycle']};\n\n")

            f.write("        finish_item(tx);\n\n")

        f.write("    endtask\n\n")
        f.write("endclass\n")

    print(f"Generated UVM sequence file: {sv_file}")


if __name__ == "__main__":
    best_fault_set, best_reward = train_rl_agent()

    export_fault_set_to_json(best_fault_set)

    generate_uvm_sequence_from_json()
