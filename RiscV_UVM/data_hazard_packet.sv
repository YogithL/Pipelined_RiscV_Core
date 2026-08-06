class data_hazard_producer_packet extends base_stim_packet;

    `uvm_object_utils(data_hazard_producer_packet)

    function new(string name = "data_hazard_producer_packet ");
        super.new(name);
    endfunction

    constraint producer_opcodes
    {
        !(opcode inside {OP_Store, OP_Branch});
    }

endclass 


