
class reg_packet extends uvm_sequence_item;
    `uvm_object_utils(reg_packet)

    logic reg_write;
    logic[31:0] rd_data;
    logic[4:0]  rd_addr;
    logic retire_valid;
    
    function new(string name = "reg_packet");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string s = "";
        
        if(reg_write && rd_addr != 0) 
            s = {s, $sformatf("REG_WRITE: x%0d <- 32'h%08x", rd_addr, rd_data)};
            
        if(s == "") 
            s = "IDLE";
    
        return s;

    endfunction
endclass