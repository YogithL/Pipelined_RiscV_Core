
interface instr_bfm(input logic clk);
    
    logic[31:0] instr;
    
    task sendInstr(input logic[31:0] instr_out);
        @(posedge clk);
            instr <= instr_out;      
    endtask

    task sampleInstr(output logic[31:0] instr_in);
        @(posedge clk);
            instr_in = instr;
    endtask

endinterface