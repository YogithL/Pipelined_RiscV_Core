
class mem_hazard_str_ld_seq extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(mem_hazard_str_ld_seq)

    function new(string name = "mem_hazard_str_ld_seq");
        super.new(name);
    endfunction

    virtual task body();
        base_stim_packet store_instr = base_stim_packet::type_id::create("store_instr");
        base_stim_packet load_instr = base_stim_packet::type_id::create("load_instr");

        start_item(store_instr);
            if(!store_instr.randomize() with {opcode == OP_Store;})
                `uvm_error("SEQ", "Randomization of producer failed!");
        finish_item(store_instr);
        
        start_item(load_instr);
            if(!load_instr.randomize() with 
                {
                    opcode == OP_Load;
                    rs1 == store_instr.rs1;
                    imm == store_instr.imm;
                }
            )
                `uvm_error("SEQ", "Randomization of consumer failed!");
        finish_item(load_instr);
    endtask
    
endclass