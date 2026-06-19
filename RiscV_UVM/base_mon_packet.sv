
class base_mon_packet extends uvm_sequence_item;
    `uvm_object_utils(base_mon_packet)

    function new(string name = "base_mon_packet");
        super.new(name);
    endfunction

    //PC
    logic[31:0] PC;
    logic branchTaken;
    logic branchEnable;
    logic jumpEnable;

    //Flags
    logic mem_read;
    logic reg_write;
    logic mem_write;

    //Registers 
    logic[31:0] rd_data;
    logic[4:0] rd_addr;

    //Loads
    logic[31:0] read_data;
    logic[31:0] read_addr;

    //Stores
    logic[31:0] write_data;
    logic[31:0] write_addr;

    virtual function string convert2string();
        string s = "";
        
        if(jumpEnable)
            s = {s, $sformatf("JUMP: PC -> 32'h%08x  ", PC)};
        else if(branchEnable)
            s = {s, $sformatf("BRANCH: %s, Target PC -> 32'h%08x  ", 
                              branchTaken ? "TAKEN" : "NOT_TAKEN", PC)};
        
        if(reg_write && rd_addr != 0) 
            s = {s, $sformatf("REG_WRITE: x%0d <- 32'h%08x  ", rd_addr, rd_data)};
            
        if(mem_write) 
            s = {s, $sformatf("MEM_WRITE: [32'h%08x] <- 32'h%08x  ", write_addr, write_data)};
            
        if(mem_read) 
            s = {s, $sformatf("MEM_READ:  [32'h%08x] -> 32'h%08x  ", read_addr, read_data)};
        
        if(s == "") 
            s = "NO_OUTPUT";
            
        return s;
    endfunction

endclass