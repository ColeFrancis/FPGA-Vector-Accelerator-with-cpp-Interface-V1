`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/11/2024 08:36:17 PM
// Design Name: 
// Module Name: input_blk_tb
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


module input_blk_tb;
    parameter FIFO_DEPTH = 2;
    parameter BAUD = 10_000_000;
    
    parameter CLK_FREQ = 100_000_000;
    parameter CLK_PER_BIT = CLK_FREQ / BAUD;
    
    logic clk;
    logic rst_l;
    logic rx;
    logic read;
    logic[7:0] out;
    logic ready;
    
    
    input_blk #(
        .BAUD(BAUD)
    ) DUT (
        .clk(clk),
        .rst_l(rst_l),
        .rx(rx),
        .read(read),
        .out(out),
        .ready(ready)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst_l = 0;
        rx = 1;
        read = 0;
        
        #100 
        
        rst_l = 1;
        
        send_uart_byte(8'b01100110);
        
        #200
        
        send_uart_byte(8'b00001111);
        
        #100
        
        read = 1;
        
        #50
        
        read = 0;
        
        #10
        
        read = 1;
        
        #10
        
        read = 0;
        
        #100
        
        send_uart_byte(8'b00000011);
    end
    
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Send start bit (0)
            rx = 0;
            #(CLK_PER_BIT * 10); // Wait one bit period

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(CLK_PER_BIT * 10); // Wait one bit period
            end

            // Send stop bit (1)
            rx = 1;
            #(CLK_PER_BIT * 10); // Wait one bit period
        end
    endtask

endmodule
