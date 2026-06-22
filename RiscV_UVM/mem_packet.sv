
class mem_packet extends uvm_sequence_item;
    `uvm_object_utils(mem_packet)

    logic mem_read;
    logic[3:0]  mem_write; 
    logic[31:0] read_data;
    logic[31:0] read_addr;
    logic[31:0] write_data;
    logic[31:0] write_addr;

    function new(string name = "mem_packet");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string s = "";
        
        if(mem_write > 0) 
            s = $sformatf("MEM_WRITE: [32'h%08x] <- 32'h%08x", write_addr, write_data);
        else if(mem_read) 
            s = $sformatf("MEM_READ:  [32'h%08x] -> 32'h%08x", read_addr, read_data);
        else 
            s = "IDLE";
        return s;
        
    endfunction
endclass