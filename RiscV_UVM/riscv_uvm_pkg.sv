package riscv_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import "DPI-C" context function void spike_init();
    import "DPI-C" context function void spike_reset();
    import "DPI-C" context function void spike_step(int instr);
    import "DPI-C" context function int  spike_get_reg(int reg_idx);
    import "DPI-C" context function void spike_write_mem(int addr, int data);
    import "DPI-C" context function void spike_set_pc(int val);

    `include "base_stim_packet.sv"
    `include "mem_packet.sv"
    `include "pc_packet.sv"
    `include "reg_packet.sv"

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
    //need to add env, coverage, test, sequenece

endpackage: riscv_uvm_pkg