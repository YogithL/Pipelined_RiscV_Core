
class environment extends uvm_env;
    `uvm_component_utils(environment)

    pc_agent pcAgent;
    instr_agent instrAgent;
    reg_agent regAgent;
    mem_agent memAgent;
    scoreboard scoreBoard;

    function new(string name = "environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        pcAgent = pc_agent::type_id::create("pcAgent", this);
        instrAgent = instr_agent::type_id::create("instrAgent", this);
        regAgent = reg_agent::type_id::create("regAgent", this);
        memAgent = mem_agent::type_id::create("memAgent", this);
        scoreBoard = scoreboard::type_id::create("scoreBoard", this);

        //need to add coverage group later

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        pcAgent.ap_pc.connect(scoreBoard.pc_export);
        instrAgent.ap_instr.connect(scoreBoard.instr_export);
        regAgent.ap_reg.connect(scoreBoard.reg_export);
        memAgent.ap_mem.connect(scoreBoard.mem_export);

        //need to add coverage group later
    endfunction
endclass