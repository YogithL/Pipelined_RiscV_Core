
class pc_monitor extends uvm_monitor;
    `uvm_component_utils(pc_monitor)

    virtual pc_bfm pc_vif;
    uvm_analysis_port#(pc_packet) ap_pc;

    function new(string name = "pc_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_pc = new("ap_pc", this);

        if(!uvm_config_db#(virtual pc_bfm)::get(this, "", "pc_vif", pc_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        pc_packet packet;

        forever begin
            packet = pc_packet::type_id::create("packet");

            pc_vif.samplePC(packet.pcMuxOut, packet.branchTaken, 
                            packet.branchEnable, packet.jumpEnable);

            if(packet.branchEnable || packet.jumpEnable)
                ap_pc.write(packet);
        end

    endtask


endclass