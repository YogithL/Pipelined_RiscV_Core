/*
This implementation was  generated with AI assistance and has been
reviewed/modified by me to fit my UVM enviroment.
*/

#include <iostream>
#include <cstdint>
#include <unordered_map>

using namespace std;

// RISC-V opcodes
enum opcodes_e
{
    OP_Load = 0x03,
    OP_Imm = 0x13,
    OP_AUIPC = 0x17,
    OP_Store = 0x23,
    OP_Reg = 0x33,
    OP_LUI = 0x37,
    OP_Branch = 0x63,
    OP_JALR = 0x67,
    OP_JAL = 0x6F
};

// ALU operation codes
enum alu_opps_e
{
    ALU_ADD = 0x0,
    ALU_SLL = 0x1,
    ALU_SLT = 0x2,
    ALU_SLTU = 0x3,
    ALU_XOR = 0x4,
    ALU_SRL = 0x5,
    ALU_OR = 0x6,
    ALU_AND = 0x7,
    ALU_SUB = 0x8,
    ALU_SRA = 0xD
};

// Branch condition codes
enum branch_types_e
{
    BR_BEQ = 0x0,
    BR_BNE = 0x1,
    BR_BLT = 0x4,
    BR_BGE = 0x5,
    BR_BLTU = 0x6,
    BR_BGEU = 0x7
};

// Memory access widths
enum width_e
{
    BYTE_S = 0x0,
    HALF_S = 0x1,
    WORD = 0x2,
    BYTE_U = 0x4,
    HALF_U = 0x5
};

class GoldenProcessor
{
private:
    uint32_t regs[32];
    unordered_map<uint32_t, uint8_t> memory; // Byte-addressable sparse memory
    uint32_t current_pc;

    int32_t sign_extend(uint32_t val, int bits)
    {
        int32_t shift = 32 - bits;
        return (int32_t)(val << shift) >> shift;
    }

    // ALU operations
    uint32_t execute_alu(uint32_t op1, uint32_t op2, uint8_t alu_op)
    {
        uint32_t shamt = op2 & 0x1F;
        switch(alu_op)
        {
            case ALU_ADD: return op1 + op2;
            case ALU_SUB: return op1 - op2;
            case ALU_SLL: return op1 << shamt;
            case ALU_SLT: return ((int32_t)op1 < (int32_t)op2) ? 1 : 0;
            case ALU_SLTU: return (op1 < op2) ? 1 : 0;
            case ALU_XOR: return op1 ^ op2;
            case ALU_SRL: return op1 >> shamt;
            case ALU_SRA: return (int32_t)op1 >> shamt;
            case ALU_OR: return op1 | op2;
            case ALU_AND: return op1 & op2;
            default: return 0;
        }
    }

    // Branch evaluation
    bool evaluate_branch(uint32_t op1, uint32_t op2, uint8_t br_type)
    {
        switch(br_type)
        {
            case BR_BEQ: return op1 == op2;
            case BR_BNE: return op1 != op2;
            case BR_BLT: return (int32_t)op1 < (int32_t)op2;
            case BR_BGE: return (int32_t)op1 >= (int32_t)op2;
            case BR_BLTU: return op1 < op2;
            case BR_BGEU: return op1 >= op2;
            default: return false;
        }
    }

public:
    GoldenProcessor()
    {
        reset();
    }

    void reset()
    {
        for(int i = 0; i < 32; i++)
        {
            regs[i] = 0;
        }
        memory.clear();
        current_pc = 0;
    }

    uint32_t read_reg(uint8_t idx)
    {
        return (idx == 0) ? 0 : regs[idx];
    }

    void write_reg(uint8_t idx, uint32_t val)
    {
        if(idx != 0)
        {
            regs[idx] = val;
        }
    }

    // ==========================================
    // ADDED: Method to force the current PC
    // ==========================================
    void set_pc(uint32_t pc)
    {
        current_pc = pc;
    }

    uint32_t read_pc()
    {
        return current_pc;
    }

    // Multi-byte memory read based on width_e
    uint32_t read_mem(uint32_t addr, uint8_t width)
    {
        uint32_t val = 0;
        val |= memory[addr];
        
        if(width != BYTE_S && width != BYTE_U)
        {
            val |= (memory[addr + 1] << 8);
        }
        
        if(width == WORD)
        {
            val |= (memory[addr + 2] << 16);
            val |= (memory[addr + 3] << 24);
        }
        
        // Handle sign extension for loads
        if(width == BYTE_S)
        {
            return sign_extend(val, 8);
        }
        
        if(width == HALF_S)
        {
            return sign_extend(val, 16);
        }
        
        return val;
    }

    // Multi-byte memory write based on width_e
    void write_mem(uint32_t addr, uint32_t val, uint8_t width)
    {
        memory[addr] = val & 0xFF;
        
        if(width == HALF_S || width == HALF_U || width == WORD)
        {
            memory[addr + 1] = (val >> 8) & 0xFF;
        }
        
        if(width == WORD)
        {
            memory[addr + 2] = (val >> 16) & 0xFF;
            memory[addr + 3] = (val >> 24) & 0xFF;
        }
    }

    void step_instruction(uint32_t instr)
    {
        // ========================================================
        // FIXED: Use the actual injected PC, and calculate next_pc
        // ========================================================
        uint32_t original_pc = current_pc; 
        uint32_t next_pc = original_pc + 4; // Default to PC+4

        uint8_t opcode = instr & 0x7F;
        uint8_t rd = (instr >> 7) & 0x1F;
        uint8_t funct3 = (instr >> 12) & 0x7;
        uint8_t rs1 = (instr >> 15) & 0x1F;
        uint8_t rs2 = (instr >> 20) & 0x1F;
        uint8_t funct7 = (instr >> 25) & 0x7F;

        // Extract and construct immediates
        int32_t imm_i = (int32_t)instr >> 20;
        int32_t imm_s = sign_extend(((funct7 << 5) | rd), 12);
		int32_t imm_b = sign_extend(((funct7 >> 6) << 12) | ((rd & 1) << 11) | ((funct7 & 0x3F) << 5) | (rd & 0x1E), 13);
      int32_t imm_u = instr & 0xFFFFF000;
        int32_t imm_j = sign_extend(((instr >> 31) << 20) | ((instr >> 12) & 0xFF) << 12 | ((instr >> 20) & 0x1) << 11 | ((instr >> 21) & 0x3FF) << 1, 21);

        uint32_t rs1_val = read_reg(rs1);
        uint32_t rs2_val = read_reg(rs2);

        switch(opcode)
        {
            case OP_Reg:
            {
                uint8_t alu_op = ((funct7 & 0x20) >> 2) | funct3; // Maps perfectly to alu_opps_e
                write_reg(rd, execute_alu(rs1_val, rs2_val, alu_op));
                break;
            }
        
            case OP_Imm:
            {
                // For shifts, funct7 bit 5 determines logical vs arithmetic. Otherwise, bit 30 is 0.
                uint8_t alu_op = (funct3 == 0x1 || funct3 == 0x5) ? (((funct7 & 0x20) >> 2) | funct3) : funct3;
                write_reg(rd, execute_alu(rs1_val, imm_i, alu_op));
                break;
            }
        
            case OP_LUI:
                write_reg(rd, imm_u);
            break;
            
            case OP_AUIPC:
                write_reg(rd, original_pc + imm_u); // FIXED: Math from real PC
            break;
            
            case OP_Load:
                write_reg(rd, read_mem(rs1_val + imm_i, funct3));
            break;
        
            case OP_Store:
                write_mem(rs1_val + imm_s, rs2_val, funct3);
            break;
    
            case OP_Branch:
                if(evaluate_branch(rs1_val, rs2_val, funct3))
                {
                    next_pc = original_pc + imm_b; // FIXED: Math from real PC
                }
            break;
            
            case OP_JAL:
                write_reg(rd, original_pc + 4); // FIXED: Save real PC+4
                next_pc = original_pc + imm_j;  // FIXED: Jump from real PC
            break;
        
            case OP_JALR:
                write_reg(rd, original_pc + 4); // FIXED: Save real PC+4
                next_pc = (rs1_val + imm_i) & ~1; 
            break;
        }

        // Expose the final target address to the UVM Scoreboard
        current_pc = next_pc; 
    }
};

// DPI-C interface
static GoldenProcessor* cpu_model = nullptr;

extern "C"
{
    void golden_init()
    {
        if(!cpu_model)
        {
            cpu_model = new GoldenProcessor();
        }
        else
        {
            cpu_model->reset();
        }
    }

    // ==========================================
    // ADDED: DPI-C function to set the PC
    // ==========================================
    void golden_set_pc(int pc)
    {
        if(cpu_model)
        {
            cpu_model->set_pc((uint32_t)pc);
        }
    }

    void golden_step(int instr)
    {
        if(cpu_model)
        {
            cpu_model->step_instruction((uint32_t)instr);
        }
    }

    int golden_get_reg(int reg_idx)
    {
        return cpu_model ? (int)cpu_model->read_reg((uint8_t)reg_idx) : 0;
    }

    void golden_write_reg(int reg_idx, int val)
    {
        if(cpu_model)
        {
            cpu_model->write_reg((uint8_t)reg_idx, (uint32_t)val);
        }
    }

    int golden_get_pc()
    {
        return cpu_model ? (int)cpu_model->read_pc() : 0;
    }

    void golden_write_mem(int addr, int data, int width_enum)
    {
        if(cpu_model)
        {
            cpu_model->write_mem((uint32_t)addr, (uint32_t)data, (uint8_t)width_enum);
        }
    }

    int golden_read_mem(int addr, int width_enum)
    {
        return cpu_model ? (int)cpu_model->read_mem((uint32_t)addr, (uint8_t)width_enum) : 0;
    }
}