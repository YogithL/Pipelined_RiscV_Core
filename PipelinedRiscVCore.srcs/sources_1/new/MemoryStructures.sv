
module ROM(
    input logic clk,
    input logic[31:0] fetch_addr,
    output logic[31:0] instruction
    );
    import riscV_pkg::*;

    logic[31:0] ROMArray[0:1023];
    logic[9:0] word_index;

    assign word_index = fetch_addr[11:2];
    
    always_ff @(posedge clk) begin 
        instruction <= ROMArray[word_index];
    end
    
    initial begin
        $readmemh("ROMMemFile.mem", ROMArray);
    end

endmodule



module RAM(
    input logic clk,
    input logic[3:0] MemWrite,
    input logic[31:0] read_addr,
    input logic[31:0] write_addr,
    input logic[31:0] write_data,
    output logic[31:0] read_data
    );
    import riscV_pkg::*;
    
    logic[31:0] RAMArray[0:2047];
    logic [10:0] rd_index, wr_index;
    assign rd_index = read_addr[12:2];
    assign wr_index = write_addr[12:2];
     
    always_ff @(posedge clk) begin
        if(MemWrite > 0) begin
            if(MemWrite[0]) RAMArray[wr_index][7:0] <= write_data[7:0];
            if(MemWrite[1]) RAMArray[wr_index][15:8] <= write_data[15:8];
            if(MemWrite[2]) RAMArray[wr_index][23:16] <= write_data[23:16];
            if(MemWrite[3]) RAMArray[wr_index][31:24] <= write_data[31:24];
        end
    end
    
    always_ff @(posedge clk) begin
        read_data <= RAMArray[rd_index];
    end
    
endmodule



module DataAligner import riscV_pkg::*;(
    input width_e size,
    input logic[31:0] write_data,
    input logic[31:0] read_addr,
    input logic[31:0] write_addr,
    input logic[31:0] read_data,
    output logic[31:0] aligned_WD,
    output logic[31:0] aligned_RD 
    );
    
    logic [1:0] rd_offset, wr_offset;
    assign rd_offset = read_addr[1:0];
    assign wr_offset = write_addr[1:0];
    
    always_comb begin
        aligned_WD = 32'b0;
        aligned_RD =  32'b0;
            
        case(size)
            WORD: begin
                aligned_WD = write_data;
                aligned_RD = read_data;
            end
            
            HALF_U: begin
                case(rd_offset)
                    2'd0: aligned_RD = {16'b0, read_data[15:0]};
                    2'd2: aligned_RD = {16'b0, read_data[31:16]};
                    default: aligned_RD = read_data[15:0];
                endcase
            end
            
            HALF_S: begin
                case(rd_offset)                                         
                    2'd0: aligned_RD = { {16{read_data[15]}} , read_data[15:0]};
                    2'd2: aligned_RD = { {16{read_data[31]}} , read_data[31:16]};
                    default: aligned_RD = { {16{read_data[15]}} , read_data[15:0]};
                endcase   
                
                case(wr_offset)
                    2'd0: aligned_WD = {16'b0, write_data[15:0]};
                    2'd2: aligned_WD = {write_data[15:0], 16'b0};
                    default: aligned_WD = {16'b0, write_data[15:0]};
                endcase                     
            end
            
            BYTE_U: begin
                case(rd_offset)                                         
                    2'd0: aligned_RD = {24'h000000, read_data[7:0]};         
                    2'd1: aligned_RD = {24'h000000, read_data[15:8]};
                    2'd2: aligned_RD = {24'h000000, read_data[23:16]};
                    2'd3: aligned_RD = {24'h000000, read_data[31:24]};
                    default: aligned_RD = {24'h000000, read_data[7:0]};      
                endcase
            end
            
            BYTE_S: begin
                case(rd_offset)                                         
                    2'd0: aligned_RD = { {24{read_data[7]}} , read_data[7:0]};         
                    2'd1: aligned_RD = { {24{read_data[15]}} , read_data[15:8]};
                    2'd2: aligned_RD = { {24{read_data[23]}} , read_data[23:16]};
                    2'd3: aligned_RD = { {24{read_data[31]}} , read_data[31:24]};
                    default: aligned_RD = { {24{read_data[7]}} , read_data[7:0]};      
                endcase 
                
                case(wr_offset)
                    2'd0: aligned_WD = {24'b0, write_data[7:0]};
                    2'd1: aligned_WD = {16'b0, write_data[7:0], 8'b0};
                    2'd2: aligned_WD = {8'b0, write_data[7:0], 16'b0};
                    2'd3: aligned_WD = {write_data[7:0], 24'b0};
                    default: aligned_WD = {24'b0, write_data[7:0]};
                endcase                        
            end
            
            default: begin
                aligned_WD = write_data;
                aligned_RD = read_data;
            end
        endcase
    end
    
endmodule
            
    
    
    
        
        
        
        
        
        
        
        
        
        

