// Weight Stationary 2x2 Systolic Array
module sa2x2 (
    input clk,
    input rst,
    input clear,
    input weight_load,  // Weight loading enable signal

    // Weight inputs for each PE (4 weights total)
    input [7:0] w_11, w_12,  // Row 1 weights
    input [7:0] w_21, w_22,  // Row 2 weights

    // Activation inputs (flow horizontally, 2 rows)
    input [7:0] act_in1,  // Activation input for row 1
    input [7:0] act_in2,  // Activation input for row 2

    // Partial sum inputs (flow vertically from top, 2 columns)
    input [7:0] psum_in1,  // Partial sum input for column 1
    input [7:0] psum_in2,  // Partial sum input for column 2

    // Partial sum outputs (flow vertically to bottom, 2 columns)
    output [7:0] psum_out1,  // Partial sum output from column 1
    output [7:0] psum_out2   // Partial sum output from column 2
);

    // ========================================
    // Internal Wires for PE Interconnections
    // ========================================
    
    // Activation horizontal flow (left to right)
    // act_h[row][col]: activation output from PE[row][col]
    wire [7:0] act_h_11;  // Row 1: PE11->PE12
    wire [7:0] act_h_21;  // Row 2: PE21->PE22
    
    // Partial sum vertical flow (top to bottom)
    // psum_v[row][col]: partial sum output from PE[row][col]
    wire [7:0] psum_v_11, psum_v_12;  // Row 1->Row 2

    // ========================================
    // 2x2 PE Array - Weight Stationary
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
        .a_out(), .psum_out(psum_v_12)  // a_out unused (end of row)
    );
    
    // Row 2
    pe pe_21(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_in2), .weight_in(w_21), .psum_in(psum_v_11),
        .a_out(act_h_21), .psum_out(psum_out1)  // psum_out goes to output
    );
    
    pe pe_22(
        .clk(clk), .rst(rst), .clear(clear), .weight_load(weight_load),
        .a_in(act_h_21), .weight_in(w_22), .psum_in(psum_v_12),
        .a_out(), .psum_out(psum_out2)  // a_out unused, psum_out goes to output
    );

endmodule
