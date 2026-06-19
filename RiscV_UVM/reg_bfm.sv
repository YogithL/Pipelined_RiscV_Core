
interface reg_bfm(input logic clk);
    
    logic[31:0] rd_data;
    logic[4:0] rd_addr;
    logic reg_write;

    task sampleReg(output logic[31:0] rd_data_in, 
                   output logic[4:0] rd_addr_in,
                   output logic reg_write_in);

        @(posedge clk);
            rd_data_in = rd_data;
            rd_addr_in = rd_addr;
            reg_write_in = reg_write;
    endtask

endinterface

