`timescale 1ns / 1ps

module SimpleTestBench();
    logic clk;
    logic reset_n;
    
    riscv_system dut(
        .clk(clk),
        .reset_n(reset_n)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        reset_n = 1;
        #1; 
        reset_n = 0;
        #20;
        reset_n = 1;
        
        #300;
        
        //Load -> Store
        if(dut.core.reg_file.RegArray[3] === 5) 
            $display("Test Passed: My result was %0d, expected was 5", dut.core.reg_file.RegArray[3]);  
        else
            $display("Test Failed: My result was %0d, expected was 5", dut.core.reg_file.RegArray[3]);
            
        //Load Use Stall
        if(dut.core.reg_file.RegArray[5] === 5) 
            $display("Test Passed: My result was %0d, expected was 5", dut.core.reg_file.RegArray[5]);  
        else
            $display("Test Failed: My result was %0d, expected was 5", dut.core.reg_file.RegArray[5]);
        
        //Branch not Taken
        if(dut.core.reg_file.RegArray[6] === 1) 
            $display("Test Passed: My result was %0d, expected was 1", dut.core.reg_file.RegArray[5]);  
        else
            $display("Test Failed: My result was %0d, expected was 1", dut.core.reg_file.RegArray[5]);
        
        //Branch Taken
        if(dut.core.reg_file.RegArray[2] === 7) 
            $display("Test Passed: My result was %0d, expected was 8", dut.core.reg_file.RegArray[2]);  
        else
            $display("Test Failed: My result was %0d, expected was 8", dut.core.reg_file.RegArray[2]);
            
            
        $finish;
    end
    
endmodule