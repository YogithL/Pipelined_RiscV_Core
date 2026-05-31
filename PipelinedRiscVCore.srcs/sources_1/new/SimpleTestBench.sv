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
        #10;
        reset_n = 0;
        #10;
        reset_n = 1;
        
        #200;
        
        if(dut.core.reg_file.RegArray[7] === 32'h00000005)
            $display("[PASS] ROM Check: x7 = 5");
        else
            $display("[FAIL] ROM Check: Expected x7=5, I got x7 = %0h", dut.core.reg_file.RegArray[7]);
        
        if(dut.core.reg_file.RegArray[4] === 32'h000001FE)
            $display("[PASS] RAM/Hazard Check: x4=1fe");
        else
            $display("[FAIL] RAM/Hazard Check: Expected x4=1fe, got x4=%0h", dut.core.reg_file.RegArray[4]);
        
        $finish;
    end
    
endmodule