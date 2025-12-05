`timescale 1ns/1ps

module pe #(
    parameter DATA_W  = 8,
    parameter ACC_W = 8
    )(
    input clk,
    input rst,
    input clear,
    input weight_load,  // Weight Stationary: weight load enable signal
    
    input [DATA_W-1: 0] a_in,      // activation input (flows horizontally)
    input [DATA_W-1: 0] weight_in, // weight input (loaded once, then stationary)
    input [ACC_W-1: 0] psum_in,    // partial sum input (flows vertically)
    
    output [DATA_W-1: 0] a_out,    // activation output to next PE
    output [DATA_W-1: 0] weight_out, // weight output to next PE (only during load)
    output [ACC_W-1: 0] psum_out   // partial sum output to next PE
    );
    
    // Weight Stationary: weight register (holds weight value)
    reg [DATA_W-1: 0] weight_reg;
    
    // Weight loading logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            weight_reg <= 0;
        else if (weight_load)
            weight_reg <= weight_in;  // Load weight when weight_load is high
        // else: weight remains stationary
    end
    
    wire [DATA_W-1:0] mult_out, add_out;

    // Multiply activation with stationary weight
    multi8 mult1(.a(a_in), .b(weight_reg), .out(mult_out));
    
    // Add multiplication result to incoming partial sum
    fadd8 add1(.a(psum_in), .b(mult_out), .out(add_out));

    // Activation flows horizontally through register
    reg8 reg_a(.clk(clk), .rst(rst), .clear(clear), .in(a_in), .out(a_out));
    
    // Weight flows to next PE: directly output weight_reg during load phase
    // Weight_reg already provides 1 cycle delay from weight_in
    assign weight_out = weight_load ? weight_reg : 8'b0;
    
    // Partial sum flows vertically through register
    reg8 reg_psum(.clk(clk), .rst(rst), .clear(clear), .in(add_out), .out(psum_out));

endmodule
