`timescale 1ns/1ps

module tb_conv_sa3x3;

    reg clk;
    reg rst;
    reg start;

    // 3x3 Weight kernel
    reg [7:0] w_11, w_12, w_13;
    reg [7:0] w_21, w_22, w_23;
    reg [7:0] w_31, w_32, w_33;

    // 4x4 Input feature map
    reg [7:0] in_11, in_12, in_13, in_14;
    reg [7:0] in_21, in_22, in_23, in_24;
    reg [7:0] in_31, in_32, in_33, in_34;
    reg [7:0] in_41, in_42, in_43, in_44;

    // 2x2 Output
    wire [7:0] conv_out_11, conv_out_12;
    wire [7:0] conv_out_21, conv_out_22;
    wire done;

    // DUT
    conv_3x3 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        
        .w_11(w_11), .w_12(w_12), .w_13(w_13),
        .w_21(w_21), .w_22(w_22), .w_23(w_23),
        .w_31(w_31), .w_32(w_32), .w_33(w_33),
        
        .in_11(in_11), .in_12(in_12), .in_13(in_13), .in_14(in_14),
        .in_21(in_21), .in_22(in_22), .in_23(in_23), .in_24(in_24),
        .in_31(in_31), .in_32(in_32), .in_33(in_33), .in_34(in_34),
        .in_41(in_41), .in_42(in_42), .in_43(in_43), .in_44(in_44),
        
        .conv_out_11(conv_out_11), .conv_out_12(conv_out_12),
        .conv_out_21(conv_out_21), .conv_out_22(conv_out_22),
        .done(done)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize
        rst = 0;
        start = 0;
        
        // Initialize weights (3x3 kernel)
        // [1 2 3]
        // [4 5 6]
        // [7 8 9]
        w_11 = 8'd1; w_12 = 8'd2; w_13 = 8'd3;
        w_21 = 8'd4; w_22 = 8'd5; w_23 = 8'd6;
        w_31 = 8'd7; w_32 = 8'd8; w_33 = 8'd9;
        
        // Initialize input (4x4 feature map)
        // [1  2  3  4]
        // [5  6  7  8]
        // [9  10 11 12]
        // [13 14 15 16]
        in_11 = 8'd1;  in_12 = 8'd2;  in_13 = 8'd3;  in_14 = 8'd4;
        in_21 = 8'd5;  in_22 = 8'd6;  in_23 = 8'd7;  in_24 = 8'd8;
        in_31 = 8'd9;  in_32 = 8'd10; in_33 = 8'd11; in_34 = 8'd12;
        in_41 = 8'd13; in_42 = 8'd14; in_43 = 8'd15; in_44 = 8'd16;

        // Reset
        #5 rst = 1;
        #20 rst = 0;

        // Wait a few cycles
        repeat(3) @(posedge clk);

        // Start convolution
        @(posedge clk);
        #1;
        start <= 1;
        @(posedge clk);
        #1;
        start <= 0;

        // Wait for done signal
        @(posedge done);
        
        $display("=== Convolution Complete ===");
        $display("");
        $display("Input (4x4):        Weight (3x3):");
        $display("[1  2  3  4]        [1 2 3]");
        $display("[5  6  7  8]        [4 5 6]");
        $display("[9  10 11 12]       [7 8 9]");
        $display("[13 14 15 16]");
        $display("");
        $display("Output (2x2):");
        $display("[%d  %d]", conv_out_11, conv_out_12);
        $display("[%d  %d]", conv_out_21, conv_out_22);
        $display("");
        $display("Expected Output:");
        $display("conv_out_11 = 348 (1*1 + 2*2 + 3*3 + 5*4 + 6*5 + 7*6 + 9*7 + 10*8 + 11*9)");
        $display("conv_out_12 = 393 (2*1 + 3*2 + 4*3 + 6*4 + 7*5 + 8*6 + 10*7 + 11*8 + 12*9)");
        $display("conv_out_21 = 528 (5*1 + 6*2 + 7*3 + 9*4 + 10*5 + 11*6 + 13*7 + 14*8 + 15*9)");
        $display("conv_out_22 = 573 (6*1 + 7*2 + 8*3 + 10*4 + 11*5 + 12*6 + 14*7 + 15*8 + 16*9)");
        $display("");
        $display("Actual Results:");
        $display("conv_out_11 = %d", conv_out_11);
        $display("conv_out_12 = %d", conv_out_12);
        $display("conv_out_21 = %d", conv_out_21);
        $display("conv_out_22 = %d", conv_out_22);

        // Additional cycles to observe
        repeat(5) @(posedge clk);
        
        $finish;
    end

    // Monitor
    always @(posedge clk) begin
        if (start || done || (conv_out_11 != 0) || (conv_out_12 != 0) || 
            (conv_out_21 != 0) || (conv_out_22 != 0)) begin
            $display("Time=%0t | start=%b done=%b | out_11=%d out_12=%d out_21=%d out_22=%d", 
                     $time, start, done, conv_out_11, conv_out_12, conv_out_21, conv_out_22);
        end
    end

endmodule
