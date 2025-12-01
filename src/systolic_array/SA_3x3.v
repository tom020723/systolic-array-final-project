// Weight Stationary 3x3 Systolic Array
module sa3x3 (
    input clk,
    input rst,
    input clear,
    input weight_load,  // Weight loading enable signal

    // Weight inputs for each PE (9 weights total)
    input [7:0] w_11, w_12, w_13,  // Row 1 weights
    input [7:0] w_21, w_22, w_23,  // Row 2 weights
    input [7:0] w_31, w_32, w_33,  // Row 3 weights

    // Activation inputs (flow horizontally, 3 rows)
    input [7:0] act_in1,  // Activation input for row 1
    input [7:0] act_in2,  // Activation input for row 2
    input [7:0] act_in3,  // Activation input for row 3

    // Partial sum inputs (flow vertically from top, 3 columns)
    input [7:0] psum_in1,  // Partial sum input for column 1
    input [7:0] psum_in2,  // Partial sum input for column 2
    input [7:0] psum_in3,  // Partial sum input for column 3

    // Partial sum outputs (flow vertically to bottom, 3 columns)
    output [7:0] psum_out1,  // Partial sum output from column 1
    output [7:0] psum_out2,  // Partial sum output from column 2
    output [7:0] psum_out3   // Partial sum output from column 3
);

    // ========================================
    // Internal Wires for PE Interconnections
    // ========================================
    
    // Activation horizontal flow (left to right)
    // act_h[row][col]: activation output from PE[row][col]
    wire [7:0] act_h_11, act_h_12;  // Row 1: PE11->PE12->PE13
    wire [7:0] act_h_21, act_h_22;  // Row 2: PE21->PE22->PE23
    wire [7:0] act_h_31, act_h_32;  // Row 3: PE31->PE32->PE33
    
    // Partial sum vertical flow (top to bottom)
    // psum_v[row][col]: partial sum output from PE[row][col]
    wire [7:0] psum_v_11, psum_v_12, psum_v_13;  // Row 1->Row 2
    wire [7:0] psum_v_21, psum_v_22, psum_v_23;  // Row 2->Row 3

    // ========================================
    // 3x3 PE Array - Weight Stationary
    // ========================================
    
    // Row 1
    pe pe_11(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_in1), .weight_in(w_11), .psum_in(psum_in1),
        .a_out(act_h_11), .psum_out(psum_v_11)
    );
    
    pe pe_12(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_11), .weight_in(w_12), .psum_in(psum_in2),
        .a_out(act_h_12), .psum_out(psum_v_12)
    );
    
    pe pe_13(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_12), .weight_in(w_13), .psum_in(psum_in3),
        .a_out(), .psum_out(psum_v_13)  // a_out unused (end of row)
    );
    
    // Row 2
    pe pe_21(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_in2), .weight_in(w_21), .psum_in(psum_v_11),
        .a_out(act_h_21), .psum_out(psum_v_21)
    );
    
    pe pe_22(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_21), .weight_in(w_22), .psum_in(psum_v_12),
        .a_out(act_h_22), .psum_out(psum_v_22)
    );
    
    pe pe_23(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_22), .weight_in(w_23), .psum_in(psum_v_13),
        .a_out(), .psum_out(psum_v_23)  // a_out unused (end of row)
    );
    
    // Row 3
    pe pe_31(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_in3), .weight_in(w_31), .psum_in(psum_v_21),
        .a_out(act_h_31), .psum_out(psum_out1)  // psum_out goes to output
    );
    
    pe pe_32(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_31), .weight_in(w_32), .psum_in(psum_v_22),
        .a_out(act_h_32), .psum_out(psum_out2)  // psum_out goes to output
    );
    
    pe pe_33(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_32), .weight_in(w_33), .psum_in(psum_v_23),
        .a_out(), .psum_out(psum_out3)  // a_out unused, psum_out goes to output
    );

endmodule