`timescale 1ns/1ps

/////////////////////////////////////////////////////////////////////////
// Behavior: When set_vec goes high, done goes low and the first value
//      is saved into an internal index, A. The following A values on
//      in are saved into the internal vector every clock cycle. Once A
//      values have been saved, done goes high.
//          When set_scal goes high, the first vlue of in is saved into
//      an internal index. The second value is saved into the internal 
//      vector. Once that is complete, done goes high.
//          When en is high teh internal vector is connected to out
//////////////////////////////////////////////////////////////////////////

module vec_imm_buff #(
        parameter BITS = 8,
        parameter N = 64
    )(
        input logic [BITS-1:0] in,
        input logic set_vec,
        input logic set_scal, 
        input logic en,
        input logic clk,
        input logic rst,
        output logic [BITS-1:0] out [N-1:0],
        output logic [BITS-1:0] out_len,
        output logic done
    );
    
    logic in_saved;
    logic [BITS-1:0] out_inter [N-1:0];
    logic [BITS-1:0] out_len_inter;
    
    logic signed [$clog2(N):0] index;
    logic running;
    logic state;
    
    // Tri state output 
    assign out_len = (en) ? out_len_inter : 'z; 
    genvar i;
    generate
        for (i=0; i<N; i++) 
            assign out[i] = en ? out_inter[i] : 'z; 
    endgenerate
    
    assign done = (index == out_len_inter);
   
    // State machine
    always_ff @(posedge clk) begin
        if (rst) begin
            index <= 0;
            out_len_inter <= 0;
            in_saved <= 0;
            
        end else begin
            if ((set_vec || set_scal) && done) begin
                index <= 0;
                out_len_inter <= in;
                
                foreach (out_inter[i]) out_inter[i] <= '0;
                
                if (set_vec) begin
                    state <= 0;
                    running <= 1;
                end else if (set_scal) begin
                    state <= 1;
                    running <= 0;
                end
                
            end else if (state && !running) begin
                in_saved <= in;
                running <= 1;
                
            end else if ((set_vec || set_scal) && running) begin
                if (index < out_len_inter) begin
                    out_inter[index] <= (state) ? in_saved : in;
                    index <= index + 1;
                    
                end else begin
                    running <= 0;
                    state <= 0;
                end
            end
        end
    end
endmodule
