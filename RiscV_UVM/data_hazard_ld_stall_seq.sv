
class data_hazard_ld_stall_seq extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(data_hazard_ld_stall_seq)

    function new(string name = "data_hazard_ld_stall_seq");
        super.new(name);
    endfunction

    virtual task body();
        base_stim_packet load_instr = base_stim_packet::type_id::create("load_instr");
        base_stim_packet consumer = base_stim_packet::type_id::create("consumer");

        start_item(load_instr);
            if(!load_instr.randomize() with {opcode == OP_Load;})
                `uvm_error("SEQ", "Randomization of producer failed!");
        finish_item(load_instr);
        
        start_item(consumer);
            if(!consumer.randomize() with {(opcode != OP_Store) && (rs1 == load_instr.rd || rs2 == load_instr.rd);})
                `uvm_error("SEQ", "Randomization of consumer failed!");
        finish_item(consumer);
    endtask
    
endclass