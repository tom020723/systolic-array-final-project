`timescale 1ns / 1ps

module controller_tb;

    // ========================================
    // Testbench Signals
    // ========================================
    reg clk;
    reg rst;
    reg start;
    
    wire done;
    wire [7:0] pe_out_c11, pe_out_c12, pe_out_c21, pe_out_c22;
    wire [7:0] sa2_out_c11, sa2_out_c12, sa2_out_c21, sa2_out_c22;
    wire [7:0] sa3_out_c11, sa3_out_c12, sa3_out_c21, sa3_out_c22;
    
    // ========================================
    // DUT (Device Under Test) Instantiation
    // ========================================
    controller dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .pe_out_c11(pe_out_c11), .pe_out_c12(pe_out_c12), 
        .pe_out_c21(pe_out_c21), .pe_out_c22(pe_out_c22),
        .sa2_out_c11(sa2_out_c11), .sa2_out_c12(sa2_out_c12), 
        .sa2_out_c21(sa2_out_c21), .sa2_out_c22(sa2_out_c22),
        .sa3_out_c11(sa3_out_c11), .sa3_out_c12(sa3_out_c12), 
        .sa3_out_c21(sa3_out_c21), .sa3_out_c22(sa3_out_c22)
    );
    
    // ========================================
    // Clock Generation (100MHz = 10ns period)
    // ========================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // ========================================
    // Test Stimulus
    // ========================================
    initial begin
        // Initialize signals
        rst = 1;
        start = 0;
        
        // Display test info
        $display("========================================");
        $display("Controller Testbench Started");
        $display("Input Matrix (4x4):");
        $display("  1  2  3  4");
        $display("  5  6  7  8");
        $display("  9 10 11 12");
        $display(" 13 14 15 16");
        $display("");
        $display("Weight Matrix (3x3):");
        $display("  1  0  1");
        $display("  0  1  0");
        $display("  1  0  1");
        $display("========================================");
        
        // Reset sequence
        #20;
        rst = 0;
        #10;
        
        // Start computation
        $display("[%0t ns] Asserting start signal", $time);
        start = 1;
        #10;
        start = 0;
        
        // Wait for completion
        wait(done == 1);
        #20;
        
        // Display results
        $display("");
        $display("========================================");
        $display("Computation Complete at %0t ns", $time);
        $display("========================================");
        
        $display("");
        $display("PE Results (Single Processing Element):");
        $display("  C11 = %3d, C12 = %3d", pe_out_c11, pe_out_c12);
        $display("  C21 = %3d, C22 = %3d", pe_out_c21, pe_out_c22);
        
        $display("");
        $display("SA 2x2 Results (2x2 Systolic Array):");
        $display("  C11 = %3d, C12 = %3d", sa2_out_c11, sa2_out_c12);
        $display("  C21 = %3d, C22 = %3d", sa2_out_c21, sa2_out_c22);
        
        $display("");
        $display("SA 3x3 Results (3x3 Systolic Array):");
        $display("  C11 = %3d, C12 = %3d", sa3_out_c11, sa3_out_c12);
        $display("  C21 = %3d, C22 = %3d", sa3_out_c21, sa3_out_c22);
        
        $display("");
        $display("========================================");
        $display("Verification:");
        $display("========================================");
        
        // Check if all three methods produce same results
        if (pe_out_c11 == sa2_out_c11 && sa2_out_c11 == sa3_out_c11 &&
            pe_out_c12 == sa2_out_c12 && sa2_out_c12 == sa3_out_c12 &&
            pe_out_c21 == sa2_out_c21 && sa2_out_c21 == sa3_out_c21 &&
            pe_out_c22 == sa2_out_c22 && sa2_out_c22 == sa3_out_c22) begin
            $display("PASS: All three methods produce identical results!");
        end else begin
            $display("FAIL: Results differ between methods!");
            $display("  PE  vs SA2x2: %s", (pe_out_c11 == sa2_out_c11 && pe_out_c12 == sa2_out_c12 && 
                                           pe_out_c21 == sa2_out_c21 && pe_out_c22 == sa2_out_c22) ? "MATCH" : "MISMATCH");
            $display("  PE  vs SA3x3: %s", (pe_out_c11 == sa3_out_c11 && pe_out_c12 == sa3_out_c12 && 
                                           pe_out_c21 == sa3_out_c21 && pe_out_c22 == sa3_out_c22) ? "MATCH" : "MISMATCH");
            $display("  SA2 vs SA3x3: %s", (sa2_out_c11 == sa3_out_c11 && sa2_out_c12 == sa3_out_c12 && 
                                           sa2_out_c21 == sa3_out_c21 && sa2_out_c22 == sa3_out_c22) ? "MATCH" : "MISMATCH");
        end
        
        $display("========================================");
        
        // Continue simulation for observation
        #100;
        
        $display("Testbench finished at %0t ns", $time);
        $finish;
    end
    
    // ========================================
    // State Monitoring
    // ========================================
    always @(posedge clk) begin
        if (dut.state == dut.CONV_PE)
            $display("[%0t ns] STATE: CONV_PE - Starting PE computation", $time);
        else if (dut.state == dut.WAIT_PE && dut.pe_done) begin
            $display("[%0t ns] STATE: WAIT_PE - PE computation done", $time);
            $display("           PE outputs: %d, %d, %d, %d", dut.pe_out_11, dut.pe_out_12, dut.pe_out_21, dut.pe_out_22);
        end
        else if (dut.state == dut.CONV_SA2X2)
            $display("[%0t ns] STATE: CONV_SA2X2 - Starting 2x2 SA computation", $time);
        else if (dut.state == dut.WAIT_SA2X2 && dut.sa2_done) begin
            $display("[%0t ns] STATE: WAIT_SA2X2 - 2x2 SA computation done", $time);
            $display("           SA2 outputs: %d, %d, %d, %d", dut.sa2_out_11, dut.sa2_out_12, dut.sa2_out_21, dut.sa2_out_22);
        end
        else if (dut.state == dut.CONV_SA3X3)
            $display("[%0t ns] STATE: CONV_SA3X3 - Starting 3x3 SA computation", $time);
        else if (dut.state == dut.WAIT_SA3X3 && dut.sa3_done) begin
            $display("[%0t ns] STATE: WAIT_SA3X3 - 3x3 SA computation done", $time);
            $display("           SA3 outputs: %d, %d, %d, %d", dut.sa3_out_11, dut.sa3_out_12, dut.sa3_out_21, dut.sa3_out_22);
        end
        else if (dut.state == dut.DISPLAY)
            $display("[%0t ns] STATE: DISPLAY - Outputting results", $time);
        else if (dut.state == dut.DONE_STATE)
            $display("[%0t ns] STATE: DONE_STATE - All computations complete", $time);
    end
    
    // Monitor done signals from submodules
    always @(posedge clk) begin
        if (dut.pe_done)
            $display("[%0t ns] PE done signal asserted", $time);
        if (dut.sa2_done)
            $display("[%0t ns] SA2x2 done signal asserted", $time);
        if (dut.sa3_done)
            $display("[%0t ns] SA3x3 done signal asserted", $time);
    end
    
    // ========================================
    // Waveform Dump (for viewing in simulator)
    // ========================================
    initial begin
        $dumpfile("controller_tb.vcd");
        $dumpvars(0, controller_tb);
    end

endmodule
