
class mem_agent extends uvm_agent;
    `uvm_component_utils(mem_agent)

    uvm_analysis_port#(mem_packet) ap_mem;
    mem_driver memDriver;
    mem_monitor memMonitor;

    function new(string name = "mem_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_mem = new("ap_mem", this);
        memDriver = mem_driver::type_id::create("memDriver", this);
        memMonitor = mem_monitor::type_id::create("memMonitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        memMonitor.ap_mem.connect(ap_mem);
    endfunction

endclass