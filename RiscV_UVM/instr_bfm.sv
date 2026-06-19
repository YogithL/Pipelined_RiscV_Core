
interface instr_bfm(input logic clk);

    logic[31:0] instr;
    logic[31:0] pcMuxOut;
    logic branchTaken;
    logic branchEnable;
    logic jumpEnable;
    
    task sendInstr(input logic[31:0] instr_out);
        @(posedge clk);
            instr <= instr_out;      
    endtask

    function void sampleInstr(output logic[31:0] instr_in);
        instr_in = instr;
    endfunction

    task samplePC(output logic[31:0] pcMuxOut_in, 
                  output logic branchTaken_in, 
                  output logic branchEnable_in, 
                  output logic jumpEnable_in);

            @(posedge clk);
                pcMuxOut_in = pcMuxOut;
                branchTaken_in = branchTaken;
                branchEnable_in = branchEnable;
                jumpEnable_in = jumpEnable;
    endtask

endinterface