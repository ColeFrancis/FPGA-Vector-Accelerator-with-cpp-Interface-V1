`timescale 1ns/1ps

module top_tb;
    parameter BAUD = 10_000_000;
    parameter N = 8;
    parameter MULT_SHIFT = 0;
    parameter IN_FIFO_DEPTH = 4;
    parameter OUT_FIFO_DEPTH = 4;
     
    parameter CLK_FREQ = 100_000_000;
    parameter CLK_PER_BIT = CLK_FREQ / BAUD;
     
    logic clk;
    logic rst_l;
    logic rx;
    logic tx;
    
    logic [7:0] in_bus;
    logic [7:0] in_bus_prev;
    logic [7:0] out_bus;
    
    integer clk_count;
    
    top #(
        .BAUD(BAUD),
        .N(N),
        .MULT_SHIFT(MULT_SHIFT),
        .IN_FIFO_DEPTH(IN_FIFO_DEPTH),
        .OUT_FIFO_DEPTH(OUT_FIFO_DEPTH)
    ) DUT (
        .clk(clk),
        .rst_l(rst_l),
        .rx(rx),
        .tx(tx)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    always_ff @(posedge clk) begin
        if (!rst_l) 
            clk_count <= 0;
        else
            clk_count <= clk_count + 1;
            
            if (clk_count > 1500)
                $finish;
    end
    
    initial begin
        rx = 1;
        rst_l = 0;
        
        #100
        
        rst_l = 1;
        
        #50
        
        // Save 0 [7,1]
        // Add 0 0 10
        // Ret 0
        // Ret max 0
        
        send_uart_byte(8'b00010000); // save vec to vec A
        send_uart_byte(8'b00000000);
        send_uart_byte(8'b00000011); // vec len
        send_uart_byte(8'b00011001);
        send_uart_byte(8'b11100000);
        send_uart_byte(8'b00000111);
        
        send_uart_byte(8'b10000000); // vec-scal (#)
        send_uart_byte(8'b11110000);
        send_uart_byte(8'b00000011);
        
        send_uart_byte(8'b10000000); // ret vec b
        send_uart_byte(8'b00010000);
        
        send_uart_byte(8'b10010000); // ret or reduce
        send_uart_byte(8'b10010000);
    end
    
    always_ff @(posedge clk) begin
        in_bus_prev <= in_bus;
        
        in_bus <= DUT.in_bus;
        out_bus <= DUT.out_bus;
        
        if (in_bus_prev != in_bus) begin
            $display("in bus: %b\n", in_bus);
        end
        
        if (out_bus !== 8'bzzzz_zzzz) begin
            $display("out bus: %b\n", out_bus);
        end
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
