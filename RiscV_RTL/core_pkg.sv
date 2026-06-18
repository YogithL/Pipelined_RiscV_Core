package riscV_pkg;

typedef enum logic[1:0]
{
    REGA = 2'b00,
    PC = 2'b01,
    ZERO = 2'b10  
} alusrcA_e;

typedef enum logic
{
    IMM  = 1'b0,
    REGB = 1'b1  
} alusrcB_e;

typedef enum logic[1:0]
{
    BRANCH = 2'b00, 
    PCPLUS4 = 2'b01,
    JUMP = 2'b10
} pc_sel_e;

typedef enum logic[1:0]
{
    NO_FORWARD_A = 2'b00, 
    FORWARD_MEM_A = 2'b01, 
    FORWARD_WB_A = 2'b10
} forward_selA_e;

typedef enum logic[1:0]
{
    NO_FORWARD_B = 2'b00, 
    FORWARD_MEM_B = 2'b01, 
    FORWARD_WB_B = 2'b10
} forward_selB_e;

typedef enum logic
{
    NO_FORWARD_WD = 1'b0, 
    FORWARD_WD_WB = 1'b1 
} forward_ld_str_e;

//For when a store occurs, then we need to load from there
typedef enum logic
{
    NO_FORWARD_RD = 1'b0, 
    FORWARD_RD_WB = 1'b1 
} forward_str_ld_e;


typedef enum logic[1:0]
{
    MEM = 2'b00,
    ALU =  2'b01,
    PC4 = 2'b10
} resultsrc_e;

typedef enum logic[3:0]      
{                            
    //MSB appended with bit30
    // Arithmetic            
    ALU_ADD = 4'b0000,       
    ALU_SUB = 4'b1000,       
                             
    // Logical               
    ALU_OR = 4'b0110,        
    ALU_AND = 4'b0111,       
    ALU_XOR = 4'b0100,       
                             
    // Shifts                
    ALU_SRL = 4'b0101,       
    ALU_SRA = 4'b1101,       
    ALU_SLL = 4'b0001,       
                         
    // Branch Focused
    ALU_SLT = 4'b0010,     
    ALU_SLTU = 4'b0011
} alu_opps_e;

typedef enum logic[2:0]
{
    BR_BEQ = 3'b000, //Branch if equal                          
    BR_BNE = 3'b001, //Branch if not equal                      
    BR_BLT = 3'b100, //Branch if less than (Signed)             
    BR_BGE = 3'b101, //Branch if greater or equal (Signed)      
    BR_BLTU = 3'b110, //Branch if less than (Unsigned)           
    BR_BGEU = 3'b111  //Branch if greater or equal (Unsigned)    
} branch_types_e;

typedef enum logic[6:0]
{
    //R-Type (1)              
    OP_Reg = 7'b0110011,       
                           
    //I-Type (2)              
    OP_Imm = 7'b0010011,                
    //I-Type (2)              
    OP_Load = 7'b0000011,   
    //I-Type (2)              
    OP_JALR = 7'b1100111,      
                           
    //S-Type (3)              
    OP_Store = 7'b0100011,     
                           
    //B-Type (4)              
    OP_Branch = 7'b1100011,     
                           
    //U-Type (5)              
    OP_LUI = 7'b0110111,                    
    //U-Type (5)              
    OP_AUIPC = 7'b0010111,     
                           
    //J-Type (6)              
    OP_JAL = 7'b1101111        
} opcodes_e;    

typedef enum logic [2:0]
{
    IMM_I = 3'b000,
    IMM_S = 3'b001,
    IMM_B = 3'b010,
    IMM_J = 3'b011,
    IMM_U = 3'b100 
} immsrc_e;

typedef enum logic[2:0]
{
    BYTE_S = 3'b000, 
    HALF_S = 3'b001, 
    WORD = 3'b010, 
    BYTE_U = 3'b100,
    HALF_U = 3'b101
} width_e;

typedef struct packed
{
    
    logic RegWrite;
    logic[3:0] MemWrite;
    logic MemRead;
    alusrcA_e ALUSrcA;
    alusrcB_e ALUSrcB;
    resultsrc_e ResultSrc;
    alu_opps_e ALUControl;
    logic Jump;
    logic Branch;
    branch_types_e BranchType;
    width_e Size;
} ctrlunit_flags_s;

typedef struct packed
{
    //Data
    logic[31:0] instr;
    logic[31:0] PCD;
    logic[31:0] PCPlus4D;
} p_if_id_s;

typedef struct packed
{
    //Data
    logic[31:0] Rs1E;
    logic[31:0] Rs2E;
    
    //Need for Hazard
    logic[4:0] Rs1AddrE;
    logic[4:0] Rs2AddrE;
        
    logic[4:0] RdE;
    logic[31:0] PCE;
    logic[31:0] PCPlus4E;
    logic[31:0] ImmE;
    
    //Control Flags
    ctrlunit_flags_s ControlFlags;
} p_id_ex_s;

typedef struct packed
{
    //Data
    logic[4:0] RdM;
    logic[31:0] PCPlus4M;
    logic[31:0] ALUResultM;
    logic[31:0] WriteDataM;
    
    //Need for Hazard
    logic[4:0] Rs2AddrM;
        
    //Control Flags
    logic RegWriteM;
    logic MemReadM;
    logic[3:0] MemWriteM;
    resultsrc_e ResultSrcM;
    width_e SizeM;
} p_ex_mem_s;

typedef struct packed
{
    //Data
    logic[4:0] RdW;
    logic[31:0] PCPlus4W;
    logic[31:0] ALUResultW;
    logic[31:0] ReadDataW;
    
    //Need for Hazard
    logic MemReadW;
    logic[3:0] MemWriteW;
    logic[31:0] WriteDataW;
    
    //Control Flags
    logic RegWriteW;
    resultsrc_e ResultSrcW;
} p_mem_wb_s;

endpackage: riscV_pkg







