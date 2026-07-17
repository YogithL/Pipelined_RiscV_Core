
module tb();

    import riscV_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh" 

    logic clk;
    logic reset_n;

    //Interfaces
    instr_bfm instrBfm(clk);
    mem_bfm memBfm(clk);
    pc_bfm pcBfm(clk);
    reg_bfm regBfm(clk);

    riscv_core dut(
        .clk(clk),
        .reset_n(reset_n),

        // ROM Interface
        .InstrF(instrBfm.instr),
        .pcMuxOut(pcBfm.pcMuxOut),

        // RAM Interface
        .MemWrite(memBfm.MemWrite),
        .MemRead(memBfm.MemRead),
        .Read_Addr(memBfm.Read_Addr),
        .Write_Addr(memBfm.Write_Addr),
        .write_data(memBfm.write_data),
        .read_data(memBfm.read_data)
    );

    assign regBfm.rd_data = dut.inMEM_WB.ReadDataW;
    assign regBfm.rd_addr = dut.inMEM_WB.RdW;
    assign regBfm.reg_write = dut.inMEM_WB.RegWriteW;
    assign regBfm.retire_valid = dut.inMEM_WB.valid_opW;

    assign pcBfm.branchEnable = dut.outID_EX.ControlFlags.Branch;
    assign pcBfm.branchTaken = dut.takeBranch;
    assign pcBfm.jumpEnable = dut.outID_EX.ControlFlags.Jump;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset_n = 0;
        #20;
        reset_n = 1;
    end

    initial begin
        uvm_config_db#(virtual instr_bfm)::set(null, "*", "instr_vif", instrBfm);
        uvm_config_db#(virtual mem_bfm)::set(null, "*", "mem_vif", memBfm);
        uvm_config_db#(virtual pc_bfm)::set(null, "*", "pc_vif", pcBfm);
        uvm_config_db#(virtual reg_bfm)::set(null, "*", "reg_vif", regBfm);

        run_test("base_test"); 
    end

endendmodule