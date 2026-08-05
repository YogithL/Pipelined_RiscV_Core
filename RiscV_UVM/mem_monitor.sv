
class mem_monitor extends uvm_monitor;
    `uvm_component_utils(mem_monitor)

    virtual mem_bfm mem_vif;
    uvm_analysis_port#(mem_packet) ap_mem;

    function new(string name = "mem_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_mem = new("ap_new", this);

        if(!uvm_config_db#(virtual mem_bfm)::get(this, "", "mem_vif", mem_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        mem_packet packet;

        forever begin
            packet = mem_packet::type_id::create("packet");
                        
                fork
                    mem_vif.sampleMem(packet.mem_write, packet.mem_read, 
                                      packet.read_addr, packet.write_addr, 
                                      packet.write_data);

                    mem_vif.sampleReadData(packet.read_data);
                join
            
            if(packet.mem_write > 0 || packet.mem_read)
                ap_mem.write(packet);
        end

    endtask


endclass