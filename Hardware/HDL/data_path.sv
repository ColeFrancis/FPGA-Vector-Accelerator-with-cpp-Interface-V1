`timescale 1ns/1ps

module data_path #(
        parameter N = 64,
        parameter MULT_SHIFT = 0
    )(
        input logic clk, 
        input logic rst_l,
        
        input logic [7:0] in_bus,
        
        input logic [3:0] vec_sel_a,
        input logic [3:0] vec_sel_b,
        input logic [2:0] alu_op_sel,
        input logic alu_scal_sel,
        
        input logic set_inst_hi,
        input logic set_inst_lo,
        input logic set_vec_imm_buff_vec,
        input logic set_vec_imm_buff_scal,
        input logic set_scal_imm_buff,
        input logic set_vec_reg_bank,
        input logic set_vec_alu,
        input logic set_red_alu,
        input logic set_scal_acc,
        input logic set_vec_out_buff,
        
        input logic en_vec_imm_buff,
        input logic en_scal_imm_buff,
        input logic en_vec_reg_bank_a,
        input logic en_vec_reg_bank_b,
        input logic en_vec_alu,
        input logic en_red_alu,
        input logic en_scal_acc,
        
        output logic [7:0] out_bus,
        
        output logic [15:0] inst,
        
        output logic vec_imm_buff_done,
        output logic red_alu_done,
        
        output logic [31:0] vec_out_buff_count
    );
    
    (* KEEP = "TRUE" *) logic [7:0] data_bus_a [N-1:0]; // out of regbank a and into vec alu(a) and reduce alu
    (* KEEP = "TRUE" *) logic [7:0] len_bus_a;
    (* KEEP = "TRUE" *) logic [7:0] data_bus_b [N-1:0]; // out of regbank b, vec # buffer, and vec alu and into vec alu(b), reg bank, and vec out buffer
    (* KEEP = "TRUE" *) logic [7:0] len_bus_b;
    (* KEEP = "TRUE" *) logic [7:0] scal_bus; // out of scalar # buffer and scalar accum, and into vec alu (scalar)
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    inst_reg #(.BITS(8)) InstReg (
        .in(in_bus),
        .set_hi(set_inst_hi),
        .set_lo(set_inst_lo),
        .clk(clk),
        .rst(!rst_l),
        .out(inst)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    vec_imm_buff #(.BITS(8),.N(N)) VecImmBuff (
        .in(in_bus),
        .set_vec(set_vec_imm_buff_vec),
        .set_scal(set_vec_imm_buff_scal),
        .en(en_vec_imm_buff),
        .clk(clk),
        .rst(!rst_l),
        .out(data_bus_b),
        .out_len(len_bus_b),
        .done(vec_imm_buff_done)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    register #(.BITS(8)) ScalImmBuff (
        .in(in_bus),
        .set(set_scal_imm_buff),
        .en(en_scal_imm_buff),
        .clk(clk),
        .out(scal_bus)
    );
    
    (* KEEP_HIERARCHY = "TRUE" *)
    vec_reg_bank #(.BITS(8), .N(N)) VecRegBank (
        .clk(clk),
        .in(data_bus_b),
        .in_len(len_bus_b),
        .in_sel(vec_sel_a),
        .write(set_vec_reg_bank),
        .out_a(data_bus_a),
        .out_a_len(len_bus_a),
        .out_sel_a(vec_sel_a),
        .out_en_a(en_vec_reg_bank_a),
        .out_b(data_bus_b),
        .out_b_len(len_bus_b),
        .out_sel_b(vec_sel_b),
        .out_en_b(en_vec_reg_bank_b)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    vector_element_alu #(.BITS(8), .N(N), .MULT_SHIFT(MULT_SHIFT)) VecAlu (
        .A(data_bus_a),
        .A_len(len_bus_a),
        .B(data_bus_b),
        .B_len(len_bus_b),
        .scalar(scal_bus),
        .op_sel(alu_op_sel),
        .scalar_sel(alu_scal_sel),
        .set(set_vec_alu),
        .en(en_vec_alu),
        .clk(clk),
        .S(data_bus_b),
        .S_len(len_bus_b)
    );
    
    logic signed [7:0] signed_data_bus_a [N-1:0];
    always @(*) begin
        for (integer i = 0; i < N; i = i + 1) begin
            signed_data_bus_a[i] = signed'(data_bus_a[i]);
        end
    end
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    reduce_vector_alu #(.BITS(8), .N(N)) RedAlu (
        .in(signed_data_bus_a),
        .in_len(len_bus_a),
        .sel(alu_op_sel[1:0]),
        .set(set_red_alu),
        .en(en_red_alu),
        .clk(clk),
        .out(out_bus),
        .done(red_alu_done)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    register #(.BITS(8)) ScalAcc (
        .in(out_bus),
        .set(set_scal_acc),
        .en(en_scal_acc),
        .clk(clk),
        .out(scal_bus)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    vec_out_buff #(.BITS(8), .N(N)) VecOutBuff (
        .in(data_bus_b),
        .in_len(len_bus_b),
        .set(set_vec_out_buff),
        .clk(clk),
        .rst_l(rst_l),
        .out(out_bus),
        .out_count(vec_out_buff_count)
    );
endmodule
