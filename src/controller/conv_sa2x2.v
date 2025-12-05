module conv_2x2 (
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
    // SA_2x2 Instantiation
    // ========================================
    // SA_2x2 signals
    wire [7:0] sa_w_in1, sa_w_in2;
    wire [7:0] sa_act_in1, sa_act_in2;
    wire [7:0] sa_psum_in1, sa_psum_in2;
    wire [7:0] sa_psum_out1, sa_psum_out2;
    
    // SA_2x2 instantiation
    sa2x2 sa_inst (
        .clk(clk),
        .rst(rst),
        .clear(1'b0),
        .weight_load(weight_load),
        
        // Weight inputs
        .w_in1(sa_w_in1),
        .w_in2(sa_w_in2),
        
        // Activation inputs
        .act_in1(sa_act_in1),
        .act_in2(sa_act_in2),
        
        // Partial sum inputs
        .psum_in1(sa_psum_in1),
        .psum_in2(sa_psum_in2),
        
        // Partial sum outputs
        .psum_out1(sa_psum_out1),
        .psum_out2(sa_psum_out2)
    );
    
    // For now, assign dummy outputs
    assign conv_out_11 = 8'd0;
    assign conv_out_12 = 8'd0;
    assign conv_out_21 = 8'd0;
    assign conv_out_22 = 8'd0;
    
    // Temporary assignments for SA inputs (to avoid floating)
    assign sa_w_in1 = 8'd0;
    assign sa_w_in2 = 8'd0;
    assign sa_act_in1 = 8'd0;
    assign sa_act_in2 = 8'd0;
    assign sa_psum_in1 = 8'd0;
    assign sa_psum_in2 = 8'd0;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            done <= 1'b0;
        else
            done <= 1'b0;  // Placeholder
    end

endmodule