`timescale 1ns/1ps

module tb_conv_pe;

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
    conv_pe dut (
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
        
        $display("=== Conv_PE (Single PE) Convolution Complete ===");
        $display("");
        $display("Input (4x4):        Weight (3x3):");
        $display("[1  2  3  4]        [1 2 3]");
        $display("[5  6  7  8]        [4 5 6]");
        $display("[9  10 11 12]       [7 8 9]");
        $display("[13 14 15 16]");
        $display("");
        $display("Output (2x2) with weight flipping (general convolution):");
        $display("[%d  %d]", conv_out_11, conv_out_12);
        $display("[%d  %d]", conv_out_21, conv_out_22);
        $display("");
        $display("Expected Output (with flipped weights [9 8 7; 6 5 4; 3 2 1]):");
        $display("conv_out_11 = 285 (1*9 + 2*8 + 3*7 + 5*6 + 6*5 + 7*4 + 9*3 + 10*2 + 11*1)");
        $display("conv_out_12 = 315 (2*9 + 3*8 + 4*7 + 6*6 + 7*5 + 8*4 + 10*3 + 11*2 + 12*1)");
        $display("conv_out_21 = 423 (5*9 + 6*8 + 7*7 + 9*6 + 10*5 + 11*4 + 13*3 + 14*2 + 15*1)");
        $display("conv_out_22 = 453 (6*9 + 7*8 + 8*7 + 10*6 + 11*5 + 12*4 + 14*3 + 15*2 + 16*1)");
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
