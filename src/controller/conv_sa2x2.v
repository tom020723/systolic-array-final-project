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



endmodule