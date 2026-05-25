
module ControlUnit import riscV_pkg::*;(
    input logic[6:0] opcode,
    input logic[2:0] funct3,
    input logic[6:0] funct7,
    output immsrc_e immControl,
    output ctrlunit_flags_s flags
    );
    
    always_comb begin
        flags = '0;
        
        case(opcode)
            OP_Reg, OP_Imm: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = ALU;
                flags.ALUControl = alu_opps_e'({funct7[5], funct3});
                
                if(opcode == OP_Reg) 
                    flags.ALUSrcB = REGB;
                else
                    flags.ALUSrcB = IMM;
            end
            
            OP_Load: begin
                flags.RegWrite = 1'b1;
                flags.MemRead = 1'b1;
                flags.ALUSrcB = IMM;
                flags.ResultSrc = MEM;
                flags.ALUControl = ALU_ADD;
                flags.Size = width_e'(funct3);
            end 
           
            OP_Store: begin
                flags.MemWrite = 1'b1;
                flags.ALUSrcB = IMM;
                //ResultSrcE doesn't matter since RegWrite low
                flags.ALUControl = ALU_ADD;
                flags.Size = width_e'(funct3);
            end
            
            OP_Branch: begin
                flags.ALUSrcB = REGB;
                flags.ALUSrcA = REGA;
                flags.ALUControl = ALU_ADD;
                flags.Branch = 1'b1;
                flags.BranchType = branch_types_e'(funct3);
            end
            
            OP_LUI: begin
                flags.RegWrite = 1'b1;
                flags.ResultSrc = UI_IMM;
            end
            
            OP_AUIPC: begin
                flags.RegWrite = 1'b1;
                flags.ALUSrcA = PC; 
                flags.ALUSrcB = IMM;     
                flags.ResultSrc = ALU;      
                flags.ALUControl = ALU_ADD;
            end
            
            OP_JAL: begin
                flags.RegWrite = 1'b1;
                flags.ALUSrcA = PC; 
                flags.ALUSrcB = IMM;     
                flags.ALUControl = ALU_ADD;
            end
            
            OP_JALR: begin
                flags.ALUSrcA = REGA; 
                flags.ALUSrcB = IMM;     
                flags.ALUControl = ALU_ADD;
            end
            
        endcase
    end        
                                               
                          
        
    
    
    
    
    
endmodule
