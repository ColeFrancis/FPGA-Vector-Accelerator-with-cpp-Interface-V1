`timescale 1ns / 1ps

module data_path_tb;
    parameter N = 16;
    parameter MULT_SHIFT = 0;

    // Inputs
    logic clk;
    logic rst_l;
    
    logic [7:0] in_bus;
    
    logic [3:0] vec_sel_a;
    logic [3:0] vec_sel_b;
    logic [2:0] alu_op_sel;
    logic alu_scal_sel;
    
    logic set_inst_hi;
    logic set_inst_lo;
    logic set_vec_imm_buff_vec;
    logic set_vec_imm_buff_scal;
    logic set_scal_imm_buff;
    logic set_vec_reg_bank;
    logic set_vec_alu;
    logic set_red_alu;
    logic set_scal_acc;
    logic set_vec_out_buff;
    
    logic en_vec_imm_buff;
    logic en_scal_imm_buff;
    logic en_vec_reg_bank_a;
    logic en_vec_reg_bank_b;
    logic en_vec_alu;
    logic en_red_alu;
    logic en_scal_acc;

    // Outputs
    logic [7:0] out_bus;
    
    logic [15:0] inst;
    
    logic vec_imm_buff_done;
    logic red_alu_done;
    logic vec_out_buff_done;

    // Instantiate the Unit Under Test (UUT)
    data_path #(
        .N(N),
        .MULT_SHIFT(MULT_SHIFT)
    ) DUT (
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
        .vec_out_buff_done(vec_out_buff_done)
    );
    
    initial begin
        $display("This simulation requires the GUI");
    end

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    initial begin
        rst_l = 0;
        
        in_bus = 8'b00000001;
    
        vec_sel_a = 4'b0000;
        vec_sel_b = 4'b0000;
        alu_op_sel = 3'b000;
        alu_scal_sel = 0;
        
        set_inst_hi = 0;
        set_inst_lo = 0;
        set_vec_imm_buff_vec = 0;
        set_vec_imm_buff_scal = 0;
        set_scal_imm_buff = 0;
        set_vec_reg_bank = 0;
        set_vec_alu = 0;
        set_red_alu = 0;
        set_scal_acc = 0;
        set_vec_out_buff = 0;
        
        en_vec_imm_buff = 0;
        en_scal_imm_buff = 0;
        en_vec_reg_bank_a = 0;
        en_vec_reg_bank_b = 0;
        en_vec_alu = 0;
        en_red_alu = 0;
        en_scal_acc = 0;
        
        #100
        
        rst_l = 1;
        set_inst_hi = 1;
        
        #10 
        
        set_inst_hi = 0;
        in_bus = 8'b00000011;
        
        #10
        
        set_vec_imm_buff_vec = 1;
        
        #10
        
        set_vec_imm_buff_vec = 0;
        
        #50
        
        en_vec_imm_buff = 1;
        vec_sel_a = 4'b0001;
        
        set_vec_reg_bank = 1;
        
        #10
        
        en_vec_imm_buff = 0;
        set_vec_reg_bank = 0;
        
        en_vec_reg_bank_a = 1;
        set_red_alu = 1;
        
        #10
        
        en_vec_reg_bank_a = 0;
        set_red_alu = 0;
        
        #50
        
        en_red_alu = 1;
        set_scal_acc = 1;
        
        #10
        
        en_red_alu = 0;
        set_scal_acc = 0;
        
        en_scal_acc = 1;
        
        
        
        alu_op_sel = 3'b001;
        alu_scal_sel = 1;
        en_vec_reg_bank_a = 1;
        set_vec_alu = 1;
        
        #10
        
        en_scal_acc = 0;
        en_vec_reg_bank_a = 0;
        set_vec_alu = 0;
        alu_scal_sel = 0;
        
        vec_sel_a = 4'b0010;
        
        en_vec_alu = 1;
        set_vec_reg_bank = 1;
        
        #10
        
        en_vec_alu = 0;
        set_vec_reg_bank = 0;
        
        vec_sel_b = 4'b0001;
        en_vec_reg_bank_a = 1;
        en_vec_reg_bank_b = 1;
        alu_op_sel = 3'b010;
        set_vec_alu = 1;
        
        #10
        
        en_vec_reg_bank_a = 0;
        en_vec_reg_bank_b = 0;
        set_vec_alu = 0;
        
        en_vec_alu = 1;
        set_vec_out_buff = 1;
        
        #10
        
        en_vec_alu = 0;
        set_vec_out_buff = 0;
        
    end

endmodule