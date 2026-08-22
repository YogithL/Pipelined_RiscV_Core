
class hazard_seq_library extends uvm_sequence_library#(base_stim_packet);
    `uvm_object_utils(hazard_seq_library)
    `uvm_sequence_library_utils(hazard_seq_library)

    function new(string name = "hazard_seq_library");
        super.new(name);
        init_sequence_library();
    endfunction
endclass