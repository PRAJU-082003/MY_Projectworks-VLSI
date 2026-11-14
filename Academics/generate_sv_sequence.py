import random

from mnist_lenet_mapping import (
    create_first_mnist_matrix_block,
    matrix_block_to_rtl_inputs
)

N = 8
DATA_WIDTH = 8
MAC_PER_PE = 4


def generate_random_input():
    row_a = [[random.randint(0, 255) for _ in range(4)] for _ in range(8)]
    col_b = [[random.randint(0, 255) for _ in range(4)] for _ in range(8)]
    return row_a, col_b


def generate_sv_sequence(row_a, col_b, pe_id, bit_pos, cycle):
    with open("generated_rl_input_fault_seq.sv", "w") as f:
        f.write("class generated_rl_input_fault_seq extends uvm_sequence #(accel_txn);\n\n")
        f.write("    `uvm_object_utils(generated_rl_input_fault_seq)\n\n")

        f.write("    function new(string name = \"generated_rl_input_fault_seq\");\n")
        f.write("        super.new(name);\n")
        f.write("    endfunction\n\n")

        f.write("    virtual task body();\n")
        f.write("        accel_txn tx;\n")
        f.write("        tx = accel_txn::type_id::create(\"tx_rl\");\n")
        f.write("        start_item(tx);\n\n")

        f.write("        tx.row_a_in_flat = '0;\n")
        f.write("        tx.col_b_in_flat = '0;\n\n")

        for r in range(8):
            for k in range(4):
                val = int(row_a[r][k])
                f.write(
                    f"        tx.row_a_in_flat[((%0d*MAC_PER_PE + %0d)*DATA_WIDTH) +: DATA_WIDTH] = 8'd{val};\n"
                    % (r, k)
                )

        f.write("\n")

        for c in range(8):
            for k in range(4):
                val = int(col_b[c][k])
                f.write(
                    f"        tx.col_b_in_flat[((%0d*MAC_PER_PE + %0d)*DATA_WIDTH) +: DATA_WIDTH] = 8'd{val};\n"
                    % (c, k)
                )

        f.write("\n")
        f.write("        tx.inject_fault  = 1'b1;\n")
        f.write(f"        tx.fault_pe_id   = 6'd{pe_id};\n")
        f.write(f"        tx.fault_bit_pos = 6'd{bit_pos};\n")
        f.write(f"        tx.fault_cycle   = {cycle};\n\n")

        f.write("        finish_item(tx);\n")
        f.write("    endtask\n\n")
        f.write("endclass\n")


def generate_mnist_sv_sequence(pe_id, bit_pos, cycle):
    A_block, B_block = create_first_mnist_matrix_block()

    row_a, col_b = matrix_block_to_rtl_inputs(A_block, B_block)

    generate_sv_sequence(
        row_a=row_a,
        col_b=col_b,
        pe_id=pe_id,
        bit_pos=bit_pos,
        cycle=cycle
    )
