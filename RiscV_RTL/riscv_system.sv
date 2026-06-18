module riscv_system import riscV_pkg::*;(
    input logic clk,
    input logic reset_n
    );
    
    //ROM Interface                    
    logic[31:0] InstrF;
    logic[31:0] pcMuxOut;          
                                       
    //RAM Interface                    
    logic[3:0] MemWrite;        
    logic[31:0] Read_Addr;
    logic[31:0] Write_Addr;
    logic[31:0] write_data;    
    logic[31:0] read_data;        
    
    riscv_core core(   
        .clk(clk),                      
        .reset_n(reset_n),                  
                                              
        //ROM Interface                       
        .InstrF(InstrF),
        .pcMuxOut(pcMuxOut),             
                                              
        //RAM Interface                       
        .MemWrite(MemWrite),           
        .Read_Addr(Read_Addr),   
        .Write_Addr(Write_Addr),
        .write_data(write_data),        
        .read_data(read_data)           
    );                                    
     
    ROM rom(
        .clk(clk),
        .fetch_addr(pcMuxOut),
        .instruction(InstrF)
        );
        
    RAM ram(
        .clk(clk),
        .MemWrite(MemWrite),
        .read_addr(Read_Addr),
        .write_addr(Write_Addr),
        .write_data(write_data),
        .read_data(read_data)
        );
        
    
endmodule
