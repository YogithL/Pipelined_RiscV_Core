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
        forever #10 clk = ~clk; 
    end
    
    initial begin
        reset_n = 1;
        #5;  
        reset_n = 0;
        #20;
        reset_n = 1;
    end
    
    always @(negedge clk) begin
        if (reset_n) begin
            if (dut.core.outEX_MEM.MemWriteM) begin
                $display("\n[Time %0t] --- MEMORY WRITE DETECTED ---", $time);
                $display("   > Address (ALUResultM) : %0d", dut.core.outEX_MEM.ALUResultM);
                $display("   > Raw Data (WriteDataM): %0d", dut.core.outEX_MEM.WriteDataM);
                $display("   > Forwarded Data       : %0d", dut.core.forwardWDOut);
                $display("   > Forward Conditions   : Rs2M=%0d | RdW=%0d | RegWriteW=%b", 
                         dut.core.outEX_MEM.Rs2AddrM, dut.core.outMEM_WB.RdW, dut.core.outMEM_WB.RegWriteW);
                $display("----------------------------------------\n");
            end

            if (dut.core.outEX_MEM.MemReadM) begin
                $display("[Time %0t] [MEM READ] Addr: %0d", $time, dut.core.outEX_MEM.ALUResultM);
            end
        end
    end
    
    initial begin
        #600; 
        $display("RISC-V PIPELINE FINAL SCOREBOARD");

        if(dut.core.reg_file.RegArray[3] === 32'd5) 
            $display("[PASS] Data Forwarding: x3 == 5");  
        else
            $display("[FAIL] Data Forwarding: x3 == %0d (Expected: 5)", dut.core.reg_file.RegArray[3]);

        if(dut.core.reg_file.RegArray[5] === 32'd5) 
            $display("[PASS] Load-Use Stall: x5 == 5");  
        else
            $display("[FAIL] Load-Use Stall: x5 == %0d (Expected: 5)", dut.core.reg_file.RegArray[5]);

        if(dut.core.reg_file.RegArray[6] === 32'd1) 
            $display("[PASS] Branch Not Taken: x6 == 1");  
        else
            $display("[FAIL] Branch Not Taken: x6 == %0d (Expected: 1)", dut.core.reg_file.RegArray[6]);

        if(dut.core.reg_file.RegArray[2] === 32'd7) 
            $display("[PASS] Branch Taken/Flush: x2 == 7");  
        else
            $display("[FAIL] Branch Taken/Flush: x2 == %0d (Expected: 7)", dut.core.reg_file.RegArray[2]);
        
        $stop;
    end
    
endmodule