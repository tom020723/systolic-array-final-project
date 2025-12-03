module controller (
    input clk,
    input rst,
    input start,            // Start signal
    output reg done,        // Completion signal
    output reg [7:0] display_out  // Output for display
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
    parameter LOAD_WEIGHT   = 4'd1;
    parameter CONV_PE       = 4'd2;
    parameter WAIT_PE       = 4'd3;
    parameter CONV_SA2X2    = 4'd4;
    parameter WAIT_SA2X2    = 4'd5;
    parameter CONV_SA3X3    = 4'd6;
    parameter WAIT_SA3X3    = 4'd7;
    parameter DISPLAY       = 4'd8;
    parameter DONE_STATE    = 4'd9;

    // ========================================
    // Memory Signals
    // ========================================
    reg mem_write_en;
    reg [4:0] mem_addr;
    reg [7:0] mem_data_in;
    wire [7:0] mem_data_out;
    
    // Memory instantiation (if needed)
    // memory mem_inst (
    //     .clk(clk),
    //     .write_en(mem_write_en),
    //     .addr(mem_addr),
    //     .data_in(mem_data_in),
    //     .data_out(mem_data_out)
    // );

    // ========================================
    // Conv PE (Processing Element) Signals
    // ========================================
    reg pe_start;
    reg pe_weight_load;
    wire pe_done;
    wire [7:0] pe_out_11, pe_out_12, pe_out_21, pe_out_22;
    
    // PE convolution module instantiation
    // conv_pe pe_inst (
    //     .clk(clk),
    //     .rst(rst),
    //     .start(pe_start),
    //     .weight_load(pe_weight_load),
    //     .w_11(weight[0][0]), .w_12(weight[0][1]), .w_13(weight[0][2]),
    //     .w_21(weight[1][0]), .w_22(weight[1][1]), .w_23(weight[1][2]),
    //     .w_31(weight[2][0]), .w_32(weight[2][1]), .w_33(weight[2][2]),
    //     .in_11(input_map[0][0]), .in_12(input_map[0][1]), .in_13(input_map[0][2]), .in_14(input_map[0][3]),
    //     .in_21(input_map[1][0]), .in_22(input_map[1][1]), .in_23(input_map[1][2]), .in_24(input_map[1][3]),
    //     .in_31(input_map[2][0]), .in_32(input_map[2][1]), .in_33(input_map[2][2]), .in_34(input_map[2][3]),
    //     .in_41(input_map[3][0]), .in_42(input_map[3][1]), .in_43(input_map[3][2]), .in_44(input_map[3][3]),
    //     .conv_out_11(pe_out_11), .conv_out_12(pe_out_12),
    //     .conv_out_21(pe_out_21), .conv_out_22(pe_out_22),
    //     .done(pe_done)
    // );

    // ========================================
    // Conv SA2x2 (2x2 Systolic Array) Signals
    // ========================================
    reg sa2_start;
    reg sa2_weight_load;
    wire sa2_done;
    wire [7:0] sa2_out_11, sa2_out_12, sa2_out_21, sa2_out_22;
    
    // 2x2 SA convolution module instantiation
    // conv_sa2x2 sa2_inst (
    //     .clk(clk),
    //     .rst(rst),
    //     .start(sa2_start),
    //     .weight_load(sa2_weight_load),
    //     .w_11(weight[0][0]), .w_12(weight[0][1]), .w_13(weight[0][2]),
    //     .w_21(weight[1][0]), .w_22(weight[1][1]), .w_23(weight[1][2]),
    //     .w_31(weight[2][0]), .w_32(weight[2][1]), .w_33(weight[2][2]),
    //     .in_11(input_map[0][0]), .in_12(input_map[0][1]), .in_13(input_map[0][2]), .in_14(input_map[0][3]),
    //     .in_21(input_map[1][0]), .in_22(input_map[1][1]), .in_23(input_map[1][2]), .in_24(input_map[1][3]),
    //     .in_31(input_map[2][0]), .in_32(input_map[2][1]), .in_33(input_map[2][2]), .in_34(input_map[2][3]),
    //     .in_41(input_map[3][0]), .in_42(input_map[3][1]), .in_43(input_map[3][2]), .in_44(input_map[3][3]),
    //     .conv_out_11(sa2_out_11), .conv_out_12(sa2_out_12),
    //     .conv_out_21(sa2_out_21), .conv_out_22(sa2_out_22),
    //     .done(sa2_done)
    // );

    // ========================================
    // Conv 3x3 (3x3 Systolic Array) Signals
    // ========================================
    reg sa3_start;
    reg sa3_weight_load;
    wire sa3_done;
    wire [7:0] sa3_out_11, sa3_out_12, sa3_out_21, sa3_out_22;
    
    // 3x3 SA convolution module instantiation
    conv_3x3 sa3_inst (
        .clk(clk),
        .rst(rst),
        .start(sa3_start),
        .weight_load(sa3_weight_load),
        .w_11(weight[0][0]), .w_12(weight[0][1]), .w_13(weight[0][2]),
        .w_21(weight[1][0]), .w_22(weight[1][1]), .w_23(weight[1][2]),
        .w_31(weight[2][0]), .w_32(weight[2][1]), .w_33(weight[2][2]),
        .in_11(input_map[0][0]), .in_12(input_map[0][1]), .in_13(input_map[0][2]), .in_14(input_map[0][3]),
        .in_21(input_map[1][0]), .in_22(input_map[1][1]), .in_23(input_map[1][2]), .in_24(input_map[1][3]),
        .in_31(input_map[2][0]), .in_32(input_map[2][1]), .in_33(input_map[2][2]), .in_34(input_map[2][3]),
        .in_41(input_map[3][0]), .in_42(input_map[3][1]), .in_43(input_map[3][2]), .in_44(input_map[3][3]),
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
                    next_state = LOAD_WEIGHT;
            end
            
            LOAD_WEIGHT: begin
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
                next_state = IDLE;
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
            display_out <= 8'd0;
            pe_start <= 1'b0;
            pe_weight_load <= 1'b0;
            sa2_start <= 1'b0;
            sa2_weight_load <= 1'b0;
            sa3_start <= 1'b0;
            sa3_weight_load <= 1'b0;
        end
        else begin
            // Default values
            pe_start <= 1'b0;
            pe_weight_load <= 1'b0;
            sa2_start <= 1'b0;
            sa2_weight_load <= 1'b0;
            sa3_start <= 1'b0;
            sa3_weight_load <= 1'b0;
            done <= 1'b0;
            
            case (state)
                IDLE: begin
                    display_out <= 8'd0;
                end
                
                LOAD_WEIGHT: begin
                    // Load weights to all modules
                    pe_weight_load <= 1'b1;
                    sa2_weight_load <= 1'b1;
                    sa3_weight_load <= 1'b1;
                end
                
                CONV_PE: begin
                    pe_start <= 1'b1;
                end
                
                WAIT_PE: begin
                    if (pe_done) begin
                        // Store PE results
                        pe_result[0][0] <= pe_out_11;
                        pe_result[0][1] <= pe_out_12;
                        pe_result[1][0] <= pe_out_21;
                        pe_result[1][1] <= pe_out_22;
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
                    end
                end
                
                DISPLAY: begin
                    // Display results (example: show first SA3x3 result)
                    display_out <= sa3_result[0][0];
                end
                
                DONE_STATE: begin
                    done <= 1'b1;
                end
            endcase
        end
    end

endmodule