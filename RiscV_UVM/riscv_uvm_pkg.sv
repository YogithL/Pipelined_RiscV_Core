package riscv_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import riscV_pkg::*;
    
    import "DPI-C" context function void golden_init();
	import "DPI-C" function void golden_set_pc(int pc);
    import "DPI-C" context function void golden_step(int instr);
    import "DPI-C" context function int  golden_get_reg(int reg_idx);
    import "DPI-C" context function void golden_write_reg(int reg_idx, int val);
    import "DPI-C" context function int  golden_get_pc();
    import "DPI-C" context function void golden_write_mem(int addr, int data, int width_enum);
    import "DPI-C" context function int  golden_read_mem(int addr, int width_enum);
    
    `include "base_stim_packet.sv"
    `include "mem_packet.sv"
    `include "pc_packet.sv"
    `include "reg_packet.sv"

    `include "rand_sequence.sv"

    `include "instr_monitor.sv"
    `include "mem_monitor.sv"
    `include "pc_monitor.sv"
    `include "reg_monitor.sv"

    `include "instr_driver.sv"
    `include "mem_driver.sv"
    
    `include "sequencer.sv"

    `include "instr_agent.sv"
    `include "mem_agent.sv"
    `include "pc_agent.sv"
    `include "reg_agent.sv"

    `include "scoreboard.sv"

    `include "environment.sv"
    
    `include "base_test.sv"

endpackage: riscv_uvm_pkg