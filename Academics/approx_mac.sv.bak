`timescale 1ns/1ps

module approx_multiplier #(
    parameter DATA_WIDTH  = 8,
    parameter APPROX_BITS = 4,
    parameter USE_COMPENSATION = 1
)(
    input  logic [DATA_WIDTH-1:0]       a,
    input  logic [DATA_WIDTH-1:0]       b,
    output logic [(2*DATA_WIDTH)-1:0]   exact_product,
    output logic [(2*DATA_WIDTH)-1:0]   approx_product,
    output logic [(2*DATA_WIDTH)-1:0]   error_value
);

    localparam PRODUCT_WIDTH = 2 * DATA_WIDTH;

    logic [PRODUCT_WIDTH-1:0] truncated_product;
    logic [PRODUCT_WIDTH-1:0] compensation_value;

    always_comb begin
        exact_product = a * b;

        truncated_product = exact_product;

        if (APPROX_BITS > 0) begin
            truncated_product[APPROX_BITS-1:0] = '0;
        end

        compensation_value = '0;

        if (USE_COMPENSATION && APPROX_BITS > 0 && exact_product != 0) begin
            compensation_value = {{(PRODUCT_WIDTH-APPROX_BITS){1'b0}}, 1'b1, {(APPROX_BITS-1){1'b0}}};
        end

        approx_product = truncated_product + compensation_value;

        if (approx_product > exact_product) begin
            error_value = approx_product - exact_product;
        end else begin
            error_value = exact_product - approx_product;
        end
    end

endmodule