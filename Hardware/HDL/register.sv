`timescale 1ns/1ps

module register #(
        parameter BITS = 8
    )(
        input logic [BITS-1:0] in,
        input logic set,
        input logic en,
        input logic clk,
        output logic [BITS-1:0] out
    );
    
    logic [BITS-1:0] mem;
    
    always_ff @(posedge clk) begin
        if(set) mem <= in;
    end
        
    assign out = en ? mem : 'z;
       
endmodule

module vector_reg #(
        parameter BITS = 8,
        parameter N = 64
    )(
        input logic [BITS-1:0] in [N-1:0],
        input logic set,
        input logic en,
        input logic clk,
        output logic [BITS-1:0] out [N-1:0]
    );
    
    genvar i;
    generate
        for (i=0; i<N; i++) begin
            register #(
                .BITS(BITS)
            ) r(
                .in(in[i]),
                .set(set),
                .en(en),
                .clk(clk),
                .out(out[i])
            );
        end
    endgenerate
endmodule
