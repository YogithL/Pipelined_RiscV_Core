class mem_driver extends uvm_driver#(mem_packet);
    `uvm_component_utils(mem_driver)
   
    virtual mem_bfm mem_vif;
    logic[7:0] SIM_RAM[bit[31:0]];

    function new(string name = "mem_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual mem_bfm)::get(this, "", "mem_vif", mem_vif))
            `uvm_fatal("VIF_ERROR", "Handle to interface not found");
    endfunction

    function logic[7:0] read_byte(bit[31:0] addr);
        return SIM_RAM.exists(addr) ? SIM_RAM[addr] : 8'h00;
    endfunction

    task run_phase(uvm_phase phase);
        logic [3:0] mem_write;
        logic mem_read;
        logic [31:0] read_addr;
        logic [31:0] write_addr;
        logic [31:0] write_data;
        bit  [31:0] word_base;
        logic[31:0] gathered_word;

        forever begin
            mem_vif.sampleMem(mem_write, mem_read, read_addr, write_addr, write_data);            
            
            if(mem_read) begin
                word_base = {read_addr[31:2], 2'b00};
                gathered_word = { read_byte(word_base + 3),
                                  read_byte(word_base + 2),
                                  read_byte(word_base + 1),
                                  read_byte(word_base + 0) };
                mem_vif.memRead(gathered_word);
            end

            if(mem_write > 0) begin
                if(mem_write[0]) SIM_RAM[write_addr + 0] = write_data[7:0];
                if(mem_write[1]) SIM_RAM[write_addr + 1] = write_data[15:8];
                if(mem_write[2]) SIM_RAM[write_addr + 2] = write_data[23:16];
                if(mem_write[3]) SIM_RAM[write_addr + 3] = write_data[31:24];
            end
        end
    endtask

endclass