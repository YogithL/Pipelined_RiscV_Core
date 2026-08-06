class data_hazard_sequence extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(data_hazard_sequence)

    function new(string name = "data_hazard_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(100) begin
            data_hazard_producer_packet producer;
            base_stim_packet consumer;

            producer = data_hazard_producer_packet::type_id::create("producer");

            start_item(producer);
                if(!producer.randomize()) begin
                    `uvm_error("SEQ", "Randomization of data_hazard_producer_packet failed!")
                end
            finish_item(producer);

            consumer = base_stim_packet::type_id::create("consumer");

            start_item(consumer);
                if(!consumer.randomize() with {rs1 == producer.rd || rs2 == producer.rd;}) begin
                    `uvm_error("SEQ", "Randomization of base_stim_packet failed!")
                end
            finish_item(consumer);
      end
        endtask

endclass