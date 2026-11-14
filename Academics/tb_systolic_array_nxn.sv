`timescale 1ns/1ps

module tb_systolic_array_nxn;

    parameter N           = 8;
    parameter DATA_WIDTH  = 8;
    parameter ACC_WIDTH   = 32;
    parameter APPROX_BITS = 4;
    parameter MAC_PER_PE  = 4;

    localparam PE_SUM_WIDTH = ACC_WIDTH + 2;

    logic clk;
    logic rst_n;
    logic clear_acc;

    logic [N-1:0] row_valid_in;
    logic [N-1:0] col_valid_in;

    logic [(N*MAC_PER_PE*DATA_WIDTH)-1:0] row_a_in_flat;
    logic [(N*MAC_PER_PE*DATA_WIDTH)-1:0] col_b_in_flat;

    logic [(N*N*PE_SUM_WIDTH)-1:0] pe_sum_flat;
    logic [(N*N)-1:0]              pe_valid_flat;

    integer r, c;

    systolic_array_nxn #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS),
        .MAC_PER_PE(MAC_PER_PE)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .clear_acc(clear_acc),

        .row_valid_in(row_valid_in),
        .col_valid_in(col_valid_in),

        .row_a_in_flat(row_a_in_flat),
        .col_b_in_flat(col_b_in_flat),

        .pe_sum_flat(pe_sum_flat),
        .pe_valid_flat(pe_valid_flat)
    );

    always #5 clk = ~clk;

    task set_row_inputs;
        integer i;
        begin
            for (i = 0; i < N; i = i + 1) begin
                row_a_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd7;
                row_a_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;
                row_a_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd25;
                row_a_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd100;
            end
        end
    endtask

    task set_col_inputs;
        integer j;
        begin
            for (j = 0; j < N; j = j + 1) begin
                col_b_in_flat[((j*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH] = 8'd9;
                col_b_in_flat[((j*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH] = 8'd15;
                col_b_in_flat[((j*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH] = 8'd12;
                col_b_in_flat[((j*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH] = 8'd3;
            end
        end
    endtask

    function [PE_SUM_WIDTH-1:0] get_pe_sum(input integer row, input integer col);
        begin
            get_pe_sum = pe_sum_flat[((row*N + col)*PE_SUM_WIDTH) +: PE_SUM_WIDTH];
        end
    endfunction

    function get_pe_valid(input integer row, input integer col);
        begin
            get_pe_valid = pe_valid_flat[(row*N + col)];
        end
    endfunction

    initial begin
        clk           = 1'b0;
        rst_n         = 1'b0;
        clear_acc     = 1'b0;
        row_valid_in  = '0;
        col_valid_in  = '0;
        row_a_in_flat = '0;
        col_b_in_flat = '0;

        $display("=================================================");
        $display(" Parameterized Systolic Array Test Started");
        $display(" N=%0d DATA_WIDTH=%0d ACC_WIDTH=%0d APPROX_BITS=%0d",
                  N, DATA_WIDTH, ACC_WIDTH, APPROX_BITS);
        $display(" Total PEs = %0d", N*N);
        $display(" Total Approx MACs = %0d", N*N*MAC_PER_PE);
        $display("=================================================");

        repeat (3) @(posedge clk);
        rst_n = 1'b1;

        @(negedge clk);
        clear_acc = 1'b1;

        @(negedge clk);
        clear_acc = 1'b0;

        set_row_inputs();
        set_col_inputs();

        // Send one valid wave into all rows and columns
        @(negedge clk);
        row_valid_in = {N{1'b1}};
        col_valid_in = {N{1'b1}};

        @(negedge clk);
        row_valid_in = '0;
        col_valid_in = '0;

        // Wait enough cycles for data to propagate through 8x8 array
        repeat (20) begin
            @(posedge clk);
            #1;
            $display("Time=%0t | PE00=%0d V00=%0b | PE07=%0d V07=%0b | PE70=%0d V70=%0b | PE77=%0d V77=%0b",
                     $time,
                     get_pe_sum(0,0), get_pe_valid(0,0),
                     get_pe_sum(0,7), get_pe_valid(0,7),
                     get_pe_sum(7,0), get_pe_valid(7,0),
                     get_pe_sum(7,7), get_pe_valid(7,7));
        end

        $display("=================================================");
        $display(" Final Important PE Results");
        $display(" PE[0][0] = %0d", get_pe_sum(0,0));
        $display(" PE[0][7] = %0d", get_pe_sum(0,7));
        $display(" PE[7][0] = %0d", get_pe_sum(7,0));
        $display(" PE[7][7] = %0d", get_pe_sum(7,7));
        $display(" Expected each active PE output = 848");
        $display("=================================================");

        for (r = 0; r < N; r = r + 1) begin
            for (c = 0; c < N; c = c + 1) begin
                if (get_pe_sum(r,c) !== 34'd848) begin
                    $display("WARNING: PE[%0d][%0d] output = %0d, expected 848",
                             r, c, get_pe_sum(r,c));
                end
            end
        end

        $display(" Parameterized Systolic Array Test Completed");
        $display("=================================================");

        $stop;
    end

endmodule