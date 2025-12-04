//`timescale 1ns / 1ps


module clock_divider #(
    parameter div = 49999999
    )(
    input clk,
    output reg clk_1hz
    );
    
    reg [25: 0] q;
    
    initial begin
        q <= 0;
        clk_1hz = 0;
    end
    
    always@ (posedge clk) begin
        if (q == div) begin
            clk_1hz <= ~clk_1hz;
            q <= 0;
        end
        else q <= q + 1;
    end
endmodule

