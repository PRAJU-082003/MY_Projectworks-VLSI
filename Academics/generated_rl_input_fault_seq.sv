class generated_rl_input_fault_seq extends uvm_sequence #(accel_txn);

    `uvm_object_utils(generated_rl_input_fault_seq)

    function new(string name = "generated_rl_input_fault_seq");
        super.new(name);
    endfunction

    virtual task body();
        accel_txn tx;
        tx = accel_txn::type_id::create("tx_rl");
        start_item(tx);

        tx.row_a_in_flat = '0;
        tx.col_b_in_flat = '0;

        tx.row_a_in_flat[((0*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((0*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((0*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((0*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((1*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((1*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((1*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((1*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((2*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((2*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((2*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((2*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((3*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((3*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((3*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((3*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((4*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((4*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((4*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((4*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((5*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((5*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((5*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((5*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((6*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((6*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((6*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((6*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((7*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((7*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;
        tx.row_a_in_flat[((7*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd227;
        tx.row_a_in_flat[((7*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd255;

        tx.col_b_in_flat[((0*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((0*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((0*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((0*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((1*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((1*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((1*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((1*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((2*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((2*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((2*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((2*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((3*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((3*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((3*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((3*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((4*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((4*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((4*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((4*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((5*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((5*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((5*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((5*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((6*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((6*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((6*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((6*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((7*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((7*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;
        tx.col_b_in_flat[((7*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd0;
        tx.col_b_in_flat[((7*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd28;

        tx.inject_fault  = 1'b1;
        tx.fault_pe_id   = 6'd18;
        tx.fault_bit_pos = 6'd5;
        tx.fault_cycle   = 5;

        finish_item(tx);
    endtask

endclass
