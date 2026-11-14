`timescale 1ns/1ps

module systolic_cell_4mac #(
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 32,
    parameter APPROX_BITS = 4
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         clear_acc,

    input  logic                         valid_a_in,
    input  logic                         valid_b_in,

    input  logic [DATA_WIDTH-1:0]        a0_in,
    input  logic [DATA_WIDTH-1:0]        a1_in,
    input  logic [DATA_WIDTH-1:0]        a2_in,
    input  logic [DATA_WIDTH-1:0]        a3_in,

    input  logic [DATA_WIDTH-1:0]        b0_in,
    input  logic [DATA_WIDTH-1:0]        b1_in,
    input  logic [DATA_WIDTH-1:0]        b2_in,
    input  logic [DATA_WIDTH-1:0]        b3_in,

    output logic [DATA_WIDTH-1:0]        a0_out,
    output logic [DATA_WIDTH-1:0]        a1_out,
    output logic [DATA_WIDTH-1:0]        a2_out,
    output logic [DATA_WIDTH-1:0]        a3_out,

    output logic [DATA_WIDTH-1:0]        b0_out,
    output logic [DATA_WIDTH-1:0]        b1_out,
    output logic [DATA_WIDTH-1:0]        b2_out,
    output logic [DATA_WIDTH-1:0]        b3_out,

    output logic                         valid_a_out,
    output logic                         valid_b_out,

    output logic [ACC_WIDTH+1:0]         pe_sum_out,
    output logic                         pe_valid_out
);

    logic pe_valid_in;

    logic [ACC_WIDTH-1:0] mac0_out;
    logic [ACC_WIDTH-1:0] mac1_out;
    logic [ACC_WIDTH-1:0] mac2_out;
    logic [ACC_WIDTH-1:0] mac3_out;

    assign pe_valid_in = valid_a_in & valid_b_in;

    pe_4mac #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_pe_4mac (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(pe_valid_in),
        .clear_acc(clear_acc),

        .a0(a0_in), .b0(b0_in),
        .a1(a1_in), .b1(b1_in),
        .a2(a2_in), .b2(b2_in),
        .a3(a3_in), .b3(b3_in),

        .mac0_out(mac0_out),
        .mac1_out(mac1_out),
        .mac2_out(mac2_out),
        .mac3_out(mac3_out),

        .pe_sum_out(pe_sum_out),
        .valid_out(pe_valid_out)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a0_out      <= '0;
            a1_out      <= '0;
            a2_out      <= '0;
            a3_out      <= '0;

            b0_out      <= '0;
            b1_out      <= '0;
            b2_out      <= '0;
            b3_out      <= '0;

            valid_a_out <= 1'b0;
            valid_b_out <= 1'b0;
        end else begin
            a0_out      <= a0_in;
            a1_out      <= a1_in;
            a2_out      <= a2_in;
            a3_out      <= a3_in;

            b0_out      <= b0_in;
            b1_out      <= b1_in;
            b2_out      <= b2_in;
            b3_out      <= b3_in;

            valid_a_out <= valid_a_in;
            valid_b_out <= valid_b_in;
        end
    end

endmodule