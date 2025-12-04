module memory_module_2 (
    input clk,
    input rst,

    // --------------------------------------------------------
    // INPUTS (Matrix 4x4: 16 + Filter 3x3: 9 = 25)
    // --------------------------------------------------------
    input [7:0] A11, input [7:0] A12, input [7:0] A13, input [7:0] A14,
    input [7:0] A21, input [7:0] A22, input [7:0] A23, input [7:0] A24,
    input [7:0] A31, input [7:0] A32, input [7:0] A33, input [7:0] A34,
    input [7:0] A41, input [7:0] A42, input [7:0] A43, input [7:0] A44,

    input [7:0] B11, input [7:0] B12, input [7:0] B13,
    input [7:0] B21, input [7:0] B22, input [7:0] B23,
    input [7:0] B31, input [7:0] B32, input [7:0] B33,

    // --------------------------------------------------------
    // OUTPUTS (wire outputs from reg8 modules)
    // --------------------------------------------------------
    output [7:0] out_A11, output [7:0] out_A12, output [7:0] out_A13, output [7:0] out_A14,
    output [7:0] out_A21, output [7:0] out_A22, output [7:0] out_A23, output [7:0] out_A24,
    output [7:0] out_A31, output [7:0] out_A32, output [7:0] out_A33, output [7:0] out_A34,
    output [7:0] out_A41, output [7:0] out_A42, output [7:0] out_A43, output [7:0] out_A44,

    output [7:0] out_B11, output [7:0] out_B12, output [7:0] out_B13,
    output [7:0] out_B21, output [7:0] out_B22, output [7:0] out_B23,
    output [7:0] out_B31, output [7:0] out_B32, output [7:0] out_B33
);

    parameter false = 1'b0;

    // --------------------------------------------------------
    // INSTANTIATE reg8 modules for Matrix A (4x4)
    // --------------------------------------------------------
    reg8 memory_A11(.in(A11), .clk(clk), .rst(rst), .clear(false), .out(out_A11));
    reg8 memory_A12(.in(A12), .clk(clk), .rst(rst), .clear(false), .out(out_A12));
    reg8 memory_A13(.in(A13), .clk(clk), .rst(rst), .clear(false), .out(out_A13));
    reg8 memory_A14(.in(A14), .clk(clk), .rst(rst), .clear(false), .out(out_A14));

    reg8 memory_A21(.in(A21), .clk(clk), .rst(rst), .clear(false), .out(out_A21));
    reg8 memory_A22(.in(A22), .clk(clk), .rst(rst), .clear(false), .out(out_A22));
    reg8 memory_A23(.in(A23), .clk(clk), .rst(rst), .clear(false), .out(out_A23));
    reg8 memory_A24(.in(A24), .clk(clk), .rst(rst), .clear(false), .out(out_A24));

    reg8 memory_A31(.in(A31), .clk(clk), .rst(rst), .clear(false), .out(out_A31));
    reg8 memory_A32(.in(A32), .clk(clk), .rst(rst), .clear(false), .out(out_A32));
    reg8 memory_A33(.in(A33), .clk(clk), .rst(rst), .clear(false), .out(out_A33));
    reg8 memory_A34(.in(A34), .clk(clk), .rst(rst), .clear(false), .out(out_A34));

    reg8 memory_A41(.in(A41), .clk(clk), .rst(rst), .clear(false), .out(out_A41));
    reg8 memory_A42(.in(A42), .clk(clk), .rst(rst), .clear(false), .out(out_A42));
    reg8 memory_A43(.in(A43), .clk(clk), .rst(rst), .clear(false), .out(out_A43));
    reg8 memory_A44(.in(A44), .clk(clk), .rst(rst), .clear(false), .out(out_A44));

    // --------------------------------------------------------
    // INSTANTIATE reg8 modules for Filter B (3x3)
    // --------------------------------------------------------
    reg8 memory_B11(.in(B11), .clk(clk), .rst(rst), .clear(false), .out(out_B11));
    reg8 memory_B12(.in(B12), .clk(clk), .rst(rst), .clear(false), .out(out_B12));
    reg8 memory_B13(.in(B13), .clk(clk), .rst(rst), .clear(false), .out(out_B13));

    reg8 memory_B21(.in(B21), .clk(clk), .rst(rst), .clear(false), .out(out_B21));
    reg8 memory_B22(.in(B22), .clk(clk), .rst(rst), .clear(false), .out(out_B22));
    reg8 memory_B23(.in(B23), .clk(clk), .rst(rst), .clear(false), .out(out_B23));

    reg8 memory_B31(.in(B31), .clk(clk), .rst(rst), .clear(false), .out(out_B31));
    reg8 memory_B32(.in(B32), .clk(clk), .rst(rst), .clear(false), .out(out_B32));
    reg8 memory_B33(.in(B33), .clk(clk), .rst(rst), .clear(false), .out(out_B33));

endmodule
