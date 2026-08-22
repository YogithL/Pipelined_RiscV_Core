
class data_hazard_d1_seq extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(data_hazard_d1_seq)

    function new(string name = "data_hazard_d1_seq");
        super.new(name);
    endfunction

    virtual task body();
        base_stim_packet producer = base_stim_packet::type_id::create("producer");
        base_stim_packet consumer = base_stim_packet::type_id::create("consumer");

        start_item(producer);
            if(!producer.randomize() with { !(opcode inside {OP_Store, OP_Branch, OP_Load}); })
                `uvm_error("SEQ", "Randomization of producer failed!");
        finish_item(producer);

        start_item(consumer);
            if(!consumer.randomize() with { rs1 == producer.rd || rs2 == producer.rd; })
                `uvm_error("SEQ", "Randomization of consumer failed!");
        finish_item(consumer);
    endtask
    
endclass