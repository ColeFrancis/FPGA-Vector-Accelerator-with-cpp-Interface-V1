`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 02:46:49 PM
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb;
    
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD = 10_000_000;
    parameter CLK_PER_BIT = CLK_FREQ / BAUD;
    
    reg clk;
    reg rst;
    reg start;
    reg [7:0] data_in;
    
    wire tx;
    wire busy;
    
    uart_tx #(
        .BAUD(BAUD),
        .CLK_FREQ(CLK_FREQ)    
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end
    
    initial begin
        clk = 0;
        forever #5 clk=~clk;
    end
    
    initial begin
        rst = 1;
        data_in = 8'b11010110;
        
        #100
        rst = 0;
        start = 1;
        
        #10
        start = 0;
        
    end 
endmodule
