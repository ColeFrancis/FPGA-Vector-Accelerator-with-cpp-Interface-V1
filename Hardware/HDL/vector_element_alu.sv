`timescale 1ns/1ps

////////////////////////////////////////////////////////////////////////////
// Behavior: When set is high and clk edge rises the operation in op_sel
//      will be perforemd on A and B if scalar_sel is low or A and scalar
//      if scalar_sel is high.
//           When en is high the output of the last operation will be
//      routed to S
////////////////////////////////////////////////////////////////////////////

module vector_element_alu #(
        parameter BITS = 8,
        parameter N = 64,
        parameter MULT_SHIFT = 0
    )(
        input logic [BITS-1:0] A [N-1:0],
        input logic [BITS-1:0] A_len,
        input logic [BITS-1:0] B [N-1:0],
        input logic [BITS-1:0] B_len,
        input logic [BITS-1:0] scalar,
        input logic [2:0] op_sel,
        input logic scalar_sel,
        input logic set,
        input logic en,
        input logic clk,
        output logic [BITS-1:0] S [N-1:0],
        output logic [BITS-1:0] S_len
    );
    
    logic [BITS-1:0] B_inter [N-1:0];
    logic [BITS-1:0] scalar_inter [N-1:0];
    logic [7:0] S_len_inter;

    assign S_len_inter = (scalar_sel) ? A_len : ((A_len > B_len) ? A_len : B_len);
    
    //assign B_inter = scalar_sel ? scalar_inter : B;

    register #(
        .BITS(8)
    ) len (
        .in(S_len_inter),
        .set(set),
        .en(en),
        .clk(clk),
        .out(S_len)
    );
    
    genvar i;
    generate
        for (i=0; i<N; i++) begin
            assign B_inter[i] = scalar_sel ? scalar : B[i];
            //assign scalar_inter[i] = i < A_len ? scalar : 1'b0;   // Its not necessary because the length is being kept track of
            
            single_element_alu #(
                .BITS(BITS),
                .MULT_SHIFT(MULT_SHIFT)
            ) alu (
                .A(A[i]),
                .B(B_inter[i]),
                .sel(op_sel),
                .set(set),
                .S(S[i]),
                .en(en),
                .clk(clk)
            );
        end
    endgenerate
    
endmodule

module single_element_alu #(
        parameter BITS = 8,
        parameter MULT_SHIFT = 0
    )(
        input logic [BITS-1:0] A,
        input logic [BITS-1:0] B,
        input logic [2:0] sel,
        input logic set,
        input logic en,
        input logic clk,
        output logic [BITS-1:0] S
    );
    
    logic [BITS-1:0] S_int;
    
    logic [BITS-1:0] add_sub_out;
    logic [BITS-1:0] mult_out;
    logic [BITS-1:0] cmp_out;
    
    always_comb begin
        if (sel[2]) begin // Logic
            case (sel[1:0])
                2'b00: S_int = A & B;
                2'b01: S_int = A | B;
                2'b10: S_int = A ^ B;
                2'b11: S_int = ~A;
            endcase
        end else begin // Arithmetic
            if (sel[1]) begin // Multiply / Compare
                if (sel[0]) begin
                    S_int = cmp_out;
                end else begin
                    S_int = mult_out;
                end
            end else begin // Add / Sub
                S_int = add_sub_out;
            end
        end
    end
    
    // cmp_out = 1 if A>B, 0 if A==B, and -1 if A<B
    assign cmp_out[BITS-1:1] = { (BITS-1) {add_sub_out[BITS-1]} };
    assign cmp_out[0] = |add_sub_out;
    
    single_add_sub #(
        .BITS(BITS)
    ) adder (
        .A(A),
        .B(B),
        .sub(sel[0]),
        .S(add_sub_out)
    );
    
    single_multiplier #(
        .BITS(BITS),
        .OUT_SHIFT(MULT_SHIFT)
    ) mult (
        .A(A),
        .B(B),
        .P(mult_out)
    ); 
    
    register #(
        .BITS(BITS)
    ) r (
        .in(S_int),
        .set(set),
        .en(en),
        .clk(clk),
        .out(S)
    );
endmodule

module single_add_sub #(
        parameter BITS = 8
    )(
        input logic [BITS-1:0] A,
        input logic [BITS-1:0] B,
        input logic sub,
        output logic [BITS-1:0] S
    );
    
    logic[BITS-1:0] B_int;
    
    assign B_int = B ^ {BITS{sub}};
    
    assign S = A + B_int + sub;
    
endmodule

module single_multiplier #(
        parameter BITS = 8,
        parameter OUT_SHIFT = 0
    )(
        input logic signed [BITS-1:0] A,
        input logic signed [BITS-1:0] B,
        output logic signed [BITS-1:0] P
    );
    
    logic [2*BITS-1:0] temp_P;
    
    assign temp_P = A * B;
    
    always_comb begin
        for (int i=0; i<BITS; i++) begin
            P[i] = temp_P[i+OUT_SHIFT];
        end
    end
endmodule
