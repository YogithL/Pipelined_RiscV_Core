
class rand_sequence extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(rand_sequence)

    function new(string name = "rand_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(100) begin
            req = base_stim_packet::type_id::create("req");

            start_item(req);
            
            if(!req.randomize()) begin
                `uvm_error("SEQ", "Randomization of base_stim_packet failed!")
            end
            
            finish_item(req);
        end
    endtask

endclass