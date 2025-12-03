`timescale 1ns / 1ps
module LAB_10_3 (
    input  clk,
    input  rstb,
    output reg [7:0] digit,
    output [7:0] seg_data
);

    wire clk_1hz;
    clock_divider #(49999999) div1 (.clk(clk), .clk_1hz (clk_1hz));

    reg [2:0] digit_idx;
    reg [3:0] num;

    always @(posedge clk_1hz or negedge rstb) begin
        if (!rstb) begin
            digit_idx <= 0;
        end
        else begin
            if (digit_idx == 7)
                digit_idx <= 0;
            else
                digit_idx <= digit_idx + 1;
        end
    end

    always @(*) begin
        digit = 8'b1000_0000 >> digit_idx;
    end

    always @(posedge clk_1hz or negedge rstb) begin
        if (!rstb)
            num <= 4'd0;
        else if (num == 4'd9)
            num <= 4'd0;
        else
            num <= num + 4'd1;
    end

    num_decoder dec1 (.num(num), .seg_data(seg_data));

endmodule
