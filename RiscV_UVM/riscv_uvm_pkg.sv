package riscv_uvm_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
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