`timescale 1ns/1ps

module pe_4mac #(
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 32,
    parameter APPROX_BITS = 4
)(
    input  logic                         clk,
    input  logic                         rst_n,

    input  logic                         valid_in,
    input  logic                         clear_acc,

    input  logic [DATA_WIDTH-1:0]        a0,
    input  logic [DATA_WIDTH-1:0]        b0,
    input  logic [DATA_WIDTH-1:0]        a1,
    input  logic [DATA_WIDTH-1:0]        b1,
    input  logic [DATA_WIDTH-1:0]        a2,
    input  logic [DATA_WIDTH-1:0]        b2,
    input  logic [DATA_WIDTH-1:0]        a3,
    input  logic [DATA_WIDTH-1:0]        b3,

    output logic [ACC_WIDTH-1:0]         mac0_out,
    output logic [ACC_WIDTH-1:0]         mac1_out,
    output logic [ACC_WIDTH-1:0]         mac2_out,
    output logic [ACC_WIDTH-1:0]         mac3_out,

    output logic [ACC_WIDTH+1:0]         pe_sum_out,
    output logic                         valid_out
);

    logic valid0;
    logic valid1;
    logic valid2;
    logic valid3;

    logic [(2*DATA_WIDTH)-1:0] exact_product0_dbg;
    logic [(2*DATA_WIDTH)-1:0] approx_product0_dbg;
    logic [(2*DATA_WIDTH)-1:0] error_value0_dbg;

    logic [(2*DATA_WIDTH)-1:0] exact_product1_dbg;
    logic [(2*DATA_WIDTH)-1:0] approx_product1_dbg;
    logic [(2*DATA_WIDTH)-1:0] error_value1_dbg;

    logic [(2*DATA_WIDTH)-1:0] exact_product2_dbg;
    logic [(2*DATA_WIDTH)-1:0] approx_product2_dbg;
    logic [(2*DATA_WIDTH)-1:0] error_value2_dbg;

    logic [(2*DATA_WIDTH)-1:0] exact_product3_dbg;
    logic [(2*DATA_WIDTH)-1:0] approx_product3_dbg;
    logic [(2*DATA_WIDTH)-1:0] error_value3_dbg;

    approx_mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_mac0 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .clear_acc(clear_acc),
        .a(a0),
        .b(b0),
        .mac_out(mac0_out),
        .valid_out(valid0),
        .exact_product_dbg(exact_product0_dbg),
        .approx_product_dbg(approx_product0_dbg),
        .error_value_dbg(error_value0_dbg)
    );

    approx_mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_mac1 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .clear_acc(clear_acc),
        .a(a1),
        .b(b1),
        .mac_out(mac1_out),
        .valid_out(valid1),
        .exact_product_dbg(exact_product1_dbg),
        .approx_product_dbg(approx_product1_dbg),
        .error_value_dbg(error_value1_dbg)
    );

    approx_mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_mac2 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .clear_acc(clear_acc),
        .a(a2),
        .b(b2),
        .mac_out(mac2_out),
        .valid_out(valid2),
        .exact_product_dbg(exact_product2_dbg),
        .approx_product_dbg(approx_product2_dbg),
        .error_value_dbg(error_value2_dbg)
    );

    approx_mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_mac3 (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .clear_acc(clear_acc),
        .a(a3),
        .b(b3),
        .mac_out(mac3_out),
        .valid_out(valid3),
        .exact_product_dbg(exact_product3_dbg),
        .approx_product_dbg(approx_product3_dbg),
        .error_value_dbg(error_value3_dbg)
    );

    always_comb begin
        pe_sum_out = {2'b00, mac0_out}
                   + {2'b00, mac1_out}
                   + {2'b00, mac2_out}
                   + {2'b00, mac3_out};
    end

    assign valid_out = valid0 & valid1 & valid2 & valid3;

endmodule