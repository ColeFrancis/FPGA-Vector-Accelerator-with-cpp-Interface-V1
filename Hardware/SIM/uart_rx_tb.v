`timescale 1ns / 1ps

module uart_rx_tb;

    // Parameters
    parameter CLK_FREQ = 100_000_000; // 100 MHz clock frequency
    parameter BAUD = 10_000;          // Baud rate
    parameter CLK_PER_BIT = CLK_FREQ / BAUD;

    // Inputs
    reg clk;
    reg rst;
    reg rx_signal;

    // Outputs
    wire data_valid;
    wire [7:0] data_out;

    // Instantiate the UART Receiver module
    uart_rx #(
        .BAUD(BAUD),
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        .rst(rst),
        .rx(rx_signal),
        .data_valid(data_valid),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock period is 10ns (5ns high, 5ns low)
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = 1;
        rx_signal = 1;
        
        // Reset the module
        #100;
        rst = 0;

        // Send a byte via UART (let's send 8'hA5 = 10100101)
        send_uart_byte(8'hA5);

        // Wait for the data to be received
        wait (data_valid == 1);
        
        // Display the received data
        if (data_out == 8'hA5) begin
            $display("Test Passed: Received 0x%02X", data_out);
        end else begin
            $display("Test Failed: Received 0x%02X, expected 0xA5", data_out);
        end

        #100;
        $finish;
    end

    // Task to send a byte via UART
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            // Send start bit (0)
            rx_signal = 0;
            #(CLK_PER_BIT * 10); // Wait one bit period

            // Send 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_signal = data[i];
                #(CLK_PER_BIT * 10); // Wait one bit period
            end

            // Send stop bit (1)
            rx_signal = 1;
            #(CLK_PER_BIT * 10); // Wait one bit period
        end
    endtask

endmodule
