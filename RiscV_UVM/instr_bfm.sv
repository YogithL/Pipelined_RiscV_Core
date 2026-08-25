
interface instr_bfm(input logic clk);
    logic[31:0] instr = 32'h00000013;
    logic[31:0] monitor_instr;
    logic[31:0] current_pc;
    logic validW;

    task sendInstr(input logic[31:0] instr_out);
        @(posedge clk);
        instr <= instr_out;
    endtask

    task sampleInstr(output logic[31:0] instr_in, output logic[31:0] pc_in, output logic valid_in);
        @(posedge clk);
        instr_in = monitor_instr;
        pc_in = current_pc;
        valid_in = validW;
    endtask
endinterface