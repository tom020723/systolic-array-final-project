`timescale 1ns/1ps

module tb_pe3;

    reg clk, rst, start;
    reg [7:0] w_in_seq [1:9];  // 9 weight values
    reg [7:0] a_in_seq [1:9];  // 9 activation values
    wire [7:0] pe_out;
    reg [7:0] pe_a_in, pe_w_in;
    
    // Single PE instance
    pe #(.DATA_W(8), .ACC_W(8)) pe_inst (
        .clk(clk),
        .rst(rst),
        .clear(1'b0),
        .weight_load(1'b1),
        .a_in(pe_a_in),
        .weight_in(pe_w_in),
        .psum_in(8'd0),
        .a_out(),
        .weight_out(),
        .psum_out(pe_out)
    );
    
    // Delayed PE output (2-cycle latency)
    reg [7:0] pe_out_d1, pe_out_d2;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pe_out_d1 <= 8'd0;
            pe_out_d2 <= 8'd0;
        end
        else begin
            pe_out_d1 <= pe_out;
            pe_out_d2 <= pe_out_d1;
        end
    end
    
    // State machine
    reg [4:0] state, next_state;
    
    parameter IDLE = 5'd0;
    parameter MUL_1 = 5'd1;
    parameter MUL_2 = 5'd2;
    parameter MUL_3 = 5'd3;
    parameter MUL_4 = 5'd4;
    parameter MUL_5 = 5'd5;
    parameter MUL_6 = 5'd6;
    parameter MUL_7 = 5'd7;
    parameter MUL_8 = 5'd8;
    parameter MUL_9 = 5'd9;
    parameter WAIT_1 = 5'd10;
    parameter WAIT_2 = 5'd11;
    parameter DONE_STATE = 5'd12;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end
    
    always @(*) begin
        case (state)
            IDLE: next_state = (start) ? MUL_1 : IDLE;
            MUL_1: next_state = MUL_2;
            MUL_2: next_state = MUL_3;
            MUL_3: next_state = MUL_4;
            MUL_4: next_state = MUL_5;
            MUL_5: next_state = MUL_6;
            MUL_6: next_state = MUL_7;
            MUL_7: next_state = MUL_8;
            MUL_8: next_state = MUL_9;
            MUL_9: next_state = WAIT_1;
            WAIT_1: next_state = WAIT_2;
            WAIT_2: next_state = DONE_STATE;
            DONE_STATE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end
    
    // Input scheduling
    always @(*) begin
        pe_a_in = 8'd0;
        pe_w_in = 8'd0;
        
        case (state)
            MUL_1: begin pe_a_in = a_in_seq[1]; pe_w_in = w_in_seq[1]; end
            MUL_2: begin pe_a_in = a_in_seq[2]; pe_w_in = w_in_seq[2]; end
            MUL_3: begin pe_a_in = a_in_seq[3]; pe_w_in = w_in_seq[3]; end
            MUL_4: begin pe_a_in = a_in_seq[4]; pe_w_in = w_in_seq[4]; end
            MUL_5: begin pe_a_in = a_in_seq[5]; pe_w_in = w_in_seq[5]; end
            MUL_6: begin pe_a_in = a_in_seq[6]; pe_w_in = w_in_seq[6]; end
            MUL_7: begin pe_a_in = a_in_seq[7]; pe_w_in = w_in_seq[7]; end
            MUL_8: begin pe_a_in = a_in_seq[8]; pe_w_in = w_in_seq[8]; end
            MUL_9: begin pe_a_in = a_in_seq[9]; pe_w_in = w_in_seq[9]; end
        endcase
    end
    
    // Accumulation register
    reg [15:0] acc;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            acc <= 16'd0;
        end
        else if (state == IDLE) begin
            acc <= 16'd0;
        end
        else begin
            // Accumulate results: MUL_1-9 inputs -> results at MUL_3 onwards
            if (state >= MUL_3 && state <= WAIT_2) begin
                acc <= acc + pe_out_d2;
            end
        end
    end
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    // Test sequence
    integer i;
    
    initial begin
        $display("\n========================================");
        $display("PE Single Execution Test (9x Multiplication)");
        $display("========================================\n");
        
        // Initialize
        rst = 1;
        start = 0;
        
        // Set 9 weight values (3x3 kernel flipped)
        w_in_seq[1] = 8'd9;  // w_33
        w_in_seq[2] = 8'd8;  // w_32
        w_in_seq[3] = 8'd7;  // w_31
        w_in_seq[4] = 8'd6;  // w_23
        w_in_seq[5] = 8'd5;  // w_22
        w_in_seq[6] = 8'd4;  // w_21
        w_in_seq[7] = 8'd3;  // w_13
        w_in_seq[8] = 8'd2;  // w_12
        w_in_seq[9] = 8'd1;  // w_11
        
        // Set 9 activation values (top-left 3x3 window from 4x4 input)
        a_in_seq[1] = 8'd1;   // in_11
        a_in_seq[2] = 8'd2;   // in_12
        a_in_seq[3] = 8'd3;   // in_13
        a_in_seq[4] = 8'd5;   // in_21
        a_in_seq[5] = 8'd6;   // in_22
        a_in_seq[6] = 8'd7;   // in_23
        a_in_seq[7] = 8'd9;   // in_31
        a_in_seq[8] = 8'd10;  // in_32
        a_in_seq[9] = 8'd11;  // in_33
        
        #20 rst = 0;
        
        $display("Input Configuration:");
        $display("Weights (flipped 3x3):    [9 8 7]");
        $display("                          [6 5 4]");
        $display("                          [3 2 1]");
        $display("");
        $display("Activations (3x3 window): [1  2  3 ]");
        $display("                          [5  6  7 ]");
        $display("                          [9  10 11]");
        $display("");
        $display("Expected products: 1*9, 2*8, 3*7, 5*6, 6*5, 7*4, 9*3, 10*2, 11*1");
        $display("                 = 9, 16, 21, 30, 30, 28, 27, 20, 11");
        $display("Expected sum = 9 + 16 + 21 + 30 + 30 + 28 + 27 + 20 + 11 = 192\n");
        
        // Start convolution
        repeat(3) @(posedge clk);
        @(posedge clk); #1;
        start <= 1'b1;
        
        @(posedge clk); #1;
        start <= 1'b0;
        
        // Monitor execution
        $display("Execution trace:");
        for (i = 0; i < 14; i = i + 1) begin
            @(posedge clk); #1;
            case (state)
                IDLE: $display("Cycle %2d: state=IDLE    , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_1: $display("Cycle %2d: state=MUL_1   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_2: $display("Cycle %2d: state=MUL_2   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_3: $display("Cycle %2d: state=MUL_3   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_4: $display("Cycle %2d: state=MUL_4   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_5: $display("Cycle %2d: state=MUL_5   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_6: $display("Cycle %2d: state=MUL_6   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_7: $display("Cycle %2d: state=MUL_7   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_8: $display("Cycle %2d: state=MUL_8   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                MUL_9: $display("Cycle %2d: state=MUL_9   , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                WAIT_1: $display("Cycle %2d: state=WAIT_1  , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                WAIT_2: $display("Cycle %2d: state=WAIT_2  , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                DONE_STATE: $display("Cycle %2d: state=DONE    , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
                default: $display("Cycle %2d: state=UNKNOWN , pe_out=%d, pe_out_d2=%d, acc=%d", i+1, pe_out, pe_out_d2, acc);
            endcase
        end
        
        @(posedge clk); #1;
        
        $display("\n========================================");
        $display("Final Results:");
        $display("========================================");
        $display("Accumulated result = %d", acc[7:0]);
        $display("Expected          = 192");
        if (acc[7:0] == 8'd192) begin
            $display("✓ TEST PASSED");
        end else begin
            $display("✗ TEST FAILED");
        end
        $display("========================================\n");
        
        #20;
        $finish;
    end

endmodule
