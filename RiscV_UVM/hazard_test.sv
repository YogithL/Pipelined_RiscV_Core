class hazard_test extends uvm_test;
    `uvm_component_utils(hazard_test)

    environment env;

    function new(string name = "hazard_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = environment::type_id::create("env", this);

        hazard_seq_library::add_typewide_sequence(data_hazard_d1_seq::get_type());
        hazard_seq_library::add_typewide_sequence(data_hazard_d2_seq::get_type());
        hazard_seq_library::add_typewide_sequence(data_hazard_d3_seq::get_type());
        hazard_seq_library::add_typewide_sequence(data_hazard_ld_stall_seq::get_type());
        hazard_seq_library::add_typewide_sequence(mem_hazard_ld_str_seq::get_type());
        hazard_seq_library::add_typewide_sequence(mem_hazard_str_ld_seq::get_type());
        hazard_seq_library::add_typewide_sequence(rand_sequence::get_type());
    endfunction

    task run_phase(uvm_phase phase);
        nop_preamble_seq preamble;
        hazard_seq_library lib;
        phase.raise_objection(this);

        preamble = nop_preamble_seq::type_id::create("preamble");
        preamble.num_nops = 20;
        preamble.start(env.instrAgent.instrSequencer);

        lib = hazard_seq_library::type_id::create("lib");
        lib.min_random_count = 1000;
        lib.max_random_count = 1000;
        lib.selection_mode = UVM_SEQ_LIB_RANDC;

        lib.start(env.instrAgent.instrSequencer);

        phase.drop_objection(this);
    endtask

endclass