
module riscv_core import riscV_pkg::*;(
    input logic clk,
    input logic reset_n,
    
    //ROM Interface
    output logic[31:0] PCF,
    input logic[31:0] InstrF,
    
    //RAM Interface
    output logic[3:0] MemWrite,
    output logic MemRead,
    output logic[31:0] ReadAddr,
    output logic[31:0] write_data,
    input logic[31:0] read_data
    );
    
    //PC
        //PC Freeze
            logic pcEnable;
        
        //PC MUX
            PCSelection pcMuxSel;
            logic[31:0] ALU_Out;
            logic[31:0] Branch_Addr;
            logic[31:0] PCPlus4;
            logic[31:0] pcMuxOut;
        
            always_comb begin
                case(pcMuxSel)
                    BRANCH: pcMuxOut = Branch_Addr;
                    PCPLUS4: pcMuxOut = PCPlus4;
                    JUMP: pcMuxOut = ALU_Out; 
                    default: pcMuxOut = PCPlus4;
                endcase
            end
        
        //PC Register    
            always_ff @(posedge clk or negedge reset_n) begin
                if(!reset_n)
                    PCF <= 32'b0;
                else if(pcEnable)
                   PCF <= pcMuxOut;
            end
            
        //PCPlus4
            logic[31:0] PCPlus4F;
            assign PCPlus4F = pcMuxOut + 3'd4;
            
            
            
    //IF/ID Register
        logic IF_ID_Enable;
        logic flushIF_ID;
        
        p_if_id_s inIF_ID;
            assign inIF_ID.instr = InstrF;
            assign inIF_ID.PCD = PCF;
            assign inIF_ID.PCPlus4D = PCPlus4F;
        
        p_if_id_s outIF_ID;
        
        REG_IF_ID if_id(
            .clk(clk),
            .rst_n(reset_n),
            .EN(IF_ID_Enable),
            .CLR(flushIF_ID),
            .in_IF_ID(inIF_ID),
            .out_IF_ID(outIF_ID)
            );
        
        
        
    //Decode
        ctrlunit_flags_s controlFlags;
        immsrc_e immControl;
        
        ControlUnit control_unit(
            .opcode(outIF_ID.instr[6:0]),
            .funct3(outIF_ID.instr[14:12]),
            .funct7(outIF_ID.instr[31:25]),
            .immControl(immControl),
            .flags(controlFlags)
            );
        
        //MEM/WB Register, needed for RegFile
               p_mem_wb_s inMEM_WB;
               p_mem_wb_s outMEM_WB;
               
               REG_MEM_WB mem_wb(
                    .clk(clk),
                    .rst_n(reset_n),
                    .in_MEM_WB(inMEM_WB),
                    .out_MEM_WB(outMEM_WB)
                    );
        
        //ResultMux, needed for RegFile
            logic[31:0] resultMuxOut;
            
            always_comb begin
                case(outMEM_WB.ResultSrcW)
                    MEM: resultMuxOut = outMEM_WB.ReadDataW;
                    ALU: resultMuxOut = outMEM_WB.ALUResultW;
                    PC4: resultMuxOut = outMEM_WB.PCPlus4W;
                    default: resultMuxOut = outMEM_WB.ALUResultW;
                endcase
            end
            
        logic[31:0] RegA;
        logic[31:0] RegB;
        logic[31:0] Imm;
        
        RegFile reg_file(
            .clk(clk),
            .RegWrite(outMEM_WB.RegWriteW),  
            .readAddr1(outIF_ID.instr[19:15]),
            .readAddr2(outIF_ID.instr[24:20]),
            .writeAddr(outMEM_WB.RdW),
            .writeData(resultMuxOut),
            .readData1(RegA),
            .readData2(RegB)
            );
        
        ImmGen imm_gen(
            .instr(outIF_ID.instr),
            .immControl(immControl),
            .imm(Imm)
            );
        
        //ID/EX, preperation for Exectute phase
            p_id_ex_s inID_EX;
                assign inID_EX.Rs1E = RegA;
                assign inID_EX.Rs2E = RegB;
                assign inID_EX.Rs1AddrE = outIF_ID.instr[19:15];
                assign inID_EX.Rs2AddrE = outIF_ID.instr[24:20];
                assign inID_EX.RdE = outIF_ID.instr[11:7];
                assign inID_EX.PCE = outIF_ID.PCD;
                assign inID_EX.PCPlus4E = outIF_ID.PCPlus4D;
                assign inID_EX.ImmE = Imm;
                assign inID_EX.ControlFlags = controlFlags;
                
            p_id_ex_s outID_EX; 
            logic flushID_EX;
            
            REG_ID_EX id_ex(
                .clk(clk),
                .CLR(flushID_EX),
                .rst_n(reset_n),
                .in_ID_EX(inID_EX),
                .out_ID_EX(outID_EX)
                );
           
    //Execute                
        logic[31:0] srcMuxOutA;
        logic[31:0] srcMuxOutB;
        logic[3:0] NZVC;
        
        //Forwarding Muxes done at end with full Hazard Unit
            logic[31:0] forwardMuxOutA;
            logic[31:0] forwardMuxOutB;

        //Source Muxes
            always_comb begin
                case(outID_EX.ControlFlags.ALUSrcA)
                    PC: srcMuxOutA = outID_EX.PCE;
                    REGA: srcMuxOutA = forwardMuxOutA;
                    ZERO: srcMuxOutA = 32'b0;
                    default: srcMuxOutA = forwardMuxOutA;
                endcase
                
                case(outID_EX.ControlFlags.ALUSrcB)
                    REGB: srcMuxOutB = forwardMuxOutB;
                    IMM: srcMuxOutB = outID_EX.ImmE;
                    default: srcMuxOutB = forwardMuxOutB;
                endcase
            end     
        
        ALU alu(
            .A(srcMuxOutA),
            .B(srcMuxOutB),
            .ALUControl(outID_EX.ControlFlags.ALUControl),
            .ALUResult(ALU_Out),
            .NZVC(NZVC)
            );
        
        logic takeBranch;
        
        BranchControlUnit branch_manager(
            .NZVC(NZVC),
            .branchEnable(outID_EX.ControlFlags.Branch),
            .jumpEnable(outID_EX.ControlFlags.Jump),
            .branchType(outID_EX.ControlFlags.BranchType),
            .PCSelection(pcMuxSel),
            .takeBranch(takeBranch)
            );
        
        assign Branch_Addr = outID_EX.ImmE + outID_EX.PCE;
    
    
    
    
    
    
    
    
    
endmodule


