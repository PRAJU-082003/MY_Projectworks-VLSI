`timescale 1ns/1ps

module systolic_array_nxn #(
    parameter N           = 8,
    parameter DATA_WIDTH  = 8,
    parameter ACC_WIDTH   = 32,
    parameter APPROX_BITS = 4,
    parameter MAC_PER_PE  = 4
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         clear_acc,

    input  logic [N-1:0]                 row_valid_in,
    input  logic [N-1:0]                 col_valid_in,

    input  logic [(N*MAC_PER_PE*DATA_WIDTH)-1:0] row_a_in_flat,
    input  logic [(N*MAC_PER_PE*DATA_WIDTH)-1:0] col_b_in_flat,

    output logic [(N*N*(ACC_WIDTH+2))-1:0]        pe_sum_flat,
    output logic [(N*N)-1:0]                      pe_valid_flat
);

    logic [DATA_WIDTH-1:0] a0_bus [0:N-1][0:N];
    logic [DATA_WIDTH-1:0] a1_bus [0:N-1][0:N];
    logic [DATA_WIDTH-1:0] a2_bus [0:N-1][0:N];
    logic [DATA_WIDTH-1:0] a3_bus [0:N-1][0:N];

    logic [DATA_WIDTH-1:0] b0_bus [0:N][0:N-1];
    logic [DATA_WIDTH-1:0] b1_bus [0:N][0:N-1];
    logic [DATA_WIDTH-1:0] b2_bus [0:N][0:N-1];
    logic [DATA_WIDTH-1:0] b3_bus [0:N][0:N-1];

    logic valid_a_bus [0:N-1][0:N];
    logic valid_b_bus [0:N][0:N-1];

    logic [ACC_WIDTH+1:0] pe_sum_matrix [0:N-1][0:N-1];
    logic                 pe_valid_matrix [0:N-1][0:N-1];

    genvar i, j;

    generate
        for (i = 0; i < N; i = i + 1) begin : ROW_INPUT_ASSIGN
            assign a0_bus[i][0] = row_a_in_flat[((i*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH];
            assign a1_bus[i][0] = row_a_in_flat[((i*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH];
            assign a2_bus[i][0] = row_a_in_flat[((i*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH];
            assign a3_bus[i][0] = row_a_in_flat[((i*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH];

            assign valid_a_bus[i][0] = row_valid_in[i];
        end
    endgenerate

    generate
        for (j = 0; j < N; j = j + 1) begin : COL_INPUT_ASSIGN
            assign b0_bus[0][j] = col_b_in_flat[((j*MAC_PER_PE + 0)*DATA_WIDTH) +: DATA_WIDTH];
            assign b1_bus[0][j] = col_b_in_flat[((j*MAC_PER_PE + 1)*DATA_WIDTH) +: DATA_WIDTH];
            assign b2_bus[0][j] = col_b_in_flat[((j*MAC_PER_PE + 2)*DATA_WIDTH) +: DATA_WIDTH];
            assign b3_bus[0][j] = col_b_in_flat[((j*MAC_PER_PE + 3)*DATA_WIDTH) +: DATA_WIDTH];

            assign valid_b_bus[0][j] = col_valid_in[j];
        end
    endgenerate

    generate
        for (i = 0; i < N; i = i + 1) begin : ROW_GEN
            for (j = 0; j < N; j = j + 1) begin : COL_GEN

                systolic_cell_4mac #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .ACC_WIDTH(ACC_WIDTH),
                    .APPROX_BITS(APPROX_BITS)
                ) u_cell (
                    .clk(clk),
                    .rst_n(rst_n),
                    .clear_acc(clear_acc),

                    .valid_a_in(valid_a_bus[i][j]),
                    .valid_b_in(valid_b_bus[i][j]),

                    .a0_in(a0_bus[i][j]),
                    .a1_in(a1_bus[i][j]),
                    .a2_in(a2_bus[i][j]),
                    .a3_in(a3_bus[i][j]),

                    .b0_in(b0_bus[i][j]),
                    .b1_in(b1_bus[i][j]),
                    .b2_in(b2_bus[i][j]),
                    .b3_in(b3_bus[i][j]),

                    .a0_out(a0_bus[i][j+1]),
                    .a1_out(a1_bus[i][j+1]),
                    .a2_out(a2_bus[i][j+1]),
                    .a3_out(a3_bus[i][j+1]),

                    .b0_out(b0_bus[i+1][j]),
                    .b1_out(b1_bus[i+1][j]),
                    .b2_out(b2_bus[i+1][j]),
                    .b3_out(b3_bus[i+1][j]),

                    .valid_a_out(valid_a_bus[i][j+1]),
                    .valid_b_out(valid_b_bus[i+1][j]),

                    .pe_sum_out(pe_sum_matrix[i][j]),
                    .pe_valid_out(pe_valid_matrix[i][j])
                );

                assign pe_sum_flat[((i*N + j)*(ACC_WIDTH+2)) +: (ACC_WIDTH+2)] =
                       pe_sum_matrix[i][j];

                assign pe_valid_flat[(i*N + j)] =
                       pe_valid_matrix[i][j];

            end
        end
    endgenerate

endmodule