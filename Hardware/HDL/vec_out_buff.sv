`timescale 1ns/1ps

///////////////////////////////////////////////////////////////////////////////////
// Behavior: When set is high and clk rises, done goes low and the value in the 
//      in vector is saved into the internal register. Each value in the in the 
//      internal register is sent to out one byte at a time starting with in[0] 
//      and ending with in[N-1]. Once this is completed, done goes high.
///////////////////////////////////////////////////////////////////////////////////

module vec_out_buff #(
        parameter BITS = 8,
        parameter N = 64
    )(
        input logic clk,
        input logic rst_l,
        input logic [BITS-1:0] in [N-1:0],
        input logic [BITS-1:0] in_len,
        input logic set,
        output logic [BITS-1:0] out,
        output logic [31:0] out_count
    );
    
    logic [BITS-1:0] in_inter [N-1:0];
    logic [BITS-1:0] in_len_inter;
    
    logic [$clog2(N):0] index;
    logic running;
    
    vector_reg #(
        .BITS(BITS),
        .N(N)
    ) buff (
        .clk(clk),
        .in(in),
        .set(set),
        .en(1),
        .out(in_inter)
    );
    
    //State machine
    always_ff @(posedge clk) begin
        if (!rst_l) begin
            running <= 0;
            out <= 'z;
            out_count <= 0;
        end
        else begin
            if (set) begin
                in_len_inter <= in_len;
                index <= 0;
                running <= 1;
                
                out <= 'z;
                out_count <= in_len;
                
            end else if (running) begin
                if (index < in_len_inter) begin
                    out <= in_inter[index];
                    index <= index + 1;
                    out_count <= out_count - 1;
                    
                end else begin
                    running <= 0;
                    
                    out <= 'z;
                end
                
            end else begin
                out <= 'z;
            end
        end
    end
endmodule
