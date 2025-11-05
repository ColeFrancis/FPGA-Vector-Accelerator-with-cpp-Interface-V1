`timescale 1ns / 1ps

module inst_reg_tb;
    parameter BITS = 8;
    
    logic [BITS-1:0] in;
    logic set_hi;
    logic set_lo;
    logic clk;
    logic [BITS*2-1:0] out;
    
    inst_reg #( 
        .BITS(BITS)
    ) DUT (
        .in(in),
        .set_hi(set_hi),
        .set_lo(set_lo),
        .clk(clk),
        .out(out)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        in = 8'b00110011;
        set_hi = 0;
        set_lo = 0;
        
        #10
        
        set_hi = 1;
        
        #10
        
        set_hi = 0;
        in = 8'b00001111;
        
        #10
        
        set_lo = 1;
        
        #10 
        
        set_lo = 0;
    end

endmodule