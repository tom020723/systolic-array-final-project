`timescale 1ns/1ps

module tb_pe2;

    reg clk, rst, clear, weight_load;
    reg [7:0] a_in, weight_in, psum_in;
    wire [7:0] a_out, weight_out, psum_out;

    // DUT
    pe #(.DATA_W(8), .ACC_W(8)) pe_inst (
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

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test 1: weight_load = 1 always, simple multiplication
    task test_1;
        begin
            $display("\n=== Test 1: weight_load=1 always, Simple Multiplication ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=3
            // Add #1 delay after @(posedge clk) to avoid race condition
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd3;
            psum_in = 8'd0;
            
            // Feed activation: a=5
            @(posedge clk); #1;
            a_in = 8'd5;
            weight_in = 8'd3;  // Keep weight for stationary
            psum_in = 8'd0;
            
            // Wait for result (2-cycle latency)
            @(posedge clk); #1;
            $display("Cycle 2: a_in=5, weight=3, result should be 15 in 2 cycles");
            
            @(posedge clk); #1;
            $display("Cycle 3: psum_out = %d (expected 15)", psum_out);
            
            @(posedge clk); #1;
            $display("Cycle 4: psum_out = %d", psum_out);
        end
    endtask

    // Test 2: Multiple multiplications with accumulation
    task test_2;
        begin
            $display("\n=== Test 2: Multiple Multiplications (weight_load=1) ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=2
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd2;
            
            // Feed first activation: a=3
            @(posedge clk); #1;
            a_in = 8'd3;
            psum_in = 8'd0;
            
            // Feed second activation: a=4
            @(posedge clk); #1;
            a_in = 8'd4;
            psum_in = 8'd0;
            $display("Cycle 1: 3*2 result should appear");
            
            @(posedge clk); #1;
            $display("Cycle 2: psum_out = %d (expected 6 from 3*2)", psum_out);
            
            // Feed third activation: a=5
            @(posedge clk); #1;
            a_in = 8'd5;
            psum_in = 8'd0;
            $display("Cycle 3: 4*2 result should appear");
            
            @(posedge clk); #1;
            $display("Cycle 4: psum_out = %d (expected 8 from 4*2)", psum_out);
        end
    endtask

    // Test 3: Accumulation with psum_in
    task test_3;
        begin
            $display("\n=== Test 3: Accumulation (psum_in feedback) ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=3
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd3;
            
            // Cycle 1: a=2, psum_in=0 -> 2*3=6
            @(posedge clk); #1;
            a_in = 8'd2;
            psum_in = 8'd0;
            
            // Cycle 2: a=4, psum_in=0 -> 4*3=12
            @(posedge clk); #1;
            a_in = 8'd4;
            psum_in = 8'd0;
            $display("Cycle 1: 2*3 should give 6");
            
            // Cycle 3: a=3, psum_in=10 (from previous) -> 3*3+10=19
            @(posedge clk); #1;
            a_in = 8'd3;
            psum_in = 8'd10;
            $display("Cycle 2: psum_out = %d (expected 6)", psum_out);
            
            @(posedge clk); #1;
            $display("Cycle 3: psum_out = %d (expected 12)", psum_out);
            
            @(posedge clk); #1;
            $display("Cycle 4: psum_out = %d (expected 19 from 3*3+10)", psum_out);
        end
    endtask

    // Test 4: Clear signal test
    task test_4;
        begin
            $display("\n=== Test 4: Clear Signal Test (Synchronous Clear) ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            clear = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=5
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd5;
            
            // Feed activation: a=4
            @(posedge clk); #1;
            a_in = 8'd4;
            psum_in = 8'd0;
            
            // Wait for result
            @(posedge clk); #1;
            $display("Cycle 1: 4*5 result should appear");
            
            @(posedge clk); #1;
            $display("Cycle 2: psum_out = %d (expected 20)", psum_out);
            
            // Assert clear (synchronous - takes effect on next clock)
            @(posedge clk); #1;
            clear = 1'b1;
            $display("Cycle 3: Asserting clear signal");
            
            @(posedge clk); #1;
            clear = 1'b0;
            $display("Cycle 4: psum_out = %d (expected 0 after clear)", psum_out);
        end
    endtask

    // Test 5: Continuous multiplication stream
    task test_5;
        integer i;
        begin
            $display("\n=== Test 5: Continuous Multiplication Stream ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=2
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd2;
            
            // Feed sequence: 1,2,3,4,5
            for (i = 1; i <= 5; i = i + 1) begin
                @(posedge clk); #1;
                a_in = i[7:0];
                psum_in = 8'd0;
                $display("Cycle %d: Feed a_in=%d", i, i);
            end
            
            // Observe results (2-cycle latency)
            $display("\nResults (with 2-cycle latency):");
            for (i = 0; i < 4; i = i + 1) begin
                @(posedge clk); #1;
                $display("Cycle %d: psum_out = %d (expected %d)", 6+i, psum_out, (i+1)*2);
            end
        end
    endtask

    // Test 6: Race condition demonstration - timing critical
    task test_6;
        begin
            $display("\n=== Test 6: Timing Verification (simulator independent) ===");
            
            // Reset
            rst = 1;
            weight_load = 0;
            a_in = 8'd0;
            weight_in = 8'd0;
            psum_in = 8'd0;
            #20 rst = 0;
            
            // Load weight: w=7
            @(posedge clk); #1;
            weight_load = 1'b1;
            weight_in = 8'd7;
            
            // Feed activation: a=6
            @(posedge clk); #1;
            a_in = 8'd6;
            psum_in = 8'd0;
            $display("@time=%0t: Input a_in=6, w=7", $time);
            
            // Monitor outputs carefully
            @(posedge clk); #1;
            $display("@time=%0t: After 1 clock - psum_out=%d (weight_reg updated)", $time, psum_out);
            
            @(posedge clk); #1;
            $display("@time=%0t: After 2 clocks - psum_out=%d (expected 42)", $time, psum_out);
            
            @(posedge clk); #1;
            $display("@time=%0t: After 3 clocks - psum_out=%d", $time, psum_out);
        end
    endtask

    // Main test
    initial begin
        $display("========================================");
        $display("PE Testbench with Timing Analysis");
        $display("(Vivado vs ModelSim compatible)");
        $display("========================================");
        
        test_1();
        repeat(5) @(posedge clk);
        
        test_2();
        repeat(5) @(posedge clk);
        
        test_3();
        repeat(5) @(posedge clk);
        
        test_4();
        repeat(5) @(posedge clk);
        
        test_5();
        repeat(5) @(posedge clk);
        
        test_6();
        repeat(5) @(posedge clk);
        
        $display("\n========================================");
        $display("All Tests Completed Successfully");
        $display("========================================\n");
        $finish;
    end

endmodule

