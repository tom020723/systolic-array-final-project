`timescale 1ns/1ps

module tb_sa2x2;

    reg clk;
    reg rst;
    reg clear;
    reg weight_load;

    reg  [7:0] w_in1;
    reg  [7:0] w_in2;

    reg  [7:0] act_in1;
    reg  [7:0] act_in2;

    reg  [7:0] psum_in1;
    reg  [7:0] psum_in2;

    wire [7:0] psum_out1;
    wire [7:0] psum_out2;

    // DUT
    sa2x2 dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .weight_load(weight_load),
        
        .w_in1(w_in1),
        .w_in2(w_in2),
        .act_in1(act_in1),
        .act_in2(act_in2),
        .psum_in1(psum_in1),
        .psum_in2(psum_in2),
        .psum_out1(psum_out1),
        .psum_out2(psum_out2)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst         = 0;
        clear       = 0;
        weight_load = 0;
        w_in1       = 0;
        w_in2       = 0;
        act_in1     = 0;
        act_in2     = 0;
        psum_in1    = 0;
        psum_in2    = 0;
    end

    initial begin
        // Reset
        #5  rst = 1;
        #20 rst = 0;

        // Clear accumulator
        @(posedge clk);
        #1;
        clear <= 1;
        @(posedge clk);
        #1;
        clear <= 0;

        // Load weights (Weight Stationary)
        // Row 1: w11=1, w12=2
        // Row 2: w21=3, w22=4
        @(posedge clk);
        #1;
        weight_load <= 1;
        w_in1 <= 8'd1;  // Weight for column 1, PE11
        w_in2 <= 8'd2;  // Weight for column 2, PE12
        
        @(posedge clk);
        #1;
        w_in1 <= 8'd3;  // Weight for column 1, PE21 (flows from PE11)
        w_in2 <= 8'd4;  // Weight for column 2, PE22 (flows from PE12)
        
        @(posedge clk);
        #1;
        weight_load <= 0;

        // Feed activations
        // Input:  3 2 1 (clk)
        //          [2 1]
        //        [4 3]
        // Weight: [3 4]
        //         [1 2]
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd1; act_in2 <= 8'd0; psum_in1 <= 8'd0; psum_in2 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd2; act_in2 <= 8'd3; psum_in1 <= 8'd0; psum_in2 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd0; act_in2 <= 8'd4; psum_in1 <= 8'd0; psum_in2 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd0; act_in2 <= 8'd0; psum_in1 <= 8'd0; psum_in2 <= 8'd0;

        // Wait for pipeline to complete
        repeat(10) @(posedge clk);
        
        $display("=== Simulation Complete ===");
        $display("CLK 1");
        $display("Expected psum_out1 = 6 (3*1 + 1*3)");
        $display("Expected psum_out2 = 0");
        $display("CLK 2");
        $display("Expected psum_out1 = 10 (3*2 + 4*1)");
        $display("Expected psum_out2 = 10 (4*1 + 2*3)");
        $display("CLK 3");
        $display("Expected psum_out1 = 0");
        $display("Expected psum_out2 = 16 (4*2 + 2*4)");
        
        #100;
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        $display("Time=%0t | psum_out1=%d, psum_out2=%d", $time, psum_out1, psum_out2);
    end

endmodule