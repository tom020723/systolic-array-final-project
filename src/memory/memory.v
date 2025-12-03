module memory_module (

    input clk,
    input rst, 

    input [7:0] A11, input [7:0] A12, input [7:0] A13, input [7:0] A14,
    input [7:0] A21, input [7:0] A22, input [7:0] A23, input [7:0] A24,
    input [7:0] A31, input [7:0] A32, input [7:0] A33, input [7:0] A34,
    input [7:0] A41, input [7:0] A42, input [7:0] A43, input [7:0] A44,
    
    input [7:0] B11, input [7:0] B12, input [7:0] B13,
    input [7:0] B21, input [7:0] B22, input [7:0] B23,
    input [7:0] B31, input [7:0] B32, input [7:0] B33,

   // input [4:0] address1, input [4:0] address2,  input [4:0] address3, 
    
   // output [7:0] out1, output [7:0] out2, output [7:0] out3);
);
 

wire [7:0]  out_A11, out_A12, out_A13, out_A14,
	         	out_A21, out_A22, out_A23, out_A24,
	         	out_A31, out_A32, out_A33, out_A34,
		        out_A41, out_A42, out_A43, out_A44,

		        out_B11, out_B12, out_B13,
		        out_B21, out_B22, out_B23,
		        out_B31, out_B32, out_B33;

// wire [7:0] A1_out, B1_out, A2_out, B2_out, A3_out, B3_out;

parameter zero = 8'b00000000;  // use for the 0 input
parameter false = 1'b0;

// wire [7:0] regout1;
// wire [7:0] regout2;
// wire [7:0] regout3;

/////////////////////////////////////////////////////////////////////////////////////////////////////////
// input matrix 4x4
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

// input filter matrix 3x3
reg8 memory_B11(.in(B11), .clk(clk), .rst(rst), .clear(false), .out(out_B11));
reg8 memory_B12(.in(B12), .clk(clk), .rst(rst), .clear(false), .out(out_B12));
reg8 memory_B13(.in(B13), .clk(clk), .rst(rst), .clear(false), .out(out_B13));

reg8 memory_B21(.in(B21), .clk(clk), .rst(rst), .clear(false), .out(out_B21));
reg8 memory_B22(.in(B22), .clk(clk), .rst(rst), .clear(false), .out(out_B22));
reg8 memory_B23(.in(B23), .clk(clk), .rst(rst), .clear(false), .out(out_B23));

reg8 memory_B31(.in(B31), .clk(clk), .rst(rst), .clear(false), .out(out_B31));
reg8 memory_B32(.in(B32), .clk(clk), .rst(rst), .clear(false), .out(out_B32));
reg8 memory_B33(.in(B33), .clk(clk), .rst(rst), .clear(false), .out(out_B33));

/*
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// OUTPUT1
// This is for selecting which component to pick in the Input Matrix 4x4
four_by_four_out_module four_by_four__A1(
	.A11(A11), .A12(A12), .A13(A13), .A14(A14),
	.A21(A21), .A22(A22), .A23(A23), .A24(A24),
	.A31(A31), .A32(A32), .A33(A33), .A34(A34),
	.A41(A41), .A42(A42), .A43(A43), .A44(A44),
	.address(address1[3:0]), .A_out(A1_out));

// This is for selecting which component to pick in the Filter Matrix 3x3
four_by_four_out_module four_by_four__B1(
	.A11(B11), .A12(B12), .A13(B13), .A14(zero),
	.A21(B21), .A22(B22), .A23(B23), .A24(zero),
	.A31(B31), .A32(B32), .A33(B33), .A34(zero),
	.A41(zero), .A42(zero), .A43(zero), .A44(zero),
	.address(address1[3:0]), .A_out(B1_out));

// This is for selecting which component to pick A or B
two_to_one_mux_module regout1_output(.a(A1_out), .b(B1_out), .s(address1[4]), .out(out1));


// OUTPUT2
// This is for selecting which component to pick in the Input Matrix 4x4
four_by_four_out_module four_by_four__A2(
	.A11(A11), .A12(A12), .A13(A13), .A14(A14),
	.A21(A21), .A22(A22), .A23(A23), .A24(A24),
	.A31(A31), .A32(A32), .A33(A33), .A34(A34),
	.A41(A41), .A42(A42), .A43(A43), .A44(A44),
	.address(address2[3:0]), .A_out(A2_out));

// This is for selecting which component to pick in the Filter Matrix 3x3
four_by_four_out_module four_by_four__B2(
	.A11(B11), .A12(B12), .A13(B13), .A14(zero),
	.A21(B21), .A22(B22), .A23(B23), .A24(zero),
	.A31(B31), .A32(B32), .A33(B33), .A34(zero),
	.A41(zero), .A42(zero), .A43(zero), .A44(zero),
	.address(address2[3:0]), .A_out(B2_out));

// This is for selecting which component to pick A or B
two_to_one_mux_module regout2_output(.a(A2_out), .b(B2_out), .s(address2[4]), .out(out2));



// OUTPUT3
// This is for selecting which component to pick in the Input Matrix 4x4
four_by_four_out_module four_by_four__A3(
	.A11(A11), .A12(A12), .A13(A13), .A14(A14),
	.A21(A21), .A22(A22), .A23(A23), .A24(A24),
	.A31(A31), .A32(A32), .A33(A33), .A34(A34),
	.A41(A41), .A42(A42), .A43(A43), .A44(A44),
	.address(address3[3:0]), .A_out(A3_out));

// This is for selecting which component to pick in the Filter Matrix 3x3
four_by_four_out_module four_by_four__B3(
	.A11(B11), .A12(B12), .A13(B13), .A14(zero),
	.A21(B21), .A22(B22), .A23(B23), .A24(zero),
	.A31(B31), .A32(B32), .A33(B33), .A34(zero),
	.A41(zero), .A42(zero), .A43(zero), .A44(zero),
	.address(address3[3:0]), .A_out(B3_out));

// This is for selecting which component to pick A or B
two_to_one_mux_module regout3_output(.a(A3_out), .b(B3_out), .s(address3[4]), .out(out3));
*/

endmodule

