
class instr_monitor extends uvm_monitor;
    `uvm_component_utils(instr_monitor)

    virtual instr_bfm instr_vif;
    uvm_analysis_port#(base_stim_packet) ap_instr;

    function new(string name = "instr_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual instr_bfm)::get(this, "", "instr_vif", instr_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");

        ap_instr = new("ap_instr", this);
    endfunction

    task run_phase(uvm_phase phase);
        base_stim_packet packet;

        forever begin
            packet = base_stim_packet::type_id::create("packet");
            instr_vif.sampleInstr(packet.instr);
            
            packet.decode_instr();
            
            ap_instr.write(packet);
        end

    endtask

endclass