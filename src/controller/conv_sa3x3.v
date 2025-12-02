module conv_3x3 (
    input clk,
    input rst,
    input start,        // Start convolution operation
    input weight_load,  // Weight loading enable signal

    // Weight inputs for each PE (9 weights total)
    input [7:0] w_11, w_12, w_13,  // Row 1 weights
    input [7:0] w_21, w_22, w_23,  // Row 2 weights
    input [7:0] w_31, w_32, w_33,  // Row 3 weights

    // input map(4x4)
    input [7:0] in_11, in_12, in_13, in_14,
    input [7:0] in_21, in_22, in_23, in_24,
    input [7:0] in_31, in_32, in_33, in_34,
    input [7:0] in_41, in_42, in_43, in_44,

    // Output of the convolution operation
    output [7:0] conv_out_11, conv_out_12,
    output [7:0] conv_out_21, conv_out_22,
    output reg done     // Convolution complete signal
);

    // ========================================
    // State Machine
    // ========================================
    reg [3:0] state, next_state;
    
    // State definitions
    parameter IDLE = 4'd0;
    parameter CONV_11_1 = 4'd1;  // conv_out_11 calculation
    parameter CONV_11_2 = 4'd2;
    parameter CONV_11_3 = 4'd3;
    parameter CONV_12_1 = 4'd4;  // conv_out_12 calculation
    parameter CONV_12_2 = 4'd5;
    parameter CONV_12_3 = 4'd6;
    parameter CONV_21_1 = 4'd7;  // conv_out_21 calculation
    parameter CONV_21_2 = 4'd8;
    parameter CONV_21_3 = 4'd9;
    parameter CONV_22_1 = 4'd10; // conv_out_22 calculation
    parameter CONV_22_2 = 4'd11;
    parameter CONV_22_3 = 4'd12;
    parameter DONE = 4'd13;

    // ========================================
    // SA3x3 Inputs/Outputs
    // ========================================
    reg [7:0] act_in1, act_in2, act_in3;
    reg [7:0] psum_in1, psum_in2, psum_in3;
    wire [7:0] psum_out1, psum_out2, psum_out3;
    reg clear;

    // ========================================
    // Instantiate 3x3 Systolic Array
    // ========================================
    sa3x3 sa3x3_inst (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .weight_load(weight_load),
        .w_11(w_11), .w_12(w_12), .w_13(w_13),
        .w_21(w_21), .w_22(w_22), .w_23(w_23),
        .w_31(w_31), .w_32(w_32), .w_33(w_33),
        .act_in1(act_in1),
        .act_in2(act_in2),
        .act_in3(act_in3),
        .psum_in1(psum_in1),
        .psum_in2(psum_in2),
        .psum_in3(psum_in3),
        .psum_out1(psum_out1),
        .psum_out2(psum_out2),
        .psum_out3(psum_out3)
    );

    // ========================================
    // Adder for combining 3 outputs
    // ========================================
    wire [7:0] sum_12, sum_result;
    
    fadd8 adder1 (.a(psum_out1), .b(psum_out2), .out(sum_12));
    fadd8 adder2 (.a(sum_12), .b(psum_out3), .out(sum_result));

    // ========================================
    // Output Registers
    // ========================================
    reg reg_enable_11, reg_enable_12, reg_enable_21, reg_enable_22;
    
    reg8 out_reg_11 (.clk(clk), .rst(rst), .clear(1'b0), .in(reg_enable_11 ? sum_result : 8'd0), .out(conv_out_11));
    reg8 out_reg_12 (.clk(clk), .rst(rst), .clear(1'b0), .in(reg_enable_12 ? sum_result : 8'd0), .out(conv_out_12));
    reg8 out_reg_21 (.clk(clk), .rst(rst), .clear(1'b0), .in(reg_enable_21 ? sum_result : 8'd0), .out(conv_out_21));
    reg8 out_reg_22 (.clk(clk), .rst(rst), .clear(1'b0), .in(reg_enable_22 ? sum_result : 8'd0), .out(conv_out_22));

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
            IDLE: begin
                if (start)
                    next_state = CONV_11_1;
                else
                    next_state = IDLE;
            end
            
            // Conv 11
            CONV_11_1: next_state = CONV_11_2;
            CONV_11_2: next_state = CONV_11_3;
            CONV_11_3: next_state = CONV_12_1;
            
            // Conv 12
            CONV_12_1: next_state = CONV_12_2;
            CONV_12_2: next_state = CONV_12_3;
            CONV_12_3: next_state = CONV_21_1;
            
            // Conv 21
            CONV_21_1: next_state = CONV_21_2;
            CONV_21_2: next_state = CONV_21_3;
            CONV_21_3: next_state = CONV_22_1;
            
            // Conv 22
            CONV_22_1: next_state = CONV_22_2;
            CONV_22_2: next_state = CONV_22_3;
            CONV_22_3: next_state = DONE;
            
            DONE: next_state = IDLE;
            
            default: next_state = IDLE;
        endcase
    end

    // ========================================
    // Output Control Logic
    // ========================================
    always @(*) begin
        // Default values
        act_in1 = 8'd0;
        act_in2 = 8'd0;
        act_in3 = 8'd0;
        psum_in1 = 8'd0;
        psum_in2 = 8'd0;
        psum_in3 = 8'd0;
        clear = 1'b0;
        reg_enable_11 = 1'b0;
        reg_enable_12 = 1'b0;
        reg_enable_21 = 1'b0;
        reg_enable_22 = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                clear = 1'b1;
            end
            
            // ========================================
            // Convolution Output 11 (top-left 3x3)
            // ========================================
            CONV_11_1: begin
                // Clock 1: Feed row 3 (bottom row of window)
                act_in1 = in_31;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_11_2: begin
                // Clock 2: Feed row 2 and row 3
                act_in1 = in_21;
                act_in2 = in_32;
                act_in3 = 8'd0;
            end
            
            CONV_11_3: begin
                // Clock 3: Feed all three rows
                act_in1 = in_11;
                act_in2 = in_22;
                act_in3 = in_33;
                reg_enable_11 = 1'b1;  // Store result
            end
            
            // ========================================
            // Convolution Output 12 (top-right 3x3)
            // ========================================
            CONV_12_1: begin
                clear = 1'b1;
                act_in1 = in_32;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_12_2: begin
                act_in1 = in_22;
                act_in2 = in_33;
                act_in3 = 8'd0;
            end
            
            CONV_12_3: begin
                act_in1 = in_12;
                act_in2 = in_23;
                act_in3 = in_34;
                reg_enable_12 = 1'b1;  // Store result
            end
            
            // ========================================
            // Convolution Output 21 (bottom-left 3x3)
            // ========================================
            CONV_21_1: begin
                clear = 1'b1;
                act_in1 = in_41;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_21_2: begin
                act_in1 = in_31;
                act_in2 = in_42;
                act_in3 = 8'd0;
            end
            
            CONV_21_3: begin
                act_in1 = in_21;
                act_in2 = in_32;
                act_in3 = in_43;
                reg_enable_21 = 1'b1;  // Store result
            end
            
            // ========================================
            // Convolution Output 22 (bottom-right 3x3)
            // ========================================
            CONV_22_1: begin
                clear = 1'b1;
                act_in1 = in_42;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_22_2: begin
                act_in1 = in_32;
                act_in2 = in_43;
                act_in3 = 8'd0;
            end
            
            CONV_22_3: begin
                act_in1 = in_22;
                act_in2 = in_33;
                act_in3 = in_44;
                reg_enable_22 = 1'b1;  // Store result
            end
            
            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule