`timescale 1ns/1ps

module output_blk #(
        parameter FIFO_DEPTH = 64, // must be a power of two for the internal FIFO to work properly (they must use the full range of values so the pointers will wrap around immediatly)
        parameter BAUD = 100_000
    ) (
        input logic clk, 
        input logic rst_l,
        
        input logic set,
        input logic [7:0] in,
        output logic tx,
        output logic full
    );
    
    localparam CLK_FREQ = 100_000_000;
    
    logic [7:0] uart_in;
    
    logic fifo_read;
    logic fifo_empty;
    logic uart_busy;
    logic uart_start;
    
    localparam s_IDLE = 2'b00;
    localparam s_READ = 2'b01;
    localparam s_SET =  2'b11;;
    logic [1:0] write_state;
    
    uart_tx #(
        .BAUD(BAUD),
        .CLK_FREQ(CLK_FREQ)
    ) Uart (
        .clk(clk),
        .rst_l(rst_l),
        .start(uart_start),
        .data_in(uart_in),
        .tx(tx),
        .busy(uart_busy)
    );
    
    fifo #(
        .DEPTH(FIFO_DEPTH),
        .DWIDTH(8)
    ) FIFO (
        .clk(clk),
        .rst_l(rst_l),
        .w_en(set),
        .r_en(fifo_read),
        .d_in(in),
        .d_out(uart_in),
        .empty(fifo_empty),
        .full(full)
    );
    
    always @(posedge clk) begin
        if (!rst_l) begin
            write_state <= 0;
            
            fifo_read <= 0;
            uart_start <= 0;
        end
        else begin
            case (write_state)
                s_IDLE: begin
                    if(!uart_busy) begin
                        write_state <= s_READ;
                    end
                end
                s_READ: begin
                    if (!fifo_empty) begin
                        fifo_read <= 1;
                        uart_start <= 1;
                        
                        write_state <= s_SET;
                    end
                end
                s_SET: begin
                    fifo_read  <= 0;
                    uart_start <= 0;
                    
                    if (uart_busy) begin
                        write_state <= s_IDLE;
                    end
                end
                default: begin
                    write_state <= s_IDLE;
                end
            endcase
        end
    end
    
endmodule
