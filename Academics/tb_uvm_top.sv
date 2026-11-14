`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

import accel_uvm_pkg::*;

module tb_uvm_top;

    parameter N           = 8;
    parameter DATA_WIDTH  = 8;
    parameter ACC_WIDTH   = 32;
    parameter APPROX_BITS = 4;
    parameter MAC_PER_PE  = 4;

    logic clk;

    accel_if #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .MAC_PER_PE(MAC_PER_PE)
    ) intf (
        .clk(clk)
    );

       approx_systolic_ai_accel_top #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS),
        .MAC_PER_PE(MAC_PER_PE)
    ) dut (
        .clk(clk),
        .rst_n(intf.rst_n),

        .start(intf.start),
        .clear_acc(intf.clear_acc),

        .row_a_in_flat(intf.row_a_in_flat),
        .col_b_in_flat(intf.col_b_in_flat),

        .fault_en(intf.fault_en),
        .fault_pe_id(intf.fault_pe_id),
        .fault_bit_pos(intf.fault_bit_pos),

        .pe_sum_flat(intf.pe_sum_flat),
        .pe_valid_flat(intf.pe_valid_flat),

        .result_valid(intf.result_valid),
        .done(intf.done),
        .cycle_count(intf.cycle_count)
    );

    accel_assertions #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .MAC_PER_PE(MAC_PER_PE),
        .MIN_LATENCY(1),
        .MAX_LATENCY(25)
    ) u_assertions (
        .vif(intf)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
    end

    initial begin
        uvm_config_db#(virtual accel_if.drv_mp)::set(
            null,
            "uvm_test_top.env.agent.drv",
            "vif",
            intf
        );

        uvm_config_db#(virtual accel_if.mon_mp)::set(
            null,
            "uvm_test_top.env.agent.mon",
            "vif",
            intf
        );

        run_test();
    end

endmodule