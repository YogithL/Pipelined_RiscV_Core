
class reg_agent extends uvm_agent;
    `uvm_component_utils(reg_agent)

    uvm_analysis_port#(reg_packet) ap_reg;
    reg_monitor regMonitor;

    function new(string name = "reg_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_reg = new("ap_reg", this);
        regMonitor = reg_monitor::type_id::create("regMonitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        regMonitor.ap_reg.connect(ap_reg);
    endfunction

endclass