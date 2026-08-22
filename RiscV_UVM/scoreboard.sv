class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo#(base_stim_packet) instr_fifo;
    uvm_analysis_export#(base_stim_packet) instr_export;

    uvm_tlm_analysis_fifo#(mem_packet) mem_fifo;
    uvm_analysis_export#(mem_packet) mem_export;

    uvm_tlm_analysis_fifo#(pc_packet) pc_fifo;
    uvm_analysis_export#(pc_packet) pc_export;

    uvm_tlm_analysis_fifo#(reg_packet) reg_fifo;
    uvm_analysis_export#(reg_packet) reg_export;    

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        golden_init();
        
        instr_export = new("instr_export", this);
        mem_export = new("mem_export", this);
        pc_export = new("pc_export", this);
        reg_export = new("reg_export", this);

        instr_fifo = new("instr_fifo", this);
        mem_fifo = new("mem_fifo", this);
        pc_fifo = new("pc_fifo", this);
        reg_fifo = new("reg_fifo", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        instr_export.connect(instr_fifo.analysis_export);
        mem_export.connect(mem_fifo.analysis_export);
        pc_export.connect(pc_fifo.analysis_export);
        reg_export.connect(reg_fifo.analysis_export);
    endfunction
    
    task run_phase(uvm_phase phase);
        base_stim_packet instrPacket;
        pc_packet PCPacket;
        mem_packet MemPacket;
        reg_packet RegPacket;

        opcodes_e opcode;
        width_e mem_width;
        logic [31:0] expected_pc_pre;
        int expected_data_reg;
        int expected_data_mem;
        int expected_pc;

        forever begin
            reg_fifo.get(RegPacket);

            if(RegPacket.retire_valid == 1'b1) begin
                instr_fifo.get(instrPacket);
                pc_fifo.get(PCPacket);

                //Checks if the correct instruction was grabbed, relative to prior instruction
                expected_pc_pre = golden_get_pc();

                if(instrPacket.current_pc == expected_pc_pre)
                    `uvm_info("PC_PRECHECK_PASS", $sformatf("PC MATCH | Expected: 0x%08h | Actual: 0x%08h",
                        expected_pc_pre, instrPacket.current_pc), UVM_HIGH)
                else begin
                    `uvm_error("PC_PRECHECK_PASS", $sformatf("PC MISMATCH! Expected: 0x%08h | Actual (RTL): 0x%08h",
                        expected_pc_pre, instrPacket.current_pc))
                    golden_set_pc(instrPacket.current_pc);
                end

                golden_step(instrPacket.instr);

                //Grabbing relevant data prior to comparison
                opcode = opcodes_e'(instrPacket.instr[6:0]);
                mem_width = width_e'(instrPacket.instr[14:12]);
                expected_data_reg = golden_get_reg(RegPacket.rd_addr);
                expected_pc = golden_get_pc();

                case(opcode)
                    OP_Store, OP_Load: begin
                        mem_fifo.get(MemPacket);
                        expected_data_mem = golden_read_mem(MemPacket.write_addr, mem_width);
                    end
                endcase

                //Comparison
                case(opcode)
                    OP_Reg, OP_Imm, OP_Load, OP_LUI, OP_AUIPC: begin
                        if(RegPacket.rd_data == expected_data_reg)
                            `uvm_info(
                                "REG_PASS",
                                $sformatf(
                                    "[%s] MATCH | rd: x%0d | data: 0x%08h\n\tPacket: %s", 
                                    opcode.name(), 
                                    RegPacket.rd_addr, 
                                    RegPacket.rd_data, 
                                    RegPacket.convert2string()
                                ), 
                                UVM_HIGH 
                            )
                        else begin
                            `uvm_error(
                                "REG_FAIL",
                                $sformatf("[%s] MISMATCH! rd: x%0d | Expected: 0x%08h | Actual (RTL): 0x%08h\n\tPacket: %s", 
                                    opcode.name(), 
                                    RegPacket.rd_addr, 
                                    expected_data_reg, 
                                    RegPacket.rd_data, 
                                    RegPacket.convert2string()
                                )
                            )       
                            golden_write_reg(RegPacket.rd_addr, RegPacket.rd_data);
                        end
                    end

                    OP_Store: begin
                        if(MemPacket.write_data == expected_data_mem)
                            `uvm_info(
                                "MEM_PASS", 
                                $sformatf("[%s] MATCH | Addr: 0x%08h | Data: 0x%08h | Width: %s\n\tPacket: %s", 
                                    opcode.name(),
                                    MemPacket.write_addr,
                                    MemPacket.write_data,
                                    mem_width.name(),
                                    MemPacket.convert2string()
                                ), 
                                UVM_HIGH
                            )
                        else begin
                            `uvm_error(
                                "MEM_FAIL", 
                                $sformatf("[%s] MISMATCH! Addr: 0x%08h | Expected Data: 0x%08h | Actual RTL Data: 0x%08h\n\tPacket: %s", 
                                    opcode.name(),
                                    MemPacket.write_addr,
                                    expected_data_mem,
                                    MemPacket.write_data,
                                    MemPacket.convert2string()
                                )
                            )
                            golden_write_mem(MemPacket.write_addr, MemPacket.write_data, mem_width);
                        end
                    end

                    OP_Branch, OP_JAL, OP_JALR: begin
                        if(opcode == OP_Branch && !PCPacket.branchTaken) begin
                        end
                        else begin
                            if(PCPacket.pcMuxOut == expected_pc)
                                `uvm_info(
                                    "PC_PASS",
                                    $sformatf("[%s] MATCH | Target PC: 0x%08h\n\tPacket: %s",
                                        opcode.name(), PCPacket.pcMuxOut, PCPacket.convert2string()
                                    ),
                                    UVM_HIGH
                                )
                            else begin
                                `uvm_error(
                                    "PC_FAIL",
                                    $sformatf("[%s] MISMATCH! Expected Target PC: 0x%08h | Actual RTL PC: 0x%08h\n\tPacket: %s",
                                        opcode.name(), expected_pc, PCPacket.pcMuxOut, PCPacket.convert2string()
                                    )
                                )
                            end
                        end
                    end
                endcase
            end
        end
    endtask
endclass