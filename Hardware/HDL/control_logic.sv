/*
* Nop                         - 0000000000000000
*
* Save scal to vec A (len, #) - 000000000010aaaa
* Save vec to vec A (len, #)  - 000000000001aaaa
*
* Return vec B                - 0001bbbb1ddddddd
* Copy vec B to vec A         - 0010bbbb1dddaaaa
*
* Vec - Vec (len, #)          - 1110dddd1xxxaaaa
* Vec - vec (reg)             - 1010bbbb1xxxaaaa
*
* Vec - scal (#)              - 1111dddd1xxxaaaa
* Vec - scal (acc)            - 1011dddd1xxxaaaa
*
* Vec red -> ret              - 1001dddd1dxxaaaa
* Vec red -> acc              - 1000dddd1dxxaaaa
*/

/*
 * ALU 
 *  000 - A+B
 *  001 - A-B
 *  010 - A*B
 *  011 - A cmp B
 *  100 - A&B
 *  101 - A|B
 *  110 - A^B
 *  111 - ~A
 *
 * RED
 *  00 - sum
 *  01 - or
 *  10 - min
 *  11 - max
*/

`timescale 1ns/1ps

module control_logic (
    input logic clk, 
    input logic rst_l,
    
    input logic [15:0] inst,
    
    input logic vec_imm_buff_done,
    input logic red_alu_done,
    
    input logic [31:0] vec_out_buff_count,
    
    input logic output_blk_full,
    input logic input_blk_ready,
        
    output logic [3:0] vec_sel_a,
    output logic [3:0] vec_sel_b,
    output logic [2:0] alu_op_sel,
    output logic       alu_scal_sel,
    
    output logic en_vec_imm_buff,
    output logic en_scal_imm_buff,
    output logic en_vec_reg_bank_a,
    output logic en_vec_reg_bank_b,
    output logic en_vec_alu,
    output logic en_red_alu,
    output logic en_scal_acc,
    output logic en_input_blk,
    
    output logic set_inst_hi,
    output logic set_inst_lo,
    output logic set_vec_imm_buff_vec,
    output logic set_vec_imm_buff_scal,
    output logic set_scal_imm_buff,
    output logic set_vec_reg_bank,
    output logic set_vec_alu,
    output logic set_red_alu,
    output logic set_scal_acc,
    output logic set_vec_out_buff,
    output logic set_output_blk
); 

    logic nop_inst;
    logic ex_inst;
    logic imm_inst;
    logic vec_imm_inst_vec;
    logic vec_imm_inst_scal;
    logic scal_imm_inst;
    logic vec_alu_inst;
    logic vec_scal_inst;
    logic red_alu_inst;
    logic ret_vec_inst;
    logic ret_scal_inst;

    ///////////////////////////////////////////////////////////////////////////////////
    // States /////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////
    typedef enum {
        FET_lo_1, FET_lo_2, FET_hi_1, FET_hi_2,
        DEC_0, DEC_1, DEC_2, DEC_vec1, DEC_vec2, DEC_vec3,
        EX_1, EX_red,
        WB_1, WB_2, WB_vec_ret
    } top_state_t;
    
    top_state_t state;
    
    
    ////////////////////////////////////////////////////////////////////////////
    // State independent control signals ///////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    assign vec_sel_a  = inst[3:0];
    assign vec_sel_b  = inst[11:8];
    assign alu_op_sel = inst[6:4];
    assign alu_scal_sel = vec_scal_inst;
    
    
    ////////////////////////////////////////////////////////////////////////////
    // intermediate state control signals //////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    assign nop_inst          = !(|inst[7:0]);
    
    assign imm_inst          = vec_imm_inst_vec || vec_imm_inst_scal || scal_imm_inst;
    assign ex_inst           = inst[7] && inst[15];
    
    assign vec_imm_inst_vec  = inst[7:4] == 4'b0001 || inst[15:12] == 4'b1110;
    assign vec_imm_inst_scal = inst[7:4] == 4'b0010;
    assign scal_imm_inst     = inst[7] && (inst[15:12] == 4'b1111);
    
    assign vec_alu_inst      = ex_inst && inst[13];
    assign vec_scal_inst     = vec_alu_inst && (inst[13:12] == 2'b11);
    assign red_alu_inst      = ex_inst && !inst[13];
    
    assign ret_vec_inst      = inst[7] && (inst[15:12] == 4'b0001);
    assign ret_scal_inst     = inst[7] && (inst[15:12] == 4'b1001);
    

    ////////////////////////////////////////////////////////////////////////////
    // State machine ///////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk, negedge rst_l) begin
        if (!rst_l) begin
            en_vec_imm_buff   <= 0;
            en_scal_imm_buff  <= 0;
            en_vec_reg_bank_a <= 0;
            en_vec_reg_bank_b <= 0;
            en_vec_alu        <= 0;
            en_red_alu        <= 0;
            en_scal_acc       <= 0;
            en_input_blk      <= 0;
        
            set_inst_hi           <= 0;
            set_inst_lo           <= 0;
            set_vec_imm_buff_vec  <= 0;
            set_vec_imm_buff_scal <= 0;
            set_scal_imm_buff     <= 0;
            set_vec_reg_bank      <= 0;
            set_vec_alu           <= 0;
            set_red_alu           <= 0;
            set_scal_acc          <= 0;
            set_vec_out_buff      <= 0;
            set_output_blk        <= 0;                                                                          
        
            state <= FET_lo_1; 
        end
        else begin
            case (state)
                FET_lo_1: begin // Request first byte of inst
                    en_red_alu <= 0;
                    set_output_blk <= 0;
                    set_scal_acc <= 0;
                    en_vec_alu <= 0;
                    set_vec_reg_bank <= 0;
                    en_vec_reg_bank_a <= 0;
                    en_vec_reg_bank_b <= 0;
                    en_vec_imm_buff <= 0;
                    
                    if (input_blk_ready) begin
                        en_input_blk <= 1;
                        
                        state <= FET_lo_2;
                    end
                end
                FET_lo_2: begin // Set first byte of inst
                    set_inst_lo <= 1;
                    state <= FET_hi_1;
                end
                FET_hi_1: begin  
                    set_inst_lo <= 0;
                    
                    if (input_blk_ready) begin
                        en_input_blk <= 1;
                        
                        state <= FET_hi_2;
                    end
                    else begin
                        en_input_blk <= 0;
                    end
                end
                FET_hi_2: begin // Set 2nd byte of inst
                    en_input_blk <= 0;
                    set_inst_hi <= 1;
                    
                    state <= DEC_0;
                end
                DEC_0: begin
                    set_inst_hi <= 0;
                    
                    state <= DEC_1;
                end
                DEC_1: begin // Decode inst
                    if (nop_inst) begin
                        state <= FET_lo_1;
                    end
                    else if (imm_inst) begin
                        if (input_blk_ready) begin
                            en_input_blk <= 1;
                            
                            state <= DEC_2;
                        end
                    end
                    else begin
                        if (ex_inst)
                            state <= EX_1;
                        else
                            state <= WB_1;
                    end
                end
                DEC_2: begin // Decode imm type
                    en_input_blk <= 0;
                    if (vec_imm_inst_vec) begin
                        set_vec_imm_buff_vec <= 1;
                        
                        state <= DEC_vec1;
                    end
                    else if (vec_imm_inst_scal) begin
                        set_vec_imm_buff_scal <= 1;
                        
                        state <= DEC_vec1;
                    end
                    else if (scal_imm_inst) begin
                        set_scal_imm_buff <= 1;
                        
                        if(ex_inst)
                            state <= EX_1;
                        else
                            state <= WB_1;
                    end
                end
                DEC_vec1: begin
                    if (vec_imm_inst_vec)
                        set_vec_imm_buff_vec <= 0;
                    state <= DEC_vec2;
                end
                DEC_vec2: begin // Wait for vec imm to be done
                    if (vec_imm_buff_done) begin
                        en_input_blk <= 0;
                        
                        if (ex_inst) begin
                            state <= EX_1;
                        end
                        else
                            state <= WB_1;
                    end
                    
                    if (vec_imm_inst_vec) begin
                        if (input_blk_ready) begin
                            en_input_blk <= 1;
                            
                            state <= DEC_vec3;
                        end
                        else begin
                            set_vec_imm_buff_vec <= 0;
                            en_input_blk <= 0;
                        end
                    end
                end
                DEC_vec3: begin
                    state <= DEC_vec2;
                    set_vec_imm_buff_vec <= 1;
                end
                EX_1: begin 
                    set_scal_imm_buff <= 0;
                    en_vec_reg_bank_a <= 1;
                    
                    if (vec_alu_inst) begin
                        if (vec_scal_inst && imm_inst) begin // scal, immediate
                            en_scal_imm_buff <= 1;
                        end
                        else if (vec_scal_inst && !imm_inst) begin // scal, reg
                            en_scal_acc <= 1;
                        end
                        else if (!vec_scal_inst && imm_inst) begin // vec, immediate
                            en_vec_imm_buff <= 1;
                        end
                        else begin // vec, reg
                            en_vec_reg_bank_b <= 1;
                        end
                        
                        set_vec_alu <= 1;
                        
                        state <= WB_1;
                    end
                    else if (red_alu_inst) begin;
                        set_red_alu <= 1;
                        
                        state <= EX_red;
                    end
                end
                EX_red: begin // wait for red inst to finish
                    en_vec_reg_bank_a <= 0;
                    set_red_alu <= 0;
                    
                    if (red_alu_done) begin
                        state <= WB_1;
                    end
                end
                WB_1: begin
                    set_scal_imm_buff <= 0;
                    en_scal_imm_buff <= 0;
                    en_input_blk <= 0;
                    
                    if (ret_vec_inst) begin // return vec inst
                        en_vec_reg_bank_b <= 1;
                        set_vec_out_buff <= 1;
                        
                        state <= WB_2;
                    end
                    else begin
                        if (red_alu_inst) begin
                            en_red_alu <= 1;
                            
                            if (ret_scal_inst) begin
                                set_output_blk <= 1;
                            end
                            else begin
                                set_scal_acc <= 1;
                            end
                        end
                        else if (vec_alu_inst) begin // Vec alu inst
                            en_vec_alu <= 1;
                            set_vec_reg_bank <= 1;
                        end
                        else begin // load/save inst
                            if (imm_inst) begin
                                en_vec_imm_buff <= 1;
                            end 
                            else begin
                                en_vec_reg_bank_b <= 1;
                            end
                            
                            set_vec_reg_bank <= 1;
                        end
                        
                        state <= FET_lo_1;
                    end
                end
                WB_2: begin
                    en_vec_reg_bank_b <= 0;
                    set_vec_out_buff <= 0;
                    
                    state <= WB_vec_ret;
                end
                WB_vec_ret: begin
                    if( vec_out_buff_count > 0) begin
                        set_output_blk <= 1;
                    end
                    else begin
                        set_output_blk <= 0;
                        state <= FET_lo_1;
                    end
                end
                default: begin 
                    en_vec_imm_buff   <= 0;
                    en_scal_imm_buff  <= 0;
                    en_vec_reg_bank_a <= 0;
                    en_vec_reg_bank_b <= 0;
                    en_vec_alu        <= 0;
                    en_red_alu        <= 0;
                    en_scal_acc       <= 0;
                    en_input_blk      <= 0;
                
                    set_inst_hi           <= 0;
                    set_inst_lo           <= 0;
                    set_vec_imm_buff_vec  <= 0;
                    set_vec_imm_buff_scal <= 0;
                    set_scal_imm_buff     <= 0;
                    set_vec_reg_bank      <= 0;
                    set_vec_alu           <= 0;
                    set_red_alu           <= 0;
                    set_scal_acc          <= 0;
                    set_vec_out_buff      <= 0;
                    set_output_blk        <= 0;
                    
                    state <= FET_lo_1;
                end
            endcase
        end
    end
endmodule
