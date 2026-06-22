
class instr_driver extends uvm_driver;
    `uvm_component_utils(instr_driver)

    virtual instr_bfm instr_vif;
    uvm_analysis_port#(base_stim_packet) ap_instr;

    function new(string name = "instr_driver", uvm_component parent);
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
            seq_item_port.get_next_item(packet);

            packet.instr_gen();
            instr_vif.sendInstr(packet.instr);
            
            ap_instr.write(packet);

            seq_item_port.item_done();
        end
    endtask

endclass