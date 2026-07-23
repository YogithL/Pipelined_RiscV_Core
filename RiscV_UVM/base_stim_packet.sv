
class base_stim_packet extends uvm_sequence_item;
    `uvm_object_utils(base_stim_packet)

    function new(string name = "base_stim_packet");
        super.new(name);
    endfunction

    rand opcodes_e opcode;
    rand bit[4:0] rd;
    rand bit[2:0] funct3;
        rand alu_opps_e alu_opps_f3;
        rand width_e mem_widths_f3;
        rand branch_types_e branch_types_f3;
    rand bit[4:0] rs1;
    rand bit[4:0] rs2;
    rand bit[6:0] funct7;
    rand bit[31:0] imm;

    bit[31:0] instr;

    constraint instr_format
    {
        (opcode == OP_Reg) -> (imm == 0);

        (opcode == OP_Imm || opcode == OP_Load || opcode == OP_JALR) 
        -> (funct7 == 0 && rs2 == 0);

        (opcode == OP_Store || opcode == OP_Branch) -> (funct7 == 0 && rd == 0);

        (opcode == OP_LUI || opcode == OP_AUIPC || opcode == OP_JAL) 
        -> (funct3 == 0 && rs1 == 0 && rs2 == 0 && funct7 == 0);
    }

    constraint funct3_format
    {
        (opcode == OP_Reg || opcode == OP_Imm) -> (funct3 == alu_opps_f3);

        (opcode == OP_Branch) -> (funct3 == branch_types_f3);

        (opcode == OP_Load || opcode == OP_Store) -> (funct3 == mem_widths_f3);
    }

    function bit[31:0] instr_gen();
        bit[6:0] raw_opcode = opcode;
        bit[6:0] actual_f7;

        if(opcode == OP_Reg)
            actual_f7 = alu_opps_f3[3] ? 7'b0100000 : 7'b0000000;
        else
            actual_f7 = 7'b0000000; 

        case(opcode)
            // R-Type
            OP_Reg: 
                instr = {actual_f7, rs2, rs1, funct3, rd, raw_opcode};

            // I-Type
            OP_Imm, OP_Load, OP_JALR: 
                instr = {imm[11:0], rs1, funct3, rd, raw_opcode};

            // S-Type
            OP_Store: 
                instr = {imm[11:5], rs2, rs1, funct3, imm[4:0], raw_opcode};

            // B-Type
            OP_Branch: 
                instr = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], raw_opcode};

            // U-Type
            OP_LUI, OP_AUIPC: 
                instr = {imm[31:12], rd, raw_opcode}; 

            // J-Type
            OP_JAL: 
                instr = {imm[20], imm[10:1], imm[11], imm[19:12], rd, raw_opcode};

            default: 
                instr = 32'h00000013; 
        endcase

        return instr;
    endfunction

    virtual function string convert2string();
        case(opcode)
            OP_Reg: 
                return $sformatf("%s x%0d, x%0d, x%0d \t\t[Raw: 32'h%08x]", 
                                 alu_opps_f3.name(), rd, rs1, rs2, instr);
            
            OP_Imm:
                return $sformatf("%s x%0d, x%0d, 12'h%0x \t[Raw: 32'h%08x]", 
                                 alu_opps_f3.name(), rd, rs1, imm[11:0], instr);
            
            OP_Load:
                return $sformatf("%s x%0d, x%0d, 12'h%0x \t[Raw: 32'h%08x]", 
                                 mem_widths_f3.name(), rd, rs1, imm[11:0], instr);
            
            OP_JALR:
                return $sformatf("%s x%0d, x%0d, 12'h%0x \t[Raw: 32'h%08x]", 
                                 opcode.name(), rd, rs1, imm[11:0], instr);
            
            OP_Store:
                return $sformatf("%s x%0d, 12'h%0x(x%0d) \t[Raw: 32'h%08x]", 
                                 mem_widths_f3.name(), rs2, imm[11:0], rs1, instr);
            
            OP_Branch:
                return $sformatf("%s x%0d, x%0d, 13'h%0x \t[Raw: 32'h%08x]", 
                                 branch_types_f3.name(), rs1, rs2, imm[12:0], instr);
            
            OP_LUI, OP_AUIPC:
                return $sformatf("%s x%0d, 20'h%0x \t\t[Raw: 32'h%08x]", 
                                 opcode.name(), rd, imm[31:12], instr);
            
            OP_JAL:
                return $sformatf("%s x%0d, 21'h%0x \t\t[Raw: 32'h%08x]", 
                                 opcode.name(), rd, imm[20:0], instr);
            
            default:
                return $sformatf("UNKNOWN_INSTR \t\t\t[Raw: 32'h%08x]", instr);
        endcase
    endfunction

    function void decode_instr();
        opcode = opcodes_e'(instr[6:0]);
        
        rd = instr[11:7];
        funct3 = instr[14:12];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct7 = instr[31:25];
        
        alu_opps_f3 = alu_opps_e'(funct3);
        mem_widths_f3 = width_e'(funct3);
        branch_types_f3 = branch_types_e'(funct3);
        
        case(opcode)
            OP_Imm, OP_Load, OP_JALR: 
                imm = { {20{instr[31]}}, instr[31:20] };

            OP_Store: 
                imm = { {20{instr[31]}}, instr[31:25], instr[11:7] };

            OP_Branch: 
                imm = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

            OP_LUI, OP_AUIPC: 
                imm = { instr[31:12], 12'b0 };

            OP_JAL: 
                imm = { {11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 };

            OP_Reg: 
                imm = 32'b0;

            default: 
                imm = 32'b0;
        endcase
    endfunction
    
endclass





