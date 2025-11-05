`timescale 1ns/1ps

module fifo #(
    parameter DEPTH = 8,
    parameter DWIDTH = 8
) (
    input clk,
    input rst_l,
    
    input w_en,
    input r_en,
    
    input      [DWIDTH-1:0] d_in,
    output reg [DWIDTH-1:0] d_out,
    
    output reg empty,
    output reg full
);

    reg [$clog2(DEPTH)-1:0] w_ptr;
    reg [$clog2(DEPTH)-1:0] r_ptr;
    
    reg [$clog2(DEPTH)-1:0] count;
    
    reg [DWIDTH-1:0] fifo [DEPTH-1:0];
    
    always @(posedge clk) begin
        if (!rst_l) begin
            w_ptr <= 0;
            r_ptr <= 0;
            
            count <= 0;
            
            full  <= 0;
            empty <= 1;
        end
        else begin
            if (w_en && !r_en && !full) begin
                fifo[w_ptr] <= d_in;
                
                empty <= 0;
                
                count <= count + 1;
                if (count == DEPTH-1) 
                    full <= 1;
                    
                if (w_ptr < DEPTH-1)
                    w_ptr <= w_ptr + 1;
                else
                    w_ptr <= 0;
            end
            else if (!w_en && r_en && !empty) begin
                d_out <= fifo[r_ptr];
                
                full <= 0;
                
                count <= count - 1;
                if (count == 1)
                    empty <= 1;
                    
                if (r_ptr < DEPTH-1)
                    r_ptr <= r_ptr + 1;
                else
                    r_ptr <= 0;
            end
            else if (w_en && r_en) begin
                d_out <= fifo[r_ptr];
                fifo[w_ptr] <= d_in;
                
                if (w_ptr < DEPTH-1)
                    w_ptr <= w_ptr + 1;
                else
                    w_ptr <= 0;
                    
                if (r_ptr < DEPTH-1)
                    r_ptr <= r_ptr + 1;
                else
                    r_ptr <= 0;
            end
        end
    end

endmodule