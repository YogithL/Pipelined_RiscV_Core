
class sequencer extends uvm_sequencer#(base_stim_packet);
    `uvm_component_utils(sequencer)

    function new(string name = "sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass


