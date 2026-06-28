
class reg_monitor extends uvm_monitor;
    `uvm_component_utils(reg_monitor)

    uvm_analysis_port#(reg_packet) ap_reg;
    virtual reg_bfm reg_vif;

    function new(string name = "reg_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ap_reg = new("ap_reg", this);
        
        if(!uvm_config_db#(virtual reg_bfm)::get(this, "", "reg_vif", reg_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        reg_packet packet;

        forever begin
            packet = reg_packet::type_id::create("packet");

            reg_vif.sampleReg(packet.rd_data, packet.rd_addr, 
                              packet.reg_write, packet.retire_valid);
                              
            if(packet.retire_valid)
                ap_reg.write(packet);
        end

    endtask
    
endclass