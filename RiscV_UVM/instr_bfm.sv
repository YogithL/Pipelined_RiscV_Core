
interface instr_bfm(input logic clk);

    logic[31:0] instr;
    
    task sendInstr(input logic[31:0] instr_out);
        @(posedge clk);
            instr <= instr_out;      
    endtask

    function void sampleInstr(output logic[31:0] instr_in);
        instr_in = instr;
    endfunction

endinterface