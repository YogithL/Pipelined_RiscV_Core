
module riscv_core import riscV_pkg::*;(
    input logic clk,
    input logic reset_n,
    
    //ROM Interface
    input logic[31:0] InstrF,
    output logic[31:0] pcMuxOut,
    
    //RAM Interface
    output logic[3:0] MemWrite,
    output logic MemRead,
    output logic[31:0] Read_Addr,
    output logic[31:0] Write_Addr,
    output logic[31:0] write_data,
    input logic[31:0] read_data
    );
    
    //PC
        logic[31:0] PCF;
                        
        //PC Freeze
            logic pcEnable;
            logic[31:0] pcMuxOut_int;   // internal signal
            assign pcMuxOut = pcMuxOut_int;  // drive port from it
            
        //PC MUX
            pc_sel_e pcMuxSel;
            logic[31:0] ALU_Out;
            logic[31:0] Branch_Addr;
            logic[31:0] PCPlus4F;
        
            always_comb begin
                case(pcMuxSel)
                    BRANCH: pcMuxOut_int = Branch_Addr;
                    PCPLUS4: pcMuxOut_int = PCPlus4F;
                    JUMP: pcMuxOut_int = ALU_Out; 
                    default: pcMuxOut_int = PCPlus4F;
                endcase
            end
        
        //PC Register    
            always_ff @(posedge clk or negedge reset_n) begin
                if(!reset_n)
                    PCF <= 32'hFFFFFFFC;
                else if(pcEnable)
                   PCF <= pcMuxOut_int;
            end
            
        //PCPlus4
            assign PCPlus4F = PCF + 32'd4;
            
            
            
    //IF/ID Register
        logic IF_ID_Enable;
        logic flushIF_ID;
        
        logic valid_opF;
        assign valid_opF = 1'b1; 
            
        p_if_id_s inIF_ID;
        assign inIF_ID.instr = InstrF;
        assign inIF_ID.PCD = PCF;
        assign inIF_ID.PCPlus4D = PCPlus4F;
        assign inIF_ID.valid_opD = valid_opF; 
            
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
        logic valid_opE;
        
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
                assign inID_EX.PCE = 32'b0; //outIF_ID.PCD;
                assign inID_EX.PCPlus4E = outIF_ID.PCPlus4D;
                assign inID_EX.ImmE = Imm;
                assign inID_EX.ControlFlags = controlFlags;
                assign inID_EX.valid_opE = outIF_ID.valid_opD;
                
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
        
        //Forward Mux Variables, declaring outEX_MEM for forwardMuxes
            p_ex_mem_s outEX_MEM; 
            forward_selA_e forwardMuxASel;
            forward_selB_e forwardMuxBSel;
            
            logic[31:0] forwardMuxOutA;
            logic[31:0] forwardMuxOutB;
             
            always_comb begin              
                case(forwardMuxASel)                                      
                    NO_FORWARD_A: forwardMuxOutA = outID_EX.Rs1E;         
                    FORWARD_MEM_A: forwardMuxOutA = outEX_MEM.ALUResultM; 
                    FORWARD_WB_A: forwardMuxOutA = resultMuxOut;          
                    default: forwardMuxOutA = outID_EX.Rs1E;              
                endcase                                                   
                                                                          
                case(forwardMuxBSel)                                      
                    NO_FORWARD_B: forwardMuxOutB = outID_EX.Rs2E;         
                    FORWARD_MEM_B: forwardMuxOutB = outEX_MEM.ALUResultM; 
                    FORWARD_WB_B: forwardMuxOutB = resultMuxOut;          
                    default: forwardMuxOutB = outID_EX.Rs2E;              
                endcase                                                   
            end                                                          
            
            
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
        
        p_ex_mem_s inEX_MEM;
            assign inEX_MEM.RdM = outID_EX.RdE;
            assign inEX_MEM.PCPlus4M = outID_EX.PCPlus4E;
            assign inEX_MEM.ALUResultM = ALU_Out;
            assign inEX_MEM.WriteDataM = forwardMuxOutB;
            assign inEX_MEM.Rs2AddrM = outID_EX.Rs2AddrE;
            assign inEX_MEM.RegWriteM = outID_EX.ControlFlags.RegWrite;
            assign inEX_MEM.MemReadM = outID_EX.ControlFlags.MemRead;     
            assign inEX_MEM.MemWriteM = outID_EX.ControlFlags.MemWrite;   
            assign inEX_MEM.ResultSrcM = outID_EX.ControlFlags.ResultSrc;
            assign inEX_MEM.SizeM = outID_EX.ControlFlags.Size;
            assign inEX_MEM.valid_opM = outID_EX.valid_opE;
    
        REG_EX_MEM ex_mem(
            .clk(clk),
            .rst_n(reset_n),
            .in_EX_MEM(inEX_MEM),
            .out_EX_MEM(outEX_MEM)
            );
    
    //Mem Write
        logic[31:0] alignedWD;
        logic[31:0] alignedRD;
        
        assign MemRead = outEX_MEM.MemReadM;
        assign MemWrite = outEX_MEM.MemWriteM;
        assign Read_Addr = ALU_Out; 
        assign Write_Addr= outEX_MEM.ALUResultM;
        assign write_data = alignedWD;
        
        //inMEM_WB, outMEM_WB, and mem_wb module all declared previously in Decode
            assign inMEM_WB.RdW = outEX_MEM.RdM;
            assign inMEM_WB.PCPlus4W = outEX_MEM.PCPlus4M;
            assign inMEM_WB.ALUResultW = outEX_MEM.ALUResultM;
            assign inMEM_WB.ReadDataW = alignedRD; //SA
            assign inMEM_WB.MemReadW = outEX_MEM.MemReadM;
            assign inMEM_WB.RegWriteW = outEX_MEM.RegWriteM;
            assign inMEM_WB.ResultSrcW = outEX_MEM.ResultSrcM;
            assign inMEM_WB.WriteDataW = alignedWD;
            assign inMEM_WB.MemWriteW = outEX_MEM.MemWriteM; 
            assign inMEM_WB.valid_opW = outEX_MEM.valid_opM;

        
        logic[31:0] forwardWDOut; //If we need to Store the output of the previous Load
        logic[31:0] forwardRDOut; //If we need to Load the output of the previous Store
        
        DataAligner data_aligner(
            .size(outEX_MEM.SizeM),
            .write_data(forwardWDOut),
            .read_addr(outEX_MEM.ALUResultM),
            .write_addr(outEX_MEM.ALUResultM),
            .read_data(forwardRDOut),
            .aligned_WD(alignedWD),
            .aligned_RD(alignedRD)
            );
    
    //Write Back
        //Only consists of ResultMux which was handled back in Decode
    
    
    //Hazard Control Unit 
        forward_ld_str_e forwardWD;
        forward_str_ld_e forwardRD;
        
        HazardUnit hazard_unit(
            .Rs1AddrD(outIF_ID.instr[19:15]),
            .Rs2AddrD(outIF_ID.instr[24:20]),
            .Rs1AddrE(outID_EX.Rs1AddrE),
            .Rs2AddrE(outID_EX.Rs2AddrE),
            .Rs2AddrM(outEX_MEM.Rs2AddrM),
            .RdE(outID_EX.RdE),
            .RdM(outEX_MEM.RdM),
            .RdW(outMEM_WB.RdW),
            .ALUResultM(outEX_MEM.ALUResultM),
            .ALUResultW(outMEM_WB.ALUResultW),
            .memReadE(outID_EX.ControlFlags.MemRead),
            .memReadM(outEX_MEM.MemReadM),
            .memReadW(outMEM_WB.MemReadW),
            .branchTaken(takeBranch),
            .memWriteD(controlFlags.MemWrite),
            .memWriteM(outEX_MEM.MemWriteM),
            .memWriteW(outMEM_WB.MemWriteW),
            .regWriteM(outEX_MEM.RegWriteM),
            .regWriteW(outMEM_WB.RegWriteW),
            .forwardA(forwardMuxASel),
            .forwardB(forwardMuxBSel),
            .forwardWD(forwardWD),
            .forwardRD(forwardRD),
            .pcEnable(pcEnable),
            .IF_ID_Enable(IF_ID_Enable),
            .FlushD(flushIF_ID),
            .FlushE(flushID_EX)
            );
        
        //Forwarding Muxes for Operation -> STR
            always_comb begin
                case(forwardWD)
                    NO_FORWARD_WD: forwardWDOut = outEX_MEM.WriteDataM;
                    FORWARD_WD_WB: forwardWDOut = resultMuxOut;
                    default: forwardWDOut = outEX_MEM.WriteDataM;
                endcase
            end     
        
        //Forwarding Muxes for STR -> LD
            always_comb begin
                case(forwardRD)
                    NO_FORWARD_RD: forwardRDOut = read_data;
                    FORWARD_RD_WB: forwardRDOut = outMEM_WB.WriteDataW;
                    default: forwardRDOut = read_data;
                endcase
            end
    
endmodule


