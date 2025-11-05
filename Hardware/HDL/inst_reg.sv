`timescale 1ns/1ps

/////////////////////////////////////////////////////////////////////////////
// Behavior: when set_hi is high and the clock rises, in is saved into the
//      top 8 bits of inst_reg. The patter repeats for the lower 8 bits
/////////////////////////////////////////////////////////////////////////////

module inst_reg #(
        parameter BITS = 8
    ) (
        input logic [BITS-1:0] in,
        input logic set_hi,
        input logic set_lo,
        input logic clk,
        input logic rst,
        output logic [BITS*2-1:0] out
    );
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) 
            out <= '0;
        else begin
            if (set_hi) out[BITS*2-1:BITS] <= in;
            else if (set_lo) out[BITS-1:0] <= in;
        end
    end
    
endmodule