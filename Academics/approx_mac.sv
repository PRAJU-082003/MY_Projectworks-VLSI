`timescale 1ns/1ps

module approx_mac #(
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 32,
    parameter APPROX_BITS = 4
)(
    input  logic                         clk,
    input  logic                         rst_n,

    input  logic                         valid_in,
    input  logic                         clear_acc,

    input  logic [DATA_WIDTH-1:0]        a,
    input  logic [DATA_WIDTH-1:0]        b,

    output logic [ACC_WIDTH-1:0]         mac_out,
    output logic                         valid_out,

    output logic [(2*DATA_WIDTH)-1:0]    exact_product_dbg,
    output logic [(2*DATA_WIDTH)-1:0]    approx_product_dbg,
    output logic [(2*DATA_WIDTH)-1:0]    error_value_dbg
);

    localparam PRODUCT_WIDTH = 2 * DATA_WIDTH;

    logic [PRODUCT_WIDTH-1:0] exact_product;
    logic [PRODUCT_WIDTH-1:0] approx_product;
    logic [PRODUCT_WIDTH-1:0] error_value;

    logic [ACC_WIDTH-1:0] acc_reg;

    approx_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .APPROX_BITS(APPROX_BITS)
    ) u_approx_multiplier (
        .a(a),
        .b(b),
        .exact_product(exact_product),
        .approx_product(approx_product),
        .error_value(error_value)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_reg   <= '0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;

            if (clear_acc) begin
                acc_reg <= '0;
            end else if (valid_in) begin
                acc_reg <= acc_reg + {{(ACC_WIDTH-PRODUCT_WIDTH){1'b0}}, approx_product};
            end
        end
    end

    assign mac_out            = acc_reg;
    assign exact_product_dbg  = exact_product;
    assign approx_product_dbg = approx_product;
    assign error_value_dbg    = error_value;

endmodule