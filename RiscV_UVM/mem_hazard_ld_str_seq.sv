
class mem_hazard_ld_str_seq extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(mem_hazard_ld_str_seq)

    function new(string name = "mem_hazard_ld_str_seq");
        super.new(name);
    endfunction

    virtual task body();
        base_stim_packet load_instr = base_stim_packet::type_id::create("load_instr");
        base_stim_packet store_instr = base_stim_packet::type_id::create("store_instr");

        start_item(load_instr);
            if(!load_instr.randomize() with {opcode == OP_Load;})
                `uvm_error("SEQ", "Randomization of producer failed!");
        finish_item(load_instr);
        
        start_item(store_instr);
            if(!store_instr.randomize() with {(opcode == OP_Store) && (rs2 == load_instr.rd || rs1 == load_instr.rd);})
                `uvm_error("SEQ", "Randomization of consumer failed!");
        finish_item(store_instr);
    endtask
    
endclass