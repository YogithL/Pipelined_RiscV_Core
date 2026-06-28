
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

                case(instrPacket.instr[6:0])
                    OP_Store, OP_Load: MemPacket = mem_fifo.get();
                    
                    OP_Branch, OP_JAL, OP_JALR: begin
                        PCPacket = pc_fifo.get();

                        while(PCPacket.pcMuxOut == 32'b0) 
                            PCPacket = pc_fifo.get(); 
                    end
                endcase

                
            end


        end
    endtask

endclass