
class instr_driver extends uvm_driver;
    `uvm_component_utils(instr_driver)

    virtual instr_bfm instr_vif;

    function new(string name = "instr_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        base_stim_packet packet;

        forever begin
            seq_item_port.get_next_item(packet);

            packet.instr_gen();
            instr_vif.sendInstr(packet.instr);
            
            seq_item_port.item_done();
        end
    endtask

endclass