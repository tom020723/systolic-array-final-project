`timescale 1ns/1ps

module tb_pe;

    reg clk;
    reg rst;
    reg clear;
    reg weight_load;

    reg  [7:0] a_in;
    reg  [7:0] weight_in;
    reg  [7:0] psum_in;

    wire [7:0] a_out;
    wire [7:0] weight_out;
    wire [7:0] psum_out;

    // DUT
    pe #(
        .DATA_W(8),
        .ACC_W(8)
    ) dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .weight_load(weight_load),
        .a_in(a_in),
        .weight_in(weight_in),
        .psum_in(psum_in),
        .a_out(a_out),
        .weight_out(weight_out),
        .psum_out(psum_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end


    initial begin
        rst         = 0;
        clear       = 0;
        weight_load = 0;
        a_in        = 0;
        weight_in   = 0;
        psum_in     = 0;
    end


    initial begin

        #5  rst = 1;
        #20 rst = 0;

        // Clear accumulator
        @(posedge clk);
        #1;  // 클럭 에지 직후에 신호 변경
        clear <= 1;
        @(posedge clk);
        #1;
        clear <= 0;

        // Load weight (weight stationary)
        @(posedge clk);
        #1;
        weight_load <= 1;
        weight_in <= 8'd5;  // Load weight = 5
        @(posedge clk);
        #1;
        weight_load <= 0;

        // Feed activations with partial sums
        @(posedge clk); #1; a_in <= 8'd1; psum_in <= 8'd0;
        @(posedge clk); #1; a_in <= 8'd2; psum_in <= 8'd0;
        @(posedge clk); #1; a_in <= 8'd3; psum_in <= 8'd0;
        @(posedge clk); #1; a_in <= 8'd4; psum_in <= 8'd100;
        @(posedge clk); #1; a_in <= 8'd5; psum_in <= 8'd100;
        @(posedge clk); #1; a_in <= 8'd6; psum_in <= 8'd100;
        @(posedge clk); #1; a_in <= 8'd7; psum_in <= 8'd50;
        @(posedge clk); #1; a_in <= 8'd8; psum_in <= 8'd50;
        @(posedge clk); #1; a_in <= 8'd9; psum_in <= 8'd50;

        #100;
        $finish;

    end

endmodule
