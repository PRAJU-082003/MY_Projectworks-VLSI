quit -sim

vlib work
vmap work work

vlog -sv approx_multiplier.sv approx_mac.sv pe_4mac.sv systolic_cell_4mac.sv systolic_array_nxn.sv tb_systolic_array_nxn.sv

vsim -voptargs=+acc work.tb_systolic_array_nxn

add wave -divider "TB Control"
add wave sim:/tb_systolic_array_nxn/clk
add wave sim:/tb_systolic_array_nxn/rst_n
add wave sim:/tb_systolic_array_nxn/clear_acc
add wave sim:/tb_systolic_array_nxn/row_valid_in
add wave sim:/tb_systolic_array_nxn/col_valid_in

add wave -divider "Flat Inputs"
add wave sim:/tb_systolic_array_nxn/row_a_in_flat
add wave sim:/tb_systolic_array_nxn/col_b_in_flat

add wave -divider "Flat Outputs"
add wave sim:/tb_systolic_array_nxn/pe_sum_flat
add wave sim:/tb_systolic_array_nxn/pe_valid_flat

add wave -divider "Important PE Outputs"
add wave sim:/tb_systolic_array_nxn/dut/pe_sum_matrix
add wave sim:/tb_systolic_array_nxn/dut/pe_valid_matrix

add wave -divider "PE00 Internal"
add wave -r sim:/tb_systolic_array_nxn/dut/ROW_GEN[0]/COL_GEN[0]/u_cell/*

add wave -divider "PE77 Internal"
add wave -r sim:/tb_systolic_array_nxn/dut/ROW_GEN[7]/COL_GEN[7]/u_cell/*

run -all