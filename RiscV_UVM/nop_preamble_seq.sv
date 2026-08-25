
class nop_preamble_seq extends uvm_sequence#(base_stim_packet);
    `uvm_object_utils(nop_preamble_seq)

    int num_nops = 20;

    function new(string name = "nop_preamble_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat(num_nops) begin
            base_stim_packet nop;
            nop = base_stim_packet::type_id::create("nop");
            start_item(nop);
                if(!nop.randomize() with {
                    opcode == OP_Imm;
                    alu_opps_f3 == ALU_ADD;
                    rd == 5'd0;
                    rs1 == 5'd0;
                    imm == 32'd0;
                })
                    `uvm_error("SEQ", "Randomization of NOP packet failed!")
            finish_item(nop);
        end
    endtask

endclass