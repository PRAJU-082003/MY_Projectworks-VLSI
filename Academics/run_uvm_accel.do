quit -sim

vlib work
vmap work work

vlog -sv -mfcu +incdir+. approx_multiplier.sv approx_mac.sv pe_4mac.sv systolic_cell_4mac.sv systolic_array_nxn.sv approx_systolic_ai_accel_top.sv accel_if.sv accel_assertions.sv accel_uvm_pkg.sv tb_uvm_top.sv

vsim -voptargs=+acc work.tb_uvm_top +UVM_TESTNAME=accel_test

add wave -divider "CLOCK"
add wave sim:/tb_uvm_top/clk

add wave -divider "INTERFACE CONTROL"
add wave sim:/tb_uvm_top/intf/rst_n
add wave sim:/tb_uvm_top/intf/start
add wave sim:/tb_uvm_top/intf/clear_acc
add wave sim:/tb_uvm_top/intf/done
add wave sim:/tb_uvm_top/intf/result_valid
add wave sim:/tb_uvm_top/intf/cycle_count

add wave -divider "INTERFACE DATA"
add wave sim:/tb_uvm_top/intf/row_a_in_flat
add wave sim:/tb_uvm_top/intf/col_b_in_flat
add wave sim:/tb_uvm_top/intf/pe_sum_flat
add wave sim:/tb_uvm_top/intf/pe_valid_flat

add wave -divider "DUT INTERNAL CONTROL"
add wave sim:/tb_uvm_top/dut/running
add wave sim:/tb_uvm_top/dut/row_valid_in
add wave sim:/tb_uvm_top/dut/col_valid_in

add wave -divider "ARRAY RESULTS"
add wave sim:/tb_uvm_top/dut/u_systolic_array/pe_sum_matrix
add wave sim:/tb_uvm_top/dut/u_systolic_array/pe_valid_matrix

add wave -divider "PE00 INTERNAL"
add wave -r sim:/tb_uvm_top/dut/u_systolic_array/ROW_GEN[0]/COL_GEN[0]/u_cell/*

add wave -divider "PE77 INTERNAL"
add wave -r sim:/tb_uvm_top/dut/u_systolic_array/ROW_GEN[7]/COL_GEN[7]/u_cell/*

run -all