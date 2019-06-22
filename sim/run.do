quit -sim

vlib work 

vlog "./*.v"
vlog "../src/*.v"
vsim -voptargs=+acc work.sdram_controller_tb

add wave -divider {sdram_controller_tb}
add wave sdram_controller_tb/*
add wave -ascii  sdram_controller_tb/cmd_monitor

add wave -divider {sdram_pll}
add wave sdram_controller_tb/sdram_controller/sdram_pll/*

add wave -divider {sdram_init}
add wave sdram_controller_tb/sdram_controller/sdram_init/*

add wave -divider {sdram_ref}
add wave sdram_controller_tb/sdram_controller/sdram_ref/*

add wave -divider {ref_timer}
add wave sdram_controller_tb/sdram_controller/ref_timer/*

add wave -divider {sdram_write}
add wave sdram_controller_tb/sdram_controller/sdram_write/*

add wave -divider {sdram_read}
add wave sdram_controller_tb/sdram_controller/sdram_read/*

add wave -divider {sdram_fsm_controller}
add wave sdram_controller_tb/sdram_controller/sdram_fsm_controller/*

.main clear

run 300us
#run -all