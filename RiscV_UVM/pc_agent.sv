
class pc_agent extends uvm_agent;
    `uvm_component_utils(pc_agent)

    uvm_analysis_port#(pc_packet) ap_pc;
    pc_monitor pcMonitor;

    function new(string name = "pc_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_pc = new("ap_pc", this);
        pcMonitor = pc_monitor::type_id::create("pcMonitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        pcMonitor.ap_pc.connect(ap_pc);
    endfunction

endclass