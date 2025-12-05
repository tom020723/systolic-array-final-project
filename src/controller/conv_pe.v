`timescale 1ns/1ps

module conv_pe (
    input clk,
    input rst,
    input start,

    // Weight inputs (3x3 kernel)
    input [7:0] w_11, w_12, w_13,
    input [7:0] w_21, w_22, w_23,
    input [7:0] w_31, w_32, w_33,

    // Input map (4x4)
    input [7:0] in_11, in_12, in_13, in_14,
    input [7:0] in_21, in_22, in_23, in_24,
    input [7:0] in_31, in_32, in_33, in_34,
    input [7:0] in_41, in_42, in_43, in_44,

    // Output (2x2 convolution results)
    output [7:0] conv_out_11, conv_out_12,
    output [7:0] conv_out_21, conv_out_22,
    output reg done
);

    // ========================================
    // Single PE instance
    // ========================================
    wire [7:0] pe_out;
    reg [7:0] pe_a_in, pe_w_in;
    
    pe #(.DATA_W(8), .ACC_W(8)) pe_inst (
        .clk(clk),
        .rst(rst),
        .clear(1'b0),
        .weight_load(1'b1),
        .a_in(pe_a_in),
        .weight_in(pe_w_in),
        .psum_in(8'd0),
        .a_out(),
        .weight_out(),
        .psum_out(pe_out)
    );
    
    // ========================================
    // Delayed PE output (2-cycle latency)
    // ========================================
    reg [7:0] pe_out_d1, pe_out_d2;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pe_out_d1 <= 8'd0;
            pe_out_d2 <= 8'd0;
        end
        else begin
            pe_out_d1 <= pe_out;
            pe_out_d2 <= pe_out_d1;
        end
    end
    
    // ========================================
    // State Machine (37 cycles: 1 initial W_LOAD + 36 MUL with overlapped w/a)
    // ========================================
    reg [5:0] state, next_state;
    
    parameter IDLE = 6'd0;
    parameter MUL_1  = 6'd1;
    parameter MUL_2  = 6'd2;
    parameter MUL_3  = 6'd3;
    parameter MUL_4  = 6'd4;
    parameter MUL_5  = 6'd5;
    parameter MUL_6  = 6'd6;
    parameter MUL_7  = 6'd7;
    parameter MUL_8  = 6'd8;
    parameter MUL_9  = 6'd9;
    
    parameter MUL_10 = 6'd10;
    parameter MUL_11 = 6'd11;
    parameter MUL_12 = 6'd12;
    parameter MUL_13 = 6'd13;
    parameter MUL_14 = 6'd14;
    parameter MUL_15 = 6'd15;
    parameter MUL_16 = 6'd16;
    parameter MUL_17 = 6'd17;
    parameter MUL_18 = 6'd18;
    
    parameter MUL_19 = 6'd19;
    parameter MUL_20 = 6'd20;
    parameter MUL_21 = 6'd21;
    parameter MUL_22 = 6'd22;
    parameter MUL_23 = 6'd23;
    parameter MUL_24 = 6'd24;
    parameter MUL_25 = 6'd25;
    parameter MUL_26 = 6'd26;
    parameter MUL_27 = 6'd27;
    
    parameter MUL_28 = 6'd28;
    parameter MUL_29 = 6'd29;
    parameter MUL_30 = 6'd30;
    parameter MUL_31 = 6'd31;
    parameter MUL_32 = 6'd32;
    parameter MUL_33 = 6'd33;
    parameter MUL_34 = 6'd34;
    parameter MUL_35 = 6'd35;
    parameter MUL_36 = 6'd36;
    
    parameter WAIT_1 = 6'd37;
    parameter WAIT_2 = 6'd38;
    parameter WAIT_ACC = 6'd39;
    parameter DONE_STATE = 6'd40;
    
    // ========================================
    // State Update
    // ========================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    // ========================================
    // Next State Logic
    // ========================================
    always @(*) begin
        case (state)
            IDLE: next_state = (start) ? MUL_1 : IDLE;
            MUL_1:  next_state = MUL_2;
            MUL_2:  next_state = MUL_3;
            MUL_3:  next_state = MUL_4;
            MUL_4:  next_state = MUL_5;
            MUL_5:  next_state = MUL_6;
            MUL_6:  next_state = MUL_7;
            MUL_7:  next_state = MUL_8;
            MUL_8:  next_state = MUL_9;
            MUL_9:  next_state = MUL_10;
            MUL_10: next_state = MUL_11;
            MUL_11: next_state = MUL_12;
            MUL_12: next_state = MUL_13;
            MUL_13: next_state = MUL_14;
            MUL_14: next_state = MUL_15;
            MUL_15: next_state = MUL_16;
            MUL_16: next_state = MUL_17;
            MUL_17: next_state = MUL_18;
            MUL_18: next_state = MUL_19;
            MUL_19: next_state = MUL_20;
            MUL_20: next_state = MUL_21;
            MUL_21: next_state = MUL_22;
            MUL_22: next_state = MUL_23;
            MUL_23: next_state = MUL_24;
            MUL_24: next_state = MUL_25;
            MUL_25: next_state = MUL_26;
            MUL_26: next_state = MUL_27;
            MUL_27: next_state = MUL_28;
            MUL_28: next_state = MUL_29;
            MUL_29: next_state = MUL_30;
            MUL_30: next_state = MUL_31;
            MUL_31: next_state = MUL_32;
            MUL_32: next_state = MUL_33;
            MUL_33: next_state = MUL_34;
            MUL_34: next_state = MUL_35;
            MUL_35: next_state = MUL_36;
            MUL_36: next_state = WAIT_1;
            WAIT_1: next_state = WAIT_2;
            WAIT_2: next_state = WAIT_ACC;
            WAIT_ACC: next_state = DONE_STATE;
            DONE_STATE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end
    
    // ========================================
    // Input Scheduling & Accumulation Registers
    // ========================================
    reg [15:0] acc_11, acc_12, acc_21, acc_22;
    
    always @(*) begin
        pe_a_in = 8'd0;
        pe_w_in = 8'd0;
        
        case (state)
            // Window C11: w*[1,2,3;5,6,7;9,10,11] with flipped weights
            // Flipped: [w33, w32, w31; w23, w22, w21; w13, w12, w11]
            // MUL_1: w_in=w33, a_in=0
            // MUL_2: w_in=w32, a_in=in_11 (w33 is in w_reg now)
            // MUL_3: w_in=w31, a_in=in_12 (w32 is in w_reg now)
            MUL_1:  begin pe_w_in = w_33; end
            MUL_2:  begin pe_w_in = w_32; pe_a_in = in_11; end
            MUL_3:  begin pe_w_in = w_31; pe_a_in = in_12; end
            MUL_4:  begin pe_w_in = w_23; pe_a_in = in_13; end
            MUL_5:  begin pe_w_in = w_22; pe_a_in = in_21; end
            MUL_6:  begin pe_w_in = w_21; pe_a_in = in_22; end
            MUL_7:  begin pe_w_in = w_13; pe_a_in = in_23; end
            MUL_8:  begin pe_w_in = w_12; pe_a_in = in_31; end
            MUL_9:  begin pe_w_in = w_11; pe_a_in = in_32; end
            
            // Window C12: w*[2,3,4;6,7,8;10,11,12] with flipped weights
            MUL_10: begin pe_w_in = w_33; pe_a_in = in_33; end
            MUL_11: begin pe_w_in = w_32; pe_a_in = in_12; end
            MUL_12: begin pe_w_in = w_31; pe_a_in = in_13; end
            MUL_13: begin pe_w_in = w_23; pe_a_in = in_14; end
            MUL_14: begin pe_w_in = w_22; pe_a_in = in_22; end
            MUL_15: begin pe_w_in = w_21; pe_a_in = in_23; end
            MUL_16: begin pe_w_in = w_13; pe_a_in = in_24; end
            MUL_17: begin pe_w_in = w_12; pe_a_in = in_32; end
            MUL_18: begin pe_w_in = w_11; pe_a_in = in_33; end
            
            // Window C21: w*[5,6,7;9,10,11;13,14,15] with flipped weights
            MUL_19: begin pe_w_in = w_33; pe_a_in = in_34; end
            MUL_20: begin pe_w_in = w_32; pe_a_in = in_21; end
            MUL_21: begin pe_w_in = w_31; pe_a_in = in_22; end
            MUL_22: begin pe_w_in = w_23; pe_a_in = in_23; end
            MUL_23: begin pe_w_in = w_22; pe_a_in = in_31; end
            MUL_24: begin pe_w_in = w_21; pe_a_in = in_32; end
            MUL_25: begin pe_w_in = w_13; pe_a_in = in_33; end
            MUL_26: begin pe_w_in = w_12; pe_a_in = in_41; end
            MUL_27: begin pe_w_in = w_11; pe_a_in = in_42; end
            
            // Window C22: w*[6,7,8;10,11,12;14,15,16] with flipped weights
            MUL_28: begin pe_w_in = w_33; pe_a_in = in_43; end
            MUL_29: begin pe_w_in = w_32; pe_a_in = in_22; end
            MUL_30: begin pe_w_in = w_31; pe_a_in = in_23; end
            MUL_31: begin pe_w_in = w_23; pe_a_in = in_24; end
            MUL_32: begin pe_w_in = w_22; pe_a_in = in_32; end
            MUL_33: begin pe_w_in = w_21; pe_a_in = in_33; end
            MUL_34: begin pe_w_in = w_13; pe_a_in = in_34; end
            MUL_35: begin pe_w_in = w_12; pe_a_in = in_42; end
            MUL_36: begin pe_w_in = w_11; pe_a_in = in_43; end
            
            WAIT_1: begin pe_a_in = in_44; end  // Last activation input
        endcase
    end
    
    // ========================================
    // Accumulation Logic
    // ========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_11 <= 16'd0;
            acc_12 <= 16'd0;
            acc_21 <= 16'd0;
            acc_22 <= 16'd0;
        end
        else if (state == IDLE) begin
            acc_11 <= 16'd0;
            acc_12 <= 16'd0;
            acc_21 <= 16'd0;
            acc_22 <= 16'd0;
        end
        else begin
            // PE 4-cycle latency: 
            // MUL_1: w_in=w33
            // MUL_2: w_in=w32, a_in=in_11 (w33 in w_reg)
            // MUL_3: w_in=w31, a_in=in_12 (w32 in w_reg, w33*in_11 computing)
            // MUL_4: w_in=w23, a_in=in_13 (w31 in w_reg, w32*in_12 computing, w33*in_11 in reg_psum)
            // MUL_5: result of w33*in_11 appears in pe_out_d2
            
            // Window C11: MUL_1-9, results appear from MUL_5 to MUL_13 (9 results)
            if (state >= MUL_5 && state <= MUL_13) begin
                acc_11 <= acc_11 + pe_out_d2;
            end
            
            // Window C12: MUL_10-18, results appear from MUL_14 to MUL_22 (9 results)
            if (state >= MUL_14 && state <= MUL_22) begin
                acc_12 <= acc_12 + pe_out_d2;
            end
            
            // Window C21: MUL_19-27, results appear from MUL_23 to MUL_31 (9 results)
            if (state >= MUL_23 && state <= MUL_31) begin
                acc_21 <= acc_21 + pe_out_d2;
            end
            
            // Window C22: MUL_28-36, results appear from MUL_32 to WAIT_1 (9 results)
            // MUL_36의 결과가 4 클럭 후인 WAIT_1(37+3=40)에 나타남
            if (state >= MUL_32 && state <= DONE_STATE) begin
                acc_22 <= acc_22 + pe_out_d2;
            end
        end
    end
    
    // ========================================
    // Output Assignment
    // ========================================
    assign conv_out_11 = acc_11[7:0];
    assign conv_out_12 = acc_12[7:0];
    assign conv_out_21 = acc_21[7:0];
    assign conv_out_22 = acc_22[7:0];
    
    // Done signal
    always @(posedge clk or posedge rst) begin
        if (rst)
            done <= 1'b0;
        else if (state == DONE_STATE)
            done <= 1'b1;
        else
            done <= 1'b0;
    end

endmodule
