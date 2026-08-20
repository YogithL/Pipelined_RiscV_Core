
interface pc_bfm(input clk);

    logic branchTaken;
    logic branchEnable;
    logic jumpEnable;
    logic[31:0] pcMuxOut;
    logic validE;
  
    task samplePC(output logic[31:0] pcMuxOut_in,
                  output logic branchTaken_in,
                  output logic branchEnable_in,
                  output logic jumpEnable_in,
                  output logic exValid_in);
        @(posedge clk);
            pcMuxOut_in = pcMuxOut;
            branchTaken_in = branchTaken;
            branchEnable_in = branchEnable;
            jumpEnable_in = jumpEnable;
            exValid_in = validE;
    endtask
endinterface