
class mem_driver extends uvm_driver#(mem_packet);
    `uvm_component_utils(mem_driver)
   
    virtual mem_bfm mem_vif;
    logic[31:0] SIM_RAM[ bit[31:0] ];

    function new(string name = "mem_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual mem_bfm)::get(this, "", "mem_vif", mem_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");
    endfunction

    task run_phase(uvm_phase phase);
        logic [3:0] mem_write;
        logic mem_read;
        logic [31:0] read_addr;
        logic [31:0] write_addr;
        logic [31:0] write_data;

        forever begin
            mem_vif.sampleMem(mem_write, mem_read, read_addr, write_addr, write_data);            
            
            if(mem_read) begin
                if(SIM_RAM.exists(read_addr))
                    mem_vif.memRead(SIM_RAM[read_addr]);
                else
                    mem_vif.memRead(32'h00000000);
            end

          if(mem_write > 0) begin
                logic [31:0] current_word = SIM_RAM.exists(write_addr) ? SIM_RAM[write_addr] : 32'h0;
                logic [31:0] new_word = current_word;

                if (mem_write[0]) new_word[7:0]   = write_data[7:0];
                if (mem_write[1]) new_word[15:8]  = write_data[15:8];
                if (mem_write[2]) new_word[23:16] = write_data[23:16];
                if (mem_write[3]) new_word[31:24] = write_data[31:24];

                SIM_RAM[write_addr] = new_word;
            end        end
    endtask

endclass