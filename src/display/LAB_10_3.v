`timescale 1ns / 1ps

// ========================================
// Display controller for systolic array results
// ========================================
module display_controller (
    input clk,
    input rst,
    input enable,                    // Start display when computation done
    input [7:0] pe_c11, pe_c12, pe_c21, pe_c22,
    input [7:0] sa2_c11, sa2_c12, sa2_c21, sa2_c22,
    input [7:0] sa3_c11, sa3_c12, sa3_c21, sa3_c22,
    output reg [7:0] digit,          // reg로 변경 (always 문에서 제어)
    output [7:0] seg_data
);

    // ========================================
    // Clock dividers
    // ========================================
    wire clk_1hz;
    clock_divider #(.div(49999999)) div_1s (
        .clk(clk),
        .clk_1hz(clk_1hz)
    );
    
    wire clk_scan;
    clock_divider #(.div(49999)) div_scan ( // 약 1kHz (사람 눈에 깜빡임 없이 보임)
        .clk(clk),
        .clk_1hz(clk_scan)
    );

    // ========================================
    // Result cycling state machine (1초마다 결과 변경)
    // ========================================
    reg [3:0] result_idx;  // 0-11 for 12 results
    reg [7:0] current_value;
    
    always @(posedge clk_1hz or posedge rst) begin
        if (rst)
            result_idx <= 4'd0;
        else if (enable) begin
            if (result_idx == 4'd11)
                result_idx <= 4'd0;
            else
                result_idx <= result_idx + 1'b1;
        end
    end
    
    // Select current display value
    always @(*) begin
        case (result_idx)
            4'd0:  current_value = pe_c11;
            4'd1:  current_value = pe_c12;
            4'd2:  current_value = pe_c21;
            4'd3:  current_value = pe_c22;
            4'd4:  current_value = sa2_c11;
            4'd5:  current_value = sa2_c12;
            4'd6:  current_value = sa2_c21;
            4'd7:  current_value = sa2_c22;
            4'd8:  current_value = sa3_c11;
            4'd9:  current_value = sa3_c12;
            4'd10: current_value = sa3_c21;
            4'd11: current_value = sa3_c22;
            default: current_value = 8'd0;
        endcase
    end

    // ========================================
    // BCD conversion (현재 값을 100, 10, 1의 자리로 분리)
    // ========================================
    wire [3:0] hundreds, tens, ones;
    wire [7:0] display_value;
    
    // enable=0이면 0 표시, enable=1이면 current_value 표시
    assign display_value = enable ? current_value : 8'd0;
    
    assign hundreds = display_value / 8'd100;
    assign tens     = (display_value % 8'd100) / 8'd10;
    assign ones     = display_value % 8'd10;

    // 인덱스를 십진수로 표시 (0~11)
    wire [3:0] idx_tens, idx_ones;
    assign idx_tens = result_idx / 4'd10;  // 인덱스의 십의 자리
    assign idx_ones = result_idx % 4'd10;  // 인덱스의 일의 자리

    // ========================================
    // Digit scanning (Multiplexing) - 8 digits
    // ========================================
    reg [2:0] scan_sel; // 0~7까지 8개 Digit 스캔
    reg [3:0] digit_num;
    
    always @(posedge clk_scan or posedge rst) begin
        if (rst)
            scan_sel <= 3'd0;
        else
            scan_sel <= scan_sel + 1'b1;
    end
    
    // 앞 4자리: 값 (천/백/십/일)
    // 뒤 4자리: 인덱스 (0/0/십/일)
    always @(*) begin
        case (scan_sel)
            3'd0: begin // Digit 1 - 항상 0
                digit = 8'b0000_0001;
                digit_num = 4'd0;
            end
            3'd1: begin // Digit 2 - 항상 0
                digit = 8'b0000_0010;
                digit_num = 4'd0;
            end
            3'd2: begin // Digit 3 - 인덱스 십의 자리
                digit = 8'b0000_0100;
                digit_num = idx_tens;
            end
            3'd3: begin // Digit 4 - 인덱스 일의 자리
                digit = 8'b0000_1000;
                digit_num = idx_ones;
            end
            3'd4: begin // Digit 5 - 값의 일의 자리
                digit = 8'b0001_0000;
                digit_num = ones;
            end
            3'd5: begin // Digit 6 - 값의 십의 자리
                digit = 8'b0010_0000;
                digit_num = tens;
            end
            3'd6: begin // Digit 7 - 값의 백의 자리
                digit = 8'b0100_0000;
                digit_num = hundreds;
            end
            3'd7: begin // Digit 8 (맨 왼쪽) - 값의 천의 자리 (항상 0)
                digit = 8'b1000_0000;
                digit_num = 4'd0;
            end
            default: begin
                digit = 8'b0000_0000;
                digit_num = 4'd0;
            end
        endcase
    end
    
    // 7-segment decoder
    num_decoder seg_decoder (
        .num(digit_num),
        .seg_data(seg_data)
    );

endmodule
