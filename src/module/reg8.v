module reg8 (clk ,rst, clear, in, out);
    input clk,rst,clear;
    input [7:0] in;
    output reg [7:0] out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 8'd0;
        end
        else if (clear) begin
            out <= 8'd0;
        end
        else begin
            out <= in;
        end
    end

endmodule