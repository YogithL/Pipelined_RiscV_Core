
class pc_packet extends uvm_sequence_item;
    `uvm_object_utils(pc_packet)

    logic branchTaken;
    logic branchEnable;
    logic jumpEnable;
    logic[31:0] pcMuxOut;
	logic exValid;
  
    function new(string name = "pc_packet");
        super.new(name);
    endfunction

    virtual function string convert2string();
        string s = "";
        
        if(jumpEnable)
            s = {s, $sformatf("JUMP: PC -> 32'h%08x  ", pcMuxOut)};
        else if(branchEnable)
            s = {s, $sformatf("BRANCH: %s, Target PC -> 32'h%08x  ", 
                              branchTaken ? "TAKEN" : "NOT_TAKEN", pcMuxOut)};
        else
            s = "PC + 4";

        return s;

    endfunction

endclass