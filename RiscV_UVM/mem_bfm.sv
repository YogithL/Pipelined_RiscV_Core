
interface mem_bfm(input logic clk);
    
    logic[3:0] MemWrite;
    logic MemRead;
    logic[31:0] Read_Addr;
    logic[31:0] Write_Addr;
    logic[31:0] write_data;
    logic[31:0] read_data;

    task sampleMem(output logic[3:0] MemWrite_in,
                   output logic MemRead_in,
                   output logic[31:0] Read_Addr_in,
                   output logic[31:0] Write_Addr_in,
                   output logic[31:0] write_data_in);
        
        @(posedge clk);
            MemWrite_in = MemWrite;
            MemRead_in = MemRead;
            Read_Addr_in = Read_Addr;
            Write_Addr_in = Write_Addr;
            write_data_in = write_data;
    endtask

    task memRead(input logic[31:0] read_data_out);
        @(posedge clk);
            read_data <= read_data_out; 
    endtask

    function void sampleReadData(output logic[31:0] read_data_in);
        read_data_in = read_data;
    endfunction

endinterface