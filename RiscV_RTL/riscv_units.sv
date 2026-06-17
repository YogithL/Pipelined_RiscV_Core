module ALU import riscV_pkg::*;(
    input logic[31:0] A,
    input logic[31:0] B,
    input alu_opps_e ALUControl, //Append funct3 with bit30
    output logic[31:0] ALUResult,
    output logic[3:0] NZVC
    );
        
    always_comb begin
        ALUResult = 32'b0;
        NZVC = 4'b0000;
        
        case(ALUControl)
            ALU_ADD: ALUResult = A + B;
            ALU_SUB: ALUResult = A - B;
            
            ALU_OR: ALUResult = A | B;
            ALU_AND: ALUResult = A & B;
            ALU_XOR: ALUResult = A ^ B;
            
            ALU_SRL: ALUResult = A >> B[4:0];
            ALU_SRA: ALUResult = $signed(A) >>> B[4:0];
            
            ALU_SLL: ALUResult = A << B[4:0];
            
            ALU_SLT: ALUResult = $signed(A) < $signed(B) ? 32'h0001 : 32'h0000;
            ALU_SLTU: ALUResult = (A) < (B) ? 32'h0001 : 32'h0000;
            
            default: ALUResult = 32'b0;
        endcase
         
        NZVC[1] = ~(| ALUResult);
        
        NZVC[0] = ALUResult[31]; 
        
        if(ALUControl == ALU_ADD) begin
            NZVC[2] = (A[31] == B[31]) && (A[31] != ALUResult[31]) ? 1'b1 : 1'b0;
            NZVC[3] = ({1'b0, A} + {1'b0, B} > {1'b0, ALUResult}) ? 1'b1 : 1'b0; 
        end
        
        if(ALUControl == ALU_SUB) begin
            NZVC[2] = (A[31] != B[31]) && (A[31] != ALUResult[31]) ? 1'b1 : 1'b0;
            NZVC[3] = B > A  ? 1'b1 : 1'b0; 
        end
    end
    
endmodule



module RegFile(
    input logic clk,
    input logic RegWrite,
    input logic[4:0] readAddr1,
    input logic[4:0] readAddr2,
    input logic[4:0] writeAddr,
    input logic[31:0] writeData,
    output logic[31:0] readData1,
    output logic[31:0] readData2
    );
    import riscV_pkg::*;
    
    logic[31:0] RegArray[0:31];
    
    always_ff @(posedge clk) begin
        if(RegWrite && (writeAddr != 5'b0))
            RegArray[writeAddr] <= writeData;    
    end
    
    always_comb begin
        if(readAddr1 == 5'b0)
            readData1 = 32'b0;
        else if(readAddr1 == writeAddr && RegWrite)
            readData1 = writeData;
        else
            readData1 = RegArray[readAddr1];
        
        if(readAddr2 == 5'b0)
            readData2 = 32'b0;
        else if(readAddr2 == writeAddr && RegWrite)
            readData2 = writeData;
        else
            readData2 = RegArray[readAddr2];
    end
endmodule

module ImmGen import riscV_pkg::*;(
    input logic[31:0] instr,
    input immsrc_e immControl,
    output logic[31:0] imm
    );
        
    always_comb begin        
        case(immControl)
            IMM_I: imm = { {20{instr[31]}} , instr[31:20] };
            IMM_U: imm = { instr[31:12] , 12'b0 };
            IMM_S: imm = { {20{instr[31]}} , instr[31:25] , instr[11:7] };
            IMM_B: imm = { {19{instr[31]}} , instr[31] , instr[7] , instr[30:25] , instr[11:8] , 1'b0 };
            IMM_J: imm = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };
            default: imm = 32'b0;
        endcase
    end
        
endmodule       



module BranchControlUnit import riscV_pkg::*;(
    input logic[3:0] NZVC,
    input logic branchEnable,
    input logic jumpEnable,
    input branch_types_e branchType,
    output pc_sel_e PCSelection,
    output logic takeBranch
    );
             
    always_comb begin
        takeBranch = 1'b0;
        
        if(branchEnable) begin
            case(branchType)
                BR_BEQ: takeBranch = NZVC[1];
                BR_BNE: takeBranch = ~NZVC[1];
                BR_BLT: takeBranch = NZVC[0] ^ NZVC[2];
                BR_BLTU: takeBranch = NZVC[3];
                BR_BGE: takeBranch = NZVC[1] || ~(NZVC[0] ^ NZVC[2]);
                BR_BGEU: takeBranch = NZVC[1] || ~NZVC[3];
                default: takeBranch = 1'b0;
            endcase
        end
        
        if(branchEnable && takeBranch)
            PCSelection = BRANCH;
        else if(jumpEnable)
            PCSelection = JUMP;
        else
            PCSelection = PCPLUS4;
    end
    
endmodule           
    
    
    

    
    
    
    
    
    
    
    
    
   