`timescale 1ns/1ps

module uart_rx #(
    parameter BAUD = 10_000,
    parameter CLK_FREQ = 100_000_000 // Basys 3 clk Freq is 100 MHz
    )(
    input clk,
    input rst_l,
    input rx,
    output reg data_valid,
    output reg [7:0] data_out
    );
    
    localparam CLK_PER_BIT = CLK_FREQ / BAUD;
    reg [15:0] clk_counter = 0;
    
    localparam s_IDLE = 2'b00;
    localparam s_START = 2'b01;
    localparam s_DATA = 2'b10;
    localparam s_STOP = 2'b11;
    reg [1:0] state = s_IDLE;
    
    reg [2:0] bit_index = 0;
    
    always @(posedge clk) begin
        if (!rst_l) begin
            state <= s_IDLE;
            clk_counter <= 0;
            bit_index <= 0;
            data_valid <= 0;
            data_out <= 0;
        end
        
        case (state)
            s_IDLE: begin
                data_valid <= 0;
                
                if (~rx) begin
                    clk_counter <= 0;
                    state <= s_START;
                end
              
            end
            
            s_START: begin
                if (clk_counter == (CLK_PER_BIT-1)/2) begin // Wait until the middle of the start bit
                    if (rx == 1'b0) begin
                        clk_counter <= 0;
                        state <= s_DATA;
                    end else begin
                        state <= s_IDLE;
                    end
                end else begin
                    clk_counter <= clk_counter + 1;
                end
            end
            
            s_DATA: begin
                if (clk_counter < CLK_PER_BIT-1) begin // Wait until middle of data bit
                    clk_counter <= clk_counter + 1;
                end else begin
                    clk_counter <= 0;
                    data_out[bit_index] <= rx;
                    
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= s_STOP;
                    end
                end
            end
            
            s_STOP: begin
                if (clk_counter < CLK_PER_BIT-1) begin // Wait until middle of stop bit
                    clk_counter <= clk_counter + 1;
                end else begin
                    clk_counter <= 0;
                    data_valid <= 1;
                    state <= s_IDLE;
                end
            end
        endcase
    end
    
endmodule

module uart_tx #(
    parameter BAUD = 10_000,
    parameter CLK_FREQ = 100_000_000 // Basys 3 clk Freq is 100 MHz
    )(
    input clk,
    input rst_l,
    input start,
    input [7:0] data_in,
    output reg tx,
    output reg busy
    );
    
    localparam  CLK_PER_BIT = CLK_FREQ / BAUD;
    reg [15:0] clk_counter = 0;
    
    localparam s_IDLE = 2'b00;
    localparam s_START = 2'b01;
    localparam s_DATA = 2'b10;
    localparam s_STOP = 2'b11;
    reg [1:0] state = s_IDLE;
    
    reg [2:0] bit_index = 0;
    
    always @(posedge clk) begin
         if (!rst_l) begin
            state <= s_IDLE;
            clk_counter <= 0;
            tx <= 1;
            busy <= 0;
            bit_index = 0;
         end
         
         case (state)
            s_IDLE: begin
                tx <= 1;
                busy <= 0;
                
                if (start) begin
                    clk_counter <= 0;
                    state <= s_START;
                    busy <= 1;
                end
            end
            
            s_START: begin
                tx <= 1'b0;
                
                if (clk_counter < CLK_PER_BIT-1) begin
                    clk_counter <= clk_counter + 1;
                end else begin
                    clk_counter <= 0;
                    state <= s_DATA;
                end
            end
            
            s_DATA: begin
                tx <= data_in[bit_index];
                
                if (clk_counter < CLK_PER_BIT-1) begin
                    clk_counter <= clk_counter + 1;
                end else begin
                    clk_counter <= 0;
                    
                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= s_STOP;
                    end
                end
                
            end
            
            s_STOP: begin
                tx <= 1'b1;
                
                if (clk_counter < CLK_PER_BIT-1) begin
                    clk_counter <= clk_counter + 1;
                end else begin
                    clk_counter <= 0;
                    state <= s_IDLE;
                end
            end
         endcase
    end
endmodule
