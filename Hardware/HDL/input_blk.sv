`timescale 1ns/1ps

// FIFO_DEPTH must be a power of 2
module input_blk #(
        parameter FIFO_DEPTH = 4,
        parameter BAUD = 100_000
    ) (
        input logic clk, 
        input logic rst_l,
        
        input logic rx,
        input logic read,
        output logic [7:0] out,
        output logic ready
    );
    
    localparam CLK_FREQ = 100_000_000;
    
    logic [7:0] mem [FIFO_DEPTH-1:0];
    
    logic [7:0] uart_out;
    
    logic fifo_empty;
    assign ready = ~fifo_empty;
    
    logic w_state;
    
    uart_rx #(
        .BAUD(BAUD),
        .CLK_FREQ(CLK_FREQ)
    ) Uart (
        .clk(clk),
        .rst_l(rst_l),
        .rx(rx),
        .data_valid(uart_done),
        .data_out(uart_out)
    );
    
    fifo #(
        .DEPTH(FIFO_DEPTH),
        .DWIDTH(8)
    ) FIFO (
        .clk(clk),
        .rst_l(rst_l),
        .w_en(uart_done),
        .r_en(read),
        .d_in(uart_out),
        .d_out(out),
        .empty(fifo_empty),
        .full()
    );
    
endmodule
