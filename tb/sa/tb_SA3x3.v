`timescale 1ns/1ps

module tb_sa3x3;

    reg clk;
    reg rst;
    reg clear;
    reg weight_load;

    reg  [7:0] w_in1;
    reg  [7:0] w_in2;
    reg  [7:0] w_in3;

    reg  [7:0] act_in1;
    reg  [7:0] act_in2;
    reg  [7:0] act_in3;

    reg  [7:0] psum_in1;
    reg  [7:0] psum_in2;
    reg  [7:0] psum_in3;

    wire [7:0] psum_out1;
    wire [7:0] psum_out2;
    wire [7:0] psum_out3;
    
    // Sum of all psum outputs
    wire [7:0] psum_sum_12;
    wire [7:0] psum_sum_total;
    
    fadd8 add1 (.a(psum_out1), .b(psum_out2), .out(psum_sum_12));
    fadd8 add2 (.a(psum_sum_12), .b(psum_out3), .out(psum_sum_total));

    // DUT
    sa3x3 dut (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .weight_load(weight_load),
        
        .w_in1(w_in1),
        .w_in2(w_in2),
        .w_in3(w_in3),
        .act_in1(act_in1),
        .act_in2(act_in2),
        .act_in3(act_in3),
        .psum_in1(psum_in1),
        .psum_in2(psum_in2),
        .psum_in3(psum_in3),
        .psum_out1(psum_out1),
        .psum_out2(psum_out2),
        .psum_out3(psum_out3)
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
        w_in3       = 0;
        act_in1     = 0;
        act_in2     = 0;
        act_in3     = 0;
        psum_in1    = 0;
        psum_in2    = 0;
        psum_in3    = 0;
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
        // Row 1: w11=1, w12=2, w13=3
        // Row 2: w21=4, w22=5, w23=6
        // Row 3: w31=7, w32=8, w33=9
        @(posedge clk);
        #1;
        weight_load <= 1;
        w_in1 <= 8'd1;  // Weight for column 1, PE11
        w_in2 <= 8'd2;  // Weight for column 2, PE12
        w_in3 <= 8'd3;  // Weight for column 3, PE13
        
        @(posedge clk);
        #1;
        w_in1 <= 8'd4;  // Weight for column 1, PE21 (flows from PE11)
        w_in2 <= 8'd5;  // Weight for column 2, PE22 (flows from PE12)
        w_in3 <= 8'd6;  // Weight for column 3, PE23 (flows from PE13)
        
        @(posedge clk);
        #1;
        w_in1 <= 8'd7;  // Weight for column 1, PE31 (flows from PE21)
        w_in2 <= 8'd8;  // Weight for column 2, PE32 (flows from PE22)
        w_in3 <= 8'd9;  // Weight for column 3, PE33 (flows from PE23)
        
        @(posedge clk);
        #1;
        weight_load <= 0;

        // Feed activations
        // Input:  5 4 3 2 1 (clk)
        //          [3 2 1]
        //        [6 5 4]
        //      [9 8 7]
        // Weight: [7 8 9]
        //         [4 5 6]
        //         [1 2 3]
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd1; act_in2 <= 8'd0; act_in3 <= 8'd0;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd2; act_in2 <= 8'd4; act_in3 <= 8'd0;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd3; act_in2 <= 8'd5; act_in3 <= 8'd7;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd0; act_in2 <= 8'd6; act_in3 <= 8'd8;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd0; act_in2 <= 8'd0; act_in3 <= 8'd9;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;
        
        @(posedge clk);
        #1;
        act_in1 <= 8'd0; act_in2 <= 8'd0; act_in3 <= 8'd0;
        psum_in1 <= 8'd0; psum_in2 <= 8'd0; psum_in3 <= 8'd0;

        // Wait for pipeline to complete
        repeat(10) @(posedge clk);
        
        $display("=== Simulation Complete ===");
        $display("CLK 1");
        $display("Expected psum_out1 = 30");
        $display("Expected psum_out2 = 0");
        $display("Expected psum_out3 = 0");
        $display("CLK 2");
        $display("Expected psum_out1 = 42");
        $display("Expected psum_out2 = 42");
        $display("Expected psum_out3 = 0");
        $display("CLK 3");
        $display("Expected psum_out1 = 54");
        $display("Expected psum_out2 = 57");
        $display("Expected psum_out3 = 54");
        $display("CLK 4");
        $display("Expected psum_out1 = 0");
        $display("Expected psum_out2 = 72");
        $display("Expected psum_out3 = 72");
        $display("CLK 5");
        $display("Expected psum_out1 = 0");
        $display("Expected psum_out2 = 0");
        $display("Expected psum_out3 = 90");
        
        #100;
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        $display("Time=%0t | psum_out1=%d, psum_out2=%d, psum_out3=%d | SUM=%d", 
                 $time, psum_out1, psum_out2, psum_out3, psum_sum_total);
    end

endmodule
