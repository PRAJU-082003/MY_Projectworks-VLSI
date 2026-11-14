import subprocess
import random

from generate_sv_sequence import generate_random_input, generate_sv_sequence
from parse_questa_log import parse_questa_log

def run_questa():
    result = subprocess.run(
        ["vsim", "-c", "-do", "run_rl_once.do"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=False,
        creationflags=subprocess.CREATE_NO_WINDOW
    )

    with open("questa_run.log", "w") as f:
        f.write(result.stdout)
        f.write(result.stderr)

    return result.returncode


def reward_function(result):
    if result["injected"] == 0:
        return 0

    reward = result["total_error"] / result["injected"]

    if result["mismatch"] == 0:
        reward -= 1000

    return reward


for episode in range(3):
    row_a, col_b = generate_random_input()

    pe_id = random.randint(0, 63)
    bit_pos = random.randint(0, 33)
    cycle = random.randint(5, 20)

    generate_sv_sequence(row_a, col_b, pe_id, bit_pos, cycle)

    run_questa()

    result = parse_questa_log("questa_run.log")
    reward = reward_function(result)

    print("Episode:", episode)
    print("Fault PE:", pe_id, "Bit:", bit_pos, "Cycle:", cycle)
    print("Result:", result)
    print("Reward:", reward)
    print("-------------------------------------")
