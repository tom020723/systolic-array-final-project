module conv_3x3 (
    input clk,
    input rst,
    input start,        // Start convolution operation

    // Weight inputs (3 weights for 3 columns)
    input [7:0] w_31, w_32, w_33,  // Bottom row weights (loaded first)
    input [7:0] w_21, w_22, w_23,  // Middle row weights
    input [7:0] w_11, w_12, w_13,  // Top row weights (loaded last)

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
    reg [4:0] state, next_state;
    
    // State definitions
    parameter IDLE = 5'd0;
    
    // Weight loading states (3 cycles)
    parameter WEIGHT_LOAD_1 = 5'd1;
    parameter WEIGHT_LOAD_2 = 5'd2;
    parameter WEIGHT_LOAD_3 = 5'd3;
    
    // Convolution computation (14 cycles for all 4 outputs)
    parameter CONV_1  = 5'd4;
    parameter CONV_2  = 5'd5;
    parameter CONV_3  = 5'd6;
    parameter CONV_4  = 5'd7;
    parameter CONV_5  = 5'd8;
    parameter CONV_6  = 5'd9;
    parameter CONV_7  = 5'd10;
    parameter CONV_8  = 5'd11;
    parameter CONV_9  = 5'd12;
    parameter CONV_10 = 5'd13;
    parameter CONV_11 = 5'd14;
    parameter CONV_12 = 5'd15;
    parameter CONV_13 = 5'd16;
    parameter CONV_14 = 5'd17;
    parameter END_CONV = 5'd18;
    
    parameter DONE = 5'd19;

    // ========================================
    // SA3x3 Inputs/Outputs
    // ========================================
    reg [7:0] w_in1, w_in2, w_in3;
    reg [7:0] act_in1, act_in2, act_in3;
    reg [7:0] psum_in1, psum_in2, psum_in3;
    wire [7:0] psum_out1, psum_out2, psum_out3;
    reg clear, weight_load;

    // ========================================
    // Instantiate 3x3 Systolic Array
    // ========================================
    sa3x3 sa3x3_inst (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .weight_load(weight_load),
        .w_in1(w_in1), .w_in2(w_in2), .w_in3(w_in3),
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
    reg [7:0] acc_11, acc_12, acc_21, acc_22;
    
    // Output assignment
    assign conv_out_11 = acc_11;
    assign conv_out_12 = acc_12;
    assign conv_out_21 = acc_21;
    assign conv_out_22 = acc_22;

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
                    next_state = WEIGHT_LOAD_1;
                else
                    next_state = IDLE;
            end
            
            // Weight Loading
            WEIGHT_LOAD_1: next_state = WEIGHT_LOAD_2;
            WEIGHT_LOAD_2: next_state = WEIGHT_LOAD_3;
            WEIGHT_LOAD_3: next_state = CONV_1;
            
            // Convolution cycles
            CONV_1:  next_state = CONV_2;
            CONV_2:  next_state = CONV_3;
            CONV_3:  next_state = CONV_4;
            CONV_4:  next_state = CONV_5;
            CONV_5:  next_state = CONV_6;
            CONV_6:  next_state = CONV_7;
            CONV_7:  next_state = CONV_8;
            CONV_8:  next_state = CONV_9;
            CONV_9:  next_state = CONV_10;
            CONV_10: next_state = CONV_11;
            CONV_11: next_state = CONV_12;
            CONV_12: next_state = CONV_13;
            CONV_13: next_state = CONV_14;
            CONV_14: next_state = END_CONV;
            END_CONV: next_state = DONE;
            
            DONE: next_state = IDLE;
            
            default: next_state = IDLE;
        endcase
    end

    // ========================================
    // Control Logic
    // ========================================
    always @(*) begin
        // Default values
        w_in1 = 8'd0;
        w_in2 = 8'd0;
        w_in3 = 8'd0;
        act_in1 = 8'd0;
        act_in2 = 8'd0;
        act_in3 = 8'd0;
        psum_in1 = 8'd0;
        psum_in2 = 8'd0;
        psum_in3 = 8'd0;
        clear = 1'b0;
        weight_load = 1'b0;
        done = 1'b0;

        case (state)
            IDLE: begin
                clear = 1'b1;
            end
            
            // Weight Loading (3 cycles)
            WEIGHT_LOAD_1: begin
                weight_load = 1'b1;
                w_in1 = w_13;
                w_in2 = w_12;
                w_in3 = w_11;
            end
            
            WEIGHT_LOAD_2: begin
                weight_load = 1'b1;
                w_in1 = w_23;
                w_in2 = w_22;
                w_in3 = w_21;
            end
            
            WEIGHT_LOAD_3: begin
                weight_load = 1'b1;
                w_in1 = w_33;
                w_in2 = w_32;
                w_in3 = w_31;
            end
            
            // Convolution - Feed all 4 3x3 windows in parallel
            // 4x4 Input Matrix: [1  2  3  4 ]
            //                   [5  6  7  8 ]
            //                   [9  10 11 12]
            //                   [13 14 15 16]
            
            CONV_1: begin
                act_in1 = in_13;  // 3
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_2: begin
                act_in1 = in_12;  // 2
                act_in2 = in_23;  // 7
                act_in3 = 8'd0;
            end
            
            CONV_3: begin
                act_in1 = in_11;  // 1
                act_in2 = in_22;  // 6
                act_in3 = in_33;  // 11
            end
            
            CONV_4: begin
                act_in1 = in_14;  // 4
                act_in2 = in_21;  // 5
                act_in3 = in_32;  // 10
            end
            
            CONV_5: begin  // Result: C11
                act_in1 = in_13;  // 3
                act_in2 = in_24;  // 8
                act_in3 = in_31;  // 9
            end
            
            CONV_6: begin
                act_in1 = in_12;  // 2
                act_in2 = in_23;  // 7
                act_in3 = in_34;  // 12
            end
            
            CONV_7: begin
                act_in1 = in_23;  // 7
                act_in2 = in_22;  // 6
                act_in3 = in_33;  // 11
            end
            
            CONV_8: begin  // Result: C12
                act_in1 = in_22;  // 6
                act_in2 = in_33;  // 11
                act_in3 = in_32;  // 10
            end
            
            CONV_9: begin
                act_in1 = in_21;  // 5
                act_in2 = in_32;  // 10
                act_in3 = in_43;  // 15
            end
            
            CONV_10: begin
                act_in1 = in_24;  // 8
                act_in2 = in_31;  // 9
                act_in3 = in_42;  // 14
            end
            
            CONV_11: begin  // Result: C21
                act_in1 = in_23;  // 7
                act_in2 = in_34;  // 12
                act_in3 = in_41;  // 13
            end
            
            CONV_12: begin
                act_in1 = in_22;  // 6
                act_in2 = in_33;  // 11
                act_in3 = in_44;  // 16
            end
            
            CONV_13: begin
                act_in1 = 8'd0;
                act_in2 = in_32;  // 10
                act_in3 = in_43;  // 15
            end
            
            CONV_14: begin  // Result: C22
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = in_42;  // 14
            end

            END_CONV: begin
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            DONE: begin
                done = 1'b1;
            end
        endcase
    end
    
    // ========================================
    // Result Capture Logic (with pipeline delay consideration)
    // ========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc_11 <= 8'd0;
            acc_12 <= 8'd0;
            acc_21 <= 8'd0;
            acc_22 <= 8'd0;
        end
        else if (state == IDLE) begin
            acc_11 <= 8'd0;
            acc_12 <= 8'd0;
            acc_21 <= 8'd0;
            acc_22 <= 8'd0;
        end
        else if (state == CONV_6) begin
            // At CONV_6 (1 clk after CONV_5), sum_result contains window_11 result
            acc_11 <= sum_result;
        end
        else if (state == CONV_9) begin
            // At CONV_9 (1 clk after CONV_8), sum_result contains window_12 result
            acc_12 <= sum_result;
        end
        else if (state == CONV_12) begin
            // At CONV_12 (1 clk after CONV_11), sum_result contains window_21 result
            acc_21 <= sum_result;
        end
        else if (state == END_CONV) begin
            // At END_CONV (1 clk after CONV_14), sum_result contains window_22 result
            acc_22 <= sum_result;
        end
    end

endmodule