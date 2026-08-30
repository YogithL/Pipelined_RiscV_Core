class coverages extends uvm_subscriber#(base_stim_packet);
    `uvm_component_utils(coverages)

    base_stim_packet pkt;

    covergroup instr_cg;
        cp_opcode: coverpoint pkt.opcode
        {
            bins reg_op = {OP_Reg};
            bins imm_op = {OP_Imm};
            bins load_op = {OP_Load};
            bins store_op = {OP_Store};
            bins branch_op = {OP_Branch};
            bins lui_op = {OP_LUI};
            bins auipc_op = {OP_AUIPC};
            bins jal_op = {OP_JAL};
            bins jalr_op = {OP_JALR};
        }

        cp_alu_op: coverpoint pkt.alu_opps_f3 iff (pkt.opcode == OP_Reg || pkt.opcode == OP_Imm)
        {
            bins ops[] = {ALU_ADD, ALU_SUB, ALU_OR, ALU_AND, ALU_XOR, ALU_SRL, ALU_SRA, ALU_SLL, ALU_SLT, ALU_SLTU};
        }

        cp_branch_type: coverpoint pkt.branch_types_f3 iff (pkt.opcode == OP_Branch)
        {
            bins types[] = {BR_BEQ, BR_BNE, BR_BLT, BR_BGE, BR_BLTU, BR_BGEU};
        }

        cp_mem_width: coverpoint pkt.mem_widths_f3 iff (pkt.opcode == OP_Load || pkt.opcode == OP_Store) 
        {
            bins byte_s = {BYTE_S};
            bins half_s = {HALF_S};
            bins word = {WORD};
            bins byte_u = {BYTE_U};
            bins half_u = {HALF_U};
        }

        cp_rd_zero: coverpoint (pkt.rd == 5'd0)
        {
            bins is_zero = {1};
            bins is_nonzero = {0};
        }

        cp_rs1_zero: coverpoint (pkt.rs1 == 5'd0)
        {
            bins is_zero = {1};
            bins is_nonzero = {0};
        }

        cp_rs2_zero: coverpoint (pkt.rs2 == 5'd0)
        {
            bins is_zero = {1};
            bins is_nonzero = {0};
        }

    endgroup

    function new(string name = "coverages", uvm_component parent);
        super.new(name, parent);
        instr_cg = new();
    endfunction

    virtual function void write(base_stim_packet t);
        pkt = t;
        instr_cg.sample();
    endfunction
endclass