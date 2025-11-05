`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 04:45:45 PM
// Design Name: 
// Module Name: vec_out_buff_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module vec_out_buff_tb;
    parameter BITS = 8;
    parameter N = 8;
    
    logic [BITS-1:0] in [N-1:0];
    logic [BITS-1:0] in_len;
    logic set;
    logic clk;
    logic [BITS-1:0] out;
    logic done;
    
    vec_out_buff #(
        .BITS(BITS),
        .N(N)
    ) DUT (
        .in(in),
        .in_len(in_len),
        .set(set),
        .clk(clk),
        .out(out),
        .done(done)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        in[0] = 8'b01010101;
        in[1] = 8'b00110011;
        in[2] = 8'b00001111;
        in[3] = 8'b00000000;
        in[4] = 8'b00000000;
        in[5] = 8'b00000000;
        in[6] = 8'b00000000;
        in[7] = 8'b00000000;
        in_len = 3;
        
        set = 0;
        
        #30
        
        set = 1;
        
        #10
        
        set = 0;
    end
    
endmodule
