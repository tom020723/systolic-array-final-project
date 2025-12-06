module controller (
    input clk,
    input rst,
    input start,            // Start signal
    output reg done,        // Completion signal
    // Debug outputs for verification
    output reg [7:0] pe_out_c11, pe_out_c12, pe_out_c21, pe_out_c22,
    output reg [7:0] sa2_out_c11, sa2_out_c12, sa2_out_c21, sa2_out_c22,
    output reg [7:0] sa3_out_c11, sa3_out_c12, sa3_out_c21, sa3_out_c22
);

    // ========================================
    // Hard-coded Input Data (Test Data)
    // ========================================
    // 4x4 Input Feature Map
    reg [7:0] input_map [0:3][0:3];
    
    // 3x3 Convolution Kernel/Weight
    reg [7:0] weight [0:2][0:2];
    
    initial begin
        // Initialize input map (example values)
        input_map[0][0] = 8'd1;  input_map[0][1] = 8'd2;  input_map[0][2] = 8'd3;  input_map[0][3] = 8'd4;
        input_map[1][0] = 8'd5;  input_map[1][1] = 8'd6;  input_map[1][2] = 8'd7;  input_map[1][3] = 8'd8;
        input_map[2][0] = 8'd9;  input_map[2][1] = 8'd10; input_map[2][2] = 8'd11; input_map[2][3] = 8'd12;
        input_map[3][0] = 8'd13; input_map[3][1] = 8'd14; input_map[3][2] = 8'd15; input_map[3][3] = 8'd16;
        
        // Initialize weights (example values)
        weight[0][0] = 8'd1; weight[0][1] = 8'd0; weight[0][2] = 8'd1;
        weight[1][0] = 8'd0; weight[1][1] = 8'd1; weight[1][2] = 8'd0;
        weight[2][0] = 8'd1; weight[2][1] = 8'd0; weight[2][2] = 8'd1;
    end

    // ========================================
    // Controller State Machine
    // ========================================
    reg [3:0] state, next_state;
    
    // State definitions
    parameter IDLE          = 4'd0;
    parameter CONV_PE       = 4'd1;
    parameter WAIT_PE       = 4'd2;
    parameter CONV_SA2X2    = 4'd3;
    parameter WAIT_SA2X2    = 4'd4;
    parameter CONV_SA3X3    = 4'd5;
    parameter WAIT_SA3X3    = 4'd6;
    parameter DISPLAY       = 4'd7;
    parameter DONE_STATE    = 4'd8;

    // ========================================
    // Memory Signals
    // ========================================
    wire [7:0] mem_out_A11, mem_out_A12, mem_out_A13, mem_out_A14;
    wire [7:0] mem_out_A21, mem_out_A22, mem_out_A23, mem_out_A24;
    wire [7:0] mem_out_A31, mem_out_A32, mem_out_A33, mem_out_A34;
    wire [7:0] mem_out_A41, mem_out_A42, mem_out_A43, mem_out_A44;
    wire [7:0] mem_out_B11, mem_out_B12, mem_out_B13;
    wire [7:0] mem_out_B21, mem_out_B22, mem_out_B23;
    wire [7:0] mem_out_B31, mem_out_B32, mem_out_B33;
    
    // Memory instantiation
    memory_module mem_inst (
        .clk(clk),
        .rst(rst),
        // Input matrix A (4x4)
        .A11(input_map[0][0]), .A12(input_map[0][1]), .A13(input_map[0][2]), .A14(input_map[0][3]),
        .A21(input_map[1][0]), .A22(input_map[1][1]), .A23(input_map[1][2]), .A24(input_map[1][3]),
        .A31(input_map[2][0]), .A32(input_map[2][1]), .A33(input_map[2][2]), .A34(input_map[2][3]),
        .A41(input_map[3][0]), .A42(input_map[3][1]), .A43(input_map[3][2]), .A44(input_map[3][3]),
        // Input filter B (3x3)
        .B11(weight[0][0]), .B12(weight[0][1]), .B13(weight[0][2]),
        .B21(weight[1][0]), .B22(weight[1][1]), .B23(weight[1][2]),
        .B31(weight[2][0]), .B32(weight[2][1]), .B33(weight[2][2]),
        // Output matrix A (4x4)
        .out_A11(mem_out_A11), .out_A12(mem_out_A12), .out_A13(mem_out_A13), .out_A14(mem_out_A14),
        .out_A21(mem_out_A21), .out_A22(mem_out_A22), .out_A23(mem_out_A23), .out_A24(mem_out_A24),
        .out_A31(mem_out_A31), .out_A32(mem_out_A32), .out_A33(mem_out_A33), .out_A34(mem_out_A34),
        .out_A41(mem_out_A41), .out_A42(mem_out_A42), .out_A43(mem_out_A43), .out_A44(mem_out_A44),
        // Output filter B (3x3)
        .out_B11(mem_out_B11), .out_B12(mem_out_B12), .out_B13(mem_out_B13),
        .out_B21(mem_out_B21), .out_B22(mem_out_B22), .out_B23(mem_out_B23),
        .out_B31(mem_out_B31), .out_B32(mem_out_B32), .out_B33(mem_out_B33)
    );

    // ========================================
    // Conv PE (Processing Element) Signals
    // ========================================
    reg pe_start;
    wire pe_done;
    wire [7:0] pe_out_11, pe_out_12, pe_out_21, pe_out_22;
    
    // PE convolution module instantiation
    conv_pe pe_inst (
        .clk(clk),
        .rst(rst),
        .start(pe_start),
        .w_11(mem_out_B11), .w_12(mem_out_B12), .w_13(mem_out_B13),
        .w_21(mem_out_B21), .w_22(mem_out_B22), .w_23(mem_out_B23),
        .w_31(mem_out_B31), .w_32(mem_out_B32), .w_33(mem_out_B33),
        .in_11(mem_out_A11), .in_12(mem_out_A12), .in_13(mem_out_A13), .in_14(mem_out_A14),
        .in_21(mem_out_A21), .in_22(mem_out_A22), .in_23(mem_out_A23), .in_24(mem_out_A24),
        .in_31(mem_out_A31), .in_32(mem_out_A32), .in_33(mem_out_A33), .in_34(mem_out_A34),
        .in_41(mem_out_A41), .in_42(mem_out_A42), .in_43(mem_out_A43), .in_44(mem_out_A44),
        .conv_out_11(pe_out_11), .conv_out_12(pe_out_12),
        .conv_out_21(pe_out_21), .conv_out_22(pe_out_22),
        .done(pe_done)
    );

    // ========================================
    // Conv SA2x2 (2x2 Systolic Array) Signals
    // ========================================
    reg sa2_start;
    wire sa2_done;
    wire [7:0] sa2_out_11, sa2_out_12, sa2_out_21, sa2_out_22;
    
    // 2x2 SA convolution module instantiation
    conv_2x2 sa2_inst (
        .clk(clk),
        .rst(rst),
        .start(sa2_start),
        .w_11(mem_out_B11), .w_12(mem_out_B12), .w_13(mem_out_B13),
        .w_21(mem_out_B21), .w_22(mem_out_B22), .w_23(mem_out_B23),
        .w_31(mem_out_B31), .w_32(mem_out_B32), .w_33(mem_out_B33),
        .in_11(mem_out_A11), .in_12(mem_out_A12), .in_13(mem_out_A13), .in_14(mem_out_A14),
        .in_21(mem_out_A21), .in_22(mem_out_A22), .in_23(mem_out_A23), .in_24(mem_out_A24),
        .in_31(mem_out_A31), .in_32(mem_out_A32), .in_33(mem_out_A33), .in_34(mem_out_A34),
        .in_41(mem_out_A41), .in_42(mem_out_A42), .in_43(mem_out_A43), .in_44(mem_out_A44),
        .conv_out_11(sa2_out_11), .conv_out_12(sa2_out_12),
        .conv_out_21(sa2_out_21), .conv_out_22(sa2_out_22),
        .done(sa2_done)
    );

    // ========================================
    // Conv 3x3 (3x3 Systolic Array) Signals
    // ========================================
    reg sa3_start;
    wire sa3_done;
    wire [7:0] sa3_out_11, sa3_out_12, sa3_out_21, sa3_out_22;
    
    // 3x3 SA convolution module instantiation
    conv_3x3 sa3_inst (
        .clk(clk),
        .rst(rst),
        .start(sa3_start),
        .w_11(mem_out_B11), .w_12(mem_out_B12), .w_13(mem_out_B13),
        .w_21(mem_out_B21), .w_22(mem_out_B22), .w_23(mem_out_B23),
        .w_31(mem_out_B31), .w_32(mem_out_B32), .w_33(mem_out_B33),
        .in_11(mem_out_A11), .in_12(mem_out_A12), .in_13(mem_out_A13), .in_14(mem_out_A14),
        .in_21(mem_out_A21), .in_22(mem_out_A22), .in_23(mem_out_A23), .in_24(mem_out_A24),
        .in_31(mem_out_A31), .in_32(mem_out_A32), .in_33(mem_out_A33), .in_34(mem_out_A34),
        .in_41(mem_out_A41), .in_42(mem_out_A42), .in_43(mem_out_A43), .in_44(mem_out_A44),
        .conv_out_11(sa3_out_11), .conv_out_12(sa3_out_12),
        .conv_out_21(sa3_out_21), .conv_out_22(sa3_out_22),
        .done(sa3_done)
    );

    // ========================================
    // Output Result Storage
    // ========================================
    reg [7:0] pe_result [0:1][0:1];
    reg [7:0] sa2_result [0:1][0:1];
    reg [7:0] sa3_result [0:1][0:1];
    
    // ========================================
    // State Update
    // ========================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // ========================================
    // Next State Logic
    // ========================================
    always @(*) begin
        next_state = state;
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = CONV_PE;
            end
            
            CONV_PE: begin
                next_state = WAIT_PE;
            end
            
            WAIT_PE: begin
                if (pe_done)
                    next_state = CONV_SA2X2;
            end
            
            CONV_SA2X2: begin
                next_state = WAIT_SA2X2;
            end
            
            WAIT_SA2X2: begin
                if (sa2_done)
                    next_state = CONV_SA3X3;
            end
            
            CONV_SA3X3: begin
                next_state = WAIT_SA3X3;
            end
            
            WAIT_SA3X3: begin
                if (sa3_done)
                    next_state = DISPLAY;
            end
            
            DISPLAY: begin
                next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                next_state = DONE_STATE;  // Stay in DONE_STATE (keep done=1)
            end
            
            default: next_state = IDLE;
        endcase
    end

    // ========================================
    // Output Control Logic
    // ========================================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 1'b0;
            pe_start <= 1'b0;
            sa2_start <= 1'b0;
            sa3_start <= 1'b0;
            // Initialize all result registers
            pe_result[0][0] <= 8'd0;
            pe_result[0][1] <= 8'd0;
            pe_result[1][0] <= 8'd0;
            pe_result[1][1] <= 8'd0;
            sa2_result[0][0] <= 8'd0;
            sa2_result[0][1] <= 8'd0;
            sa2_result[1][0] <= 8'd0;
            sa2_result[1][1] <= 8'd0;
            sa3_result[0][0] <= 8'd0;
            sa3_result[0][1] <= 8'd0;
            sa3_result[1][0] <= 8'd0;
            sa3_result[1][1] <= 8'd0;
            // Initialize debug outputs
            pe_out_c11 <= 8'd0; pe_out_c12 <= 8'd0; pe_out_c21 <= 8'd0; pe_out_c22 <= 8'd0;
            sa2_out_c11 <= 8'd0; sa2_out_c12 <= 8'd0; sa2_out_c21 <= 8'd0; sa2_out_c22 <= 8'd0;
            sa3_out_c11 <= 8'd0; sa3_out_c12 <= 8'd0; sa3_out_c21 <= 8'd0; sa3_out_c22 <= 8'd0;
        end
        else begin
            // Default values
            pe_start <= 1'b0;
            sa2_start <= 1'b0;
            sa3_start <= 1'b0;
            // Don't reset done to 0 by default - let each state control it
            
            case (state)
                IDLE: begin
                    // Wait for start signal
                    done <= 1'b0;  // Clear done when idle
                end
                
                CONV_PE: begin
                    pe_start <= 1'b1;
                    done <= 1'b0;
                end
                
                WAIT_PE: begin
                    if (pe_done) begin
                        // Store PE results
                        pe_result[0][0] <= pe_out_11;
                        pe_result[0][1] <= pe_out_12;
                        pe_result[1][0] <= pe_out_21;
                        pe_result[1][1] <= pe_out_22;
                        // Update debug outputs immediately
                        pe_out_c11 <= pe_out_11;
                        pe_out_c12 <= pe_out_12;
                        pe_out_c21 <= pe_out_21;
                        pe_out_c22 <= pe_out_22;
                    end
                end
                
                CONV_SA2X2: begin
                    sa2_start <= 1'b1;
                end
                
                WAIT_SA2X2: begin
                    if (sa2_done) begin
                        // Store SA2x2 results
                        sa2_result[0][0] <= sa2_out_11;
                        sa2_result[0][1] <= sa2_out_12;
                        sa2_result[1][0] <= sa2_out_21;
                        sa2_result[1][1] <= sa2_out_22;
                        // Update debug outputs immediately
                        sa2_out_c11 <= sa2_out_11;
                        sa2_out_c12 <= sa2_out_12;
                        sa2_out_c21 <= sa2_out_21;
                        sa2_out_c22 <= sa2_out_22;
                    end
                end
                
                CONV_SA3X3: begin
                    sa3_start <= 1'b1;
                end
                
                WAIT_SA3X3: begin
                    if (sa3_done) begin
                        // Store SA3x3 results
                        sa3_result[0][0] <= sa3_out_11;
                        sa3_result[0][1] <= sa3_out_12;
                        sa3_result[1][0] <= sa3_out_21;
                        sa3_result[1][1] <= sa3_out_22;
                        // Update debug outputs immediately
                        sa3_out_c11 <= sa3_out_11;
                        sa3_out_c12 <= sa3_out_12;
                        sa3_out_c21 <= sa3_out_21;
                        sa3_out_c22 <= sa3_out_22;
                    end
                end
                
                DISPLAY: begin
                    // Debug outputs already updated in WAIT states
                end
                
                DONE_STATE: begin
                    done <= 1'b1;  // Keep done high
                end
                
                default: begin
                    // Stay in current state
                end
            endcase
        end
    end

endmodule