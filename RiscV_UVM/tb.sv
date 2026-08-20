`include "instr_bfm.sv"
`include "mem_bfm.sv"
`include "pc_bfm.sv"
`include "reg_bfm.sv"

`include "riscv_uvm_pkg.sv"

module tb();

    import riscV_pkg::*;
    import uvm_pkg::*;
    import riscv_uvm_pkg::*;
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
  	
	assign instrBfm.current_pc = dut.outMEM_WB.PCPlus4W - 4;
    assign instrBfm.monitor_instr = dut.outMEM_WB.InstrW; 
  	assign instrBfm.validW = dut.outMEM_WB.valid_opW;
  
    assign regBfm.rd_data = (dut.outMEM_WB.RdW == 5'b0) ? 32'b0 : dut.resultMuxOut;
    assign regBfm.rd_addr = dut.outMEM_WB.RdW;
    assign regBfm.reg_write = dut.outMEM_WB.RegWriteW;
    assign regBfm.retire_valid = dut.outMEM_WB.valid_opW;
  
    assign pcBfm.branchEnable = dut.outID_EX.ControlFlags.Branch;
    assign pcBfm.branchTaken = dut.takeBranch;
    assign pcBfm.jumpEnable = dut.outID_EX.ControlFlags.Jump;
  	assign pcBfm.validE = dut.outID_EX.valid_opE;

	generate
        genvar i;
        for (i = 0; i < 32; i++) begin : backdoor_init_loop
            initial begin
                #1; 
                force dut.reg_file.RegArray[i] = 32'h00000000;
                
                #1; 
                release dut.reg_file.RegArray[i];
            end
        end
    endgenerate
    
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
endmodule