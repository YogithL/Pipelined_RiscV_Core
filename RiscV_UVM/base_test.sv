
class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    environment env;
    rand_sequence seq;
    data_hazard_sequence hazard_seq;

    function new(string name = "base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        seq = rand_sequence::type_id::create("seq");
        hazard_seq = data_hazard_sequence::type_id::create("hazard_seq");

        phase.raise_objection(this);
        seq.start(env.instrAgent.instrSequencer);
        hazard_seq.start(env.instrAgent.instrSequencer);
        phase.drop_objection(this);

    endtask

endclass