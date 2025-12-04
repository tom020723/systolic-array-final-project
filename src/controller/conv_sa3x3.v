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
    
    // Convolution 11 (5 cycles)
    parameter CONV_11_1 = 5'd4;
    parameter CONV_11_2 = 5'd5;
    parameter CONV_11_3 = 5'd6;
    parameter CONV_11_4 = 5'd7;
    parameter CONV_11_5 = 5'd8;
    
    // Convolution 12 (5 cycles)
    parameter CONV_12_1 = 5'd9;
    parameter CONV_12_2 = 5'd10;
    parameter CONV_12_3 = 5'd11;
    parameter CONV_12_4 = 5'd12;
    parameter CONV_12_5 = 5'd13;
    
    // Convolution 21 (5 cycles)
    parameter CONV_21_1 = 5'd14;
    parameter CONV_21_2 = 5'd15;
    parameter CONV_21_3 = 5'd16;
    parameter CONV_21_4 = 5'd17;
    parameter CONV_21_5 = 5'd18;
    
    // Convolution 22 (5 cycles)
    parameter CONV_22_1 = 5'd19;
    parameter CONV_22_2 = 5'd20;
    parameter CONV_22_3 = 5'd21;
    parameter CONV_22_4 = 5'd22;
    parameter CONV_22_5 = 5'd23;
    
    parameter DONE = 5'd24;

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
                    next_state = WEIGHT_LOAD_1;
                else
                    next_state = IDLE;
            end
            
            // Weight Loading
            WEIGHT_LOAD_1: next_state = WEIGHT_LOAD_2;
            WEIGHT_LOAD_2: next_state = WEIGHT_LOAD_3;
            WEIGHT_LOAD_3: next_state = CONV_11_1;
            
            // Conv 11
            CONV_11_1: next_state = CONV_11_2;
            CONV_11_2: next_state = CONV_11_3;
            CONV_11_3: next_state = CONV_11_4;
            CONV_11_4: next_state = CONV_11_5;
            CONV_11_5: next_state = CONV_12_1;
            
            // Conv 12
            CONV_12_1: next_state = CONV_12_2;
            CONV_12_2: next_state = CONV_12_3;
            CONV_12_3: next_state = CONV_12_4;
            CONV_12_4: next_state = CONV_12_5;
            CONV_12_5: next_state = CONV_21_1;
            
            // Conv 21
            CONV_21_1: next_state = CONV_21_2;
            CONV_21_2: next_state = CONV_21_3;
            CONV_21_3: next_state = CONV_21_4;
            CONV_21_4: next_state = CONV_21_5;
            CONV_21_5: next_state = CONV_22_1;
            
            // Conv 22
            CONV_22_1: next_state = CONV_22_2;
            CONV_22_2: next_state = CONV_22_3;
            CONV_22_3: next_state = CONV_22_4;
            CONV_22_4: next_state = CONV_22_5;
            CONV_22_5: next_state = DONE;
            
            DONE: next_state = IDLE;
            
            default: next_state = IDLE;
        endcase
    end

    // ========================================
    // Output Control Logic
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
            // Weight Loading (3 cycles)
            // ========================================
            WEIGHT_LOAD_1: begin
                weight_load = 1'b1;
                w_in1 = w_31;  // Bottom row to column 1
                w_in2 = w_32;  // Bottom row to column 2
                w_in3 = w_33;  // Bottom row to column 3
            end
            
            WEIGHT_LOAD_2: begin
                weight_load = 1'b1;
                w_in1 = w_21;  // Middle row to column 1
                w_in2 = w_22;  // Middle row to column 2
                w_in3 = w_23;  // Middle row to column 3
            end
            
            WEIGHT_LOAD_3: begin
                weight_load = 1'b1;
                w_in1 = w_11;  // Top row to column 1
                w_in2 = w_12;  // Top row to column 2
                w_in3 = w_13;  // Top row to column 3
            end
            
            // ========================================
            // Convolution Output 11 (top-left 3x3)
            // ========================================
            CONV_11_1: begin
                act_in1 = in_31;
                act_in2 = 8'd0;
                act_in3 = 8'd0;
            end
            
            CONV_11_2: begin
                act_in1 = in_21;
                act_in2 = in_32;
                act_in3 = 8'd0;
            end
            
            CONV_11_3: begin
                act_in1 = in_11;
                act_in2 = in_22;
                act_in3 = in_33;
            end
            
            CONV_11_4: begin
                act_in1 = 8'd0;
                act_in2 = in_12;
                act_in3 = in_23;
            end
            
            CONV_11_5: begin
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = in_13;
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
            end
            
            CONV_12_4: begin
                act_in1 = 8'd0;
                act_in2 = in_13;
                act_in3 = in_24;
            end
            
            CONV_12_5: begin
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = in_14;
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
            end
            
            CONV_21_4: begin
                act_in1 = 8'd0;
                act_in2 = in_22;
                act_in3 = in_33;
            end
            
            CONV_21_5: begin
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = in_23;
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
            end
            
            CONV_22_4: begin
                act_in1 = 8'd0;
                act_in2 = in_23;
                act_in3 = in_34;
            end
            
            CONV_22_5: begin
                act_in1 = 8'd0;
                act_in2 = 8'd0;
                act_in3 = in_24;
                reg_enable_22 = 1'b1;  // Store result
            end
            
            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule