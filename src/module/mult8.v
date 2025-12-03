module multi8(
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] out
);
    integer i;
    reg [15:0] acc;

    always @* begin
        acc = 16'd0;
        for (i = 0; i < 8; i = i + 1) begin
            if (b[i])
                acc = acc + (a << i);
        end
    end

    assign out = acc[7:0];
endmodule
