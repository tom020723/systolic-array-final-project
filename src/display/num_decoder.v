//`timescale 1ns / 1ps

module num_decoder (
    input  [3:0] num,
    output reg [7:0] seg_data
);

    always @(*) begin
        case (num)
            4'd0: seg_data = 8'b1111_1100;
            4'd1: seg_data = 8'b0110_0000;
            4'd2: seg_data = 8'b1101_1010;
            4'd3: seg_data = 8'b1111_0010;
            4'd4: seg_data = 8'b0110_0110;
            4'd5: seg_data = 8'b1011_0110;
            4'd6: seg_data = 8'b1011_1110;
            4'd7: seg_data = 8'b1110_0000;
            4'd8: seg_data = 8'b1111_1110;
            4'd9: seg_data = 8'b1110_0110;
        endcase
    end
endmodule
