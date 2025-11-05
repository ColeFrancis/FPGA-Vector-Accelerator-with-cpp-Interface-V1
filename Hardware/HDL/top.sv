`timescale 1ns/1ps

module top #(
    parameter BAUD = 100_000,
    parameter N = 16,
    parameter MULT_SHIFT = 0,
    parameter IN_FIFO_DEPTH = 4,
    parameter OUT_FIFO_DEPTH = 64
) (
    input logic clk,
    input logic rst_l,
    input logic rx,
    output logic tx,
    output logic [15:0] inst
);
    (* KEEP = "TRUE" *) logic [7:0] in_bus, out_bus;
    //(* KEEP = "TRUE" *) logic [15:0] inst;
    logic [3:0] vec_sel_a, vec_sel_b;
    logic [2:0] alu_op_sel;
    
    logic [31:0] vec_out_buff_count;
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    input_blk #(
        .FIFO_DEPTH(IN_FIFO_DEPTH),
        .BAUD(BAUD)
    ) InputBlk (
        .clk(clk),
        .rst_l(rst_l),
        .rx(rx),
        .read(en_input_blk),
        .out(in_bus),
        .ready(input_blk_ready)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    output_blk #(
        .FIFO_DEPTH(OUT_FIFO_DEPTH),
        .BAUD(BAUD)
    ) OutputBlk(
        .clk(clk),
        .rst_l(rst_l),
        .set(set_output_blk),
        .in(out_bus),
        .tx(tx),
        .full(output_blk_full)
    );

    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    data_path #(
        .N(N),
        .MULT_SHIFT(MULT_SHIFT)
    ) DataPath (
        .clk(clk),
        .rst_l(rst_l),
        .in_bus(in_bus),
        .vec_sel_a(vec_sel_a),
        .vec_sel_b(vec_sel_b),
        .alu_op_sel(alu_op_sel),
        .alu_scal_sel(alu_scal_sel),
        .set_inst_hi(set_inst_hi),
        .set_inst_lo(set_inst_lo),
        .set_vec_imm_buff_vec(set_vec_imm_buff_vec),
        .set_vec_imm_buff_scal(set_vec_imm_buff_scal),
        .set_scal_imm_buff(set_scal_imm_buff),
        .set_vec_reg_bank(set_vec_reg_bank),
        .set_vec_alu(set_vec_alu),
        .set_red_alu(set_red_alu),
        .set_scal_acc(set_scal_acc),
        .set_vec_out_buff(set_vec_out_buff),
        .en_vec_imm_buff(en_vec_imm_buff),
        .en_scal_imm_buff(en_scal_imm_buff),
        .en_vec_reg_bank_a(en_vec_reg_bank_a),
        .en_vec_reg_bank_b(en_vec_reg_bank_b),
        .en_vec_alu(en_vec_alu),
        .en_red_alu(en_red_alu),
        .en_scal_acc(en_scal_acc),
        .out_bus(out_bus),
        .inst(inst),
        .vec_imm_buff_done(vec_imm_buff_done),
        .red_alu_done(red_alu_done),
        .vec_out_buff_count(vec_out_buff_count)
    );
    
    (* DONT_TOUCH = "TRUE" *)(* KEEP_HIERARCHY = "TRUE" *)
    control_logic ControlLogic(
        .clk(clk),
        .rst_l(rst_l),
        .inst(inst),
        .vec_imm_buff_done(vec_imm_buff_done),
        .red_alu_done(red_alu_done),
        .vec_out_buff_count(vec_out_buff_count),
        .output_blk_full(output_blk_full),
        .input_blk_ready(input_blk_ready),
        .vec_sel_a(vec_sel_a),
        .vec_sel_b(vec_sel_b),
        .alu_op_sel(alu_op_sel),
        .alu_scal_sel(alu_scal_sel),
        .set_inst_hi(set_inst_hi),
        .set_inst_lo(set_inst_lo),
        .set_vec_imm_buff_vec(set_vec_imm_buff_vec),
        .set_vec_imm_buff_scal(set_vec_imm_buff_scal),
        .set_scal_imm_buff(set_scal_imm_buff),
        .set_vec_reg_bank(set_vec_reg_bank),
        .set_vec_alu(set_vec_alu),
        .set_red_alu(set_red_alu),
        .set_scal_acc(set_scal_acc),
        .set_vec_out_buff(set_vec_out_buff),
        .set_output_blk(set_output_blk),
        .en_vec_imm_buff(en_vec_imm_buff),
        .en_scal_imm_buff(en_scal_imm_buff),
        .en_vec_reg_bank_a(en_vec_reg_bank_a),
        .en_vec_reg_bank_b(en_vec_reg_bank_b),
        .en_vec_alu(en_vec_alu),
        .en_red_alu(en_red_alu),
        .en_scal_acc(en_scal_acc),
        .en_input_blk(en_input_blk)
    );
endmodule
