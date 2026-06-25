
class instr_agent extends uvm_agent;
    `uvm_component_utils(instr_agent)

    uvm_analysis_port#(base_stim_packet) ap_instr;
    instr_driver instrDriver;
    instr_monitor instrMonitor;
    sequencer instrSequencer;

    function new(string name = "instr_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_instr = new("ap_instr", this);
        instrMonitor = instr_monitor::type_id::create("instrMonitor", this);
        instrDriver = instr_driver::type_id::create("instrDriver", this);
        instrSequencer = sequencer::type_id::create("instrSequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        instrMonitor.ap_instr.connect(ap_instr);
        instrDriver.seq_item_port.connect(instrSequencer.seq_item_export);
    endfunction

endclass