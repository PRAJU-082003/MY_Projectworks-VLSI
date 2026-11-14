// Auto-generated RIFT-style UVM fault sequence
// Generated from Python RL fault selector

class generated_rift_fault_seq extends uvm_sequence #(accel_txn);

    `uvm_object_utils(generated_rift_fault_seq)

    function new(string name = "generated_rift_fault_seq");
        super.new(name);
    endfunction

    virtual task body();
        accel_txn tx;

        // Fault 0
        tx = accel_txn::type_id::create("tx_fault_0");
        start_item(tx);

        for (int i = 0; i < N; i++) begin
            tx.row_a_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd7;
            tx.row_a_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;
            tx.row_a_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd25;
            tx.row_a_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd100;

            tx.col_b_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd9;
            tx.col_b_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;
            tx.col_b_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd12;
            tx.col_b_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd3;
        end

        tx.inject_fault  = 1'b1;
        tx.fault_pe_id   = 6'd42;
        tx.fault_bit_pos = 6'd33;
        tx.fault_cycle   = 15;

        finish_item(tx);

    endtask

endclass
