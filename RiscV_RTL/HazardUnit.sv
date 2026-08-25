module HazardUnit import riscV_pkg::*;(
    input logic[4:0] Rs1AddrD, Rs2AddrD, Rs1AddrE, Rs2AddrE, Rs2AddrM,
    input logic[4:0] RdE, RdM, RdW,
    input logic[31:0] ALUResultM, ALUResultW,
    input logic memReadE, memReadM, memReadW, branchTaken,
    input logic[3:0] memWriteD, memWriteM, memWriteW,
    input logic regWriteM, regWriteW,
    output forward_selA_e forwardA,
    output forward_selB_e forwardB,
    output forward_ld_str_e forwardWD,
    output logic[3:0] forwardRD,
    output logic pcEnable, IF_ID_Enable, FlushD, FlushE
    );
    
    always_comb begin
        pcEnable = 1'b1;
        IF_ID_Enable = 1'b1;
        FlushD = 1'b0;
        FlushE = 1'b0;
    
        //Forwarding
        if((Rs1AddrE != 0) && (Rs1AddrE == RdM) && (RdM != 0) && regWriteM)
            forwardA = FORWARD_MEM_A;
        else if((Rs1AddrE != 0) && (Rs1AddrE == RdW) && (RdW != 0) && regWriteW)
            forwardA = FORWARD_WB_A;
        else
            forwardA = NO_FORWARD_A; 
            
        if((Rs2AddrE != 0) && (Rs2AddrE == RdM) && (RdM != 0) && regWriteM)
            forwardB = FORWARD_MEM_B;
        else if((Rs2AddrE != 0) && (Rs2AddrE == RdW) && (RdW != 0) && regWriteW)
            forwardB = FORWARD_WB_B;
        else
            forwardB = NO_FORWARD_B;
                    
        //Stalling, need to get memWrite straight from control unit
        if((memReadE && RdE != 0) && //Term 1
        ((Rs1AddrD == RdE) || (Rs2AddrD == RdE && memWriteD == 0)) //Term 2
        ) begin
            pcEnable = 1'b0;
            IF_ID_Enable = 1'b0;
            FlushE = 1'b1;
        end
        
        //Load followed by a Store
        if(memWriteM && memReadW && (Rs2AddrM == RdW) && (RdW != 5'b0))
            forwardWD = FORWARD_WD_WB;
        else
            forwardWD = NO_FORWARD_WD;
        
        //Store followed by a Load
        if(memReadM && memWriteW && ALUResultM[31:2] == ALUResultW[31:2])
            forwardRD = memWriteW;
        else
            forwardRD = 4'b0000;
       
       if(branchTaken) begin
            FlushD = 1'b1;
            FlushE = 1'b1;
        end
    end
    
endmodule
