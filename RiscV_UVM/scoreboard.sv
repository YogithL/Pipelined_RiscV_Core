
class scoreboard extends uvm_scoreboard;
    import riscV_pkg::*;
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

        forever begin
            RegPacket = reg_fifo.get();

            if(RegPacket.retire_valid == 1'b1) begin
                instrPacket = instr_fifo.get();
                golden_step(instrPacket.instr);

                opcodes_e opcode = opcodes_e'(instrPacket.instr[6:0]);
                int expected_data_reg = golden_get_reg(RegPacket.rd_addr);
                width_e mem_width = width_e'(instrPacket.instr[14:12]);
                int expected_data_mem = golden_read_mem(MemPacket.write_addr, mem_width);
                int expected_pc = golden_get_pc();

                case(opcode) 
                    OP_Store, OP_Load: MemPacket = mem_fifo.get();
                    
                    OP_Branch, OP_JAL, OP_JALR: begin
                        PCPacket = pc_fifo.get();

                        while(PCPacket.pcMuxOut == 32'b0 || PCPacket.pcMuxOut == 32'd4) 
                            PCPacket = pc_fifo.get();                        
                    end
                endcase
                
                case(opcode)
                    OP_Reg, OP_Imm, OP_Load, OP_LUI, OP_AUIPC: begin
                        if(RegPacket.rd_data == expected_data_reg)
                            `uvm_info(
                                "REG_PASS",
                                $sformatf(
                                    "[%s] MATCH | rd: x%0d | data: 0x%08h | Packet: %s", 
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
                                        MemPacket.addr,
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
                                    MemPacket.addr,
                                    expected_data_mem,
                                    MemPacket.write_data,
                                    MemPacket.convert2string()
                                )
                            )

                            golden_write_mem(MemPacket.addr, MemPacket.write_data, mem_width);
                            
                        end
                    end

                    OP_Branch, OP_JAL, OP_JALR: begin
                        if(PCPacket.pcMuxOut == expected_pc)
                            `uvm_info(
                                "BRANCH_PASS", 
                                $sformatf("[%s] MATCH | Target PC: 0x%08h\n\tPacket: %s", 
                                    opcode.name(),
                                    PCPacket.pcMuxOut,
                                    instrPacket.convert2string()
                                ), 
                                UVM_HIGH
                            )
                        
                        else begin
                            `uvm_error(
                                "BRANCH_FAIL", 
                                $sformatf("[%s] MISMATCH! Expected Target PC: 0x%08h | Actual RTL PC: 0x%08h\n\tPacket: %s", 
                                    opcode.name(),
                                    expected_pc,
                                    PCPacket.pcMuxOut,
                                    instrPacket.convert2string()
                                )
                            )
                        end
                    end
                endcase
                
            end
        end
    endtask
endclass