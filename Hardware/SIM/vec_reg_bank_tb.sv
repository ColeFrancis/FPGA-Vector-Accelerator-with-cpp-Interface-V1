`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/08/2024 04:03:05 PM
// Design Name: 
// Module Name: vec_reg_bank_tb
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


module vec_reg_bank_tb;
    parameter BITS = 8;
    parameter N = 4;
    
    logic [BITS-1:0] data_in [N-1:0];
    logic [7:0] in_len;
    logic [3:0] in_sel;
    logic write;
    logic [3:0] out_sel_a;
    logic [3:0] out_sel_b;
    logic out_en_a;
    logic out_en_b;
    logic [BITS-1:0] out_a [N-1:0];
    logic [7:0] out_a_len;
    logic [BITS-1:0] out_b [N-1:0];
    logic [7:0] out_b_len;
    logic clk;
    
    vec_reg_bank #(
        .BITS(BITS),
        .N(N)
    ) bank (
        .in(data_in),
        .in_len(in_len),
        .in_sel(in_sel),
        .write(write),
        .out_sel_a(out_sel_a),
        .out_sel_b(out_sel_b),
        .out_en_a(out_en_a),
        .out_en_b(out_en_b),
        .out_a(out_a),
        .out_a_len(out_a_len),
        .out_b(out_b),
        .out_b_len(out_b_len),
        .clk(clk)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        data_in[0] = 8'b00001111;
        data_in[1] = 8'b00111100;
        data_in[2] = 8'b00000000;
        data_in[3] = 8'b00000000;
        in_len = 2;
        
        in_sel = 0;
        
        out_en_a = 1;
        out_en_b = 1;
        out_sel_a = 1;
        out_sel_b = 0;
         
        #12
        
        write = 1;
        
        #10
        
        write = 0;
        in_sel = 1;
        data_in[0] = 8'b11111111;
        data_in[1] = 8'b01111110;
        data_in[2] = 8'b01111101;
        in_len = 3;
        
        #10
        
        write = 1;
        
        #5 
        
        write = 0;
        in_sel = 2;
        data_in[0] = 8'b00000001;
        data_in[1] = 8'b00000000;
        data_in[2] = 8'b00001100;
        in_len = 2;
        
        #10
        
        write = 1;
        
        #10
        
        out_en_a = 0;
        out_sel_b = 2;
    end
endmodule
