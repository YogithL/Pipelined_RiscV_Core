
module ControlUnit import riscV_pkg::*;(
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    input logic[6:0] funct7,
    output immsrc_e immControl,
    output ctrlunit_flags_s flags
    );
    
    logic use_funct7;
    
    always_comb begin
        flags = '0;
        immControl = IMM_I;
        use_funct7 = (opcode == OP_Reg) || (opcode == OP_Imm && (funct3 == 3'b001 || funct3 == 3'b101));
        
        case(opcode)
            OP_Reg, OP_Imm: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = ALU;
                flags.ALUControl = alu_opps_e'({(use_funct7 ? funct7[5] : 1'b0), funct3});
                
                if(opcode == OP_Reg) 
                    flags.ALUSrcB = REGB;
                else begin
                    flags.ALUSrcB = IMM;
                    immControl = IMM_I;
                end
            end
            
            OP_Load: begin
                flags.RegWrite = 1'b1;
                flags.MemRead = 1'b1;
                flags.ALUSrcB = IMM;
                flags.ResultSrc = MEM;
                flags.ALUControl = ALU_ADD;
                flags.Size = width_e'(funct3);
                immControl = IMM_I;
            end 
            
            OP_Store: begin
                flags.ALUSrcB = IMM;
                //ResultSrcE doesn't matter since RegWrite low
                flags.ALUControl = ALU_ADD;
                flags.Size = width_e'(funct3);
                immControl = IMM_S;
                
                case(funct3)
                    3'b010: flags.MemWrite = 4'b1111;
                    3'b001: flags.MemWrite = 4'b0011;
                    3'b000: flags.MemWrite = 4'b0001;
                    default: flags.MemWrite = 4'b1111;
                endcase     
        
            end
            
            OP_Branch: begin
                flags.ALUSrcB = REGB;
                flags.ALUSrcA = REGA;
                flags.ALUControl = ALU_SUB;
                flags.Branch = 1'b1;
                flags.BranchType = branch_types_e'(funct3);
                immControl = IMM_B;
            end
            
            OP_LUI: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = ALU;
                flags.ALUSrcA = ZERO;
                flags.ALUSrcB = IMM;
                immControl = IMM_U;
                flags.ALUControl = ALU_ADD;
            end
            
            OP_AUIPC: begin
                flags.RegWrite = 1'b1;
                flags.ALUSrcA = PC; 
                flags.ALUSrcB = IMM;     
                flags.ResultSrc = ALU;      
                flags.ALUControl = ALU_ADD;
                immControl = IMM_U;
            end
            
            OP_JAL: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = PC4;
                flags.ALUSrcA = PC; 
                flags.ALUSrcB = IMM;     
                flags.ALUControl = ALU_ADD;
                immControl = IMM_J;
            end
            
            OP_JALR: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = PC4;
                flags.ALUSrcA = REGA; 
                flags.ALUSrcB = IMM;     
                flags.ALUControl = ALU_ADD;
                immControl = IMM_I;
            end
            
        endcase
    end
    
endmodule
