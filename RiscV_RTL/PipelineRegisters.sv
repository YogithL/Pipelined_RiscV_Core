
module REG_IF_ID import riscV_pkg::*;(
    input logic clk,
    input logic rst_n,
    input logic EN,
    input logic CLR,
    input p_if_id_s in_IF_ID,
    output p_if_id_s out_IF_ID
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            out_IF_ID <= '0;
        else if(CLR) begin
            out_IF_ID <= '0;       
        end
        else if(EN)
            out_IF_ID <= in_IF_ID;
    end
endmodule


module REG_ID_EX import riscV_pkg::*;(
    input logic clk,
    input logic CLR,
    input logic rst_n,
    input p_id_ex_s in_ID_EX,
    output p_id_ex_s out_ID_EX
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            out_ID_EX <= '0;
        else if(CLR) begin
            out_ID_EX <= '0;      
        end
        else
            out_ID_EX <= in_ID_EX; 
    end
endmodule


module REG_EX_MEM import riscV_pkg::*;(
    input logic clk,
    input logic rst_n,
    input p_ex_mem_s in_EX_MEM,
    output p_ex_mem_s out_EX_MEM
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            out_EX_MEM <= '0; 

        else
            out_EX_MEM <= in_EX_MEM;
    end

endmodule



module REG_MEM_WB import riscV_pkg::*;(
    input logic clk,
    input logic rst_n,
    input p_mem_wb_s in_MEM_WB,
    output p_mem_wb_s out_MEM_WB
    );
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            out_MEM_WB <= '0; 

        else
            out_MEM_WB <= in_MEM_WB;
    end

endmodule
