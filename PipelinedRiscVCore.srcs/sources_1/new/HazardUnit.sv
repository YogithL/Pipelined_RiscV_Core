module HazardUnit import riscV_pkg::*;(
    input logic[4:0] Rs1AddrD, Rs2AddrD, Rs1AddrE, Rs2AddrE, Rs2AddrM,
    input logic[4:0] RdE, RdM, RdW,
    input logic memReadE, memReadW, branchTaken,
    input logic[3:0] memWriteD, memWriteM,
    input logic regWriteM, regWriteW,
    output forward_selA_e forwardA,
    output forward_selB_e forwardB,
    output forward_ld_str_e forwardWD,
    output logic pcEnable, IF_ID_Enable, FlushD, FlushE
    );
    
    always_comb begin
        pcEnable = 1'b1;
        IF_ID_Enable = 1'b1;
        FlushD = 1'b0;
        FlushE = 1'b0;

    
        //Forwarding
        if(Rs1AddrE == RdM && (RdM != 0) && regWriteM)
            forwardA = FORWARD_MEM_A;
        else if(Rs1AddrE == RdW && (RdW != 0) && regWriteW)
            forwardA = FORWARD_WB_A;
        else
            forwardA = NO_FORWARD_A; 
            
        if(Rs2AddrE == RdM && (RdM != 0) && regWriteM)
            forwardB = FORWARD_MEM_B;
        else if(Rs2AddrE == RdW && (RdW != 0) && regWriteW)
            forwardB = FORWARD_WB_B;
        else
            forwardB = NO_FORWARD_B;
        
        //Stalling, need to get memWrite straight from control unit
        if(memReadE && (memWriteD == 0) && ((Rs1AddrD == RdE) || (Rs2AddrD == RdE))) begin
            pcEnable = 1'b0;
            IF_ID_Enable = 1'b0;
            FlushE = 1'b1;
        end
        
        //Load -> Store
        if(Rs2AddrM == RdW && memWriteM != 0 && memReadW)
            forwardWD = FORWARD_WD_WB;
        else
            forwardWD = NO_FORWARD_WD;
        
        //Flushing, + Stall collision
        if(branchTaken) begin
            pcEnable = 1'b1; 
            IF_ID_Enable = 1'b1;
            FlushD = 1'b1;
            FlushE = 1'b1;
        end
    end
    
endmodule

