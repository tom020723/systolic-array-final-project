module top_module (
    input clk,
    input rst_n,            // Active-low reset from board (U7)
    input start,            // Active-high push button (M20)
    output [7:0] digit,      // 7-segment digit select
    output [7:0] seg_data    // 7-segment data
);

    // Convert active-low reset to active-high for internal use
    wire rst;
    assign rst = ~rst_n;

    // ========================================
    // Controller instantiation
    // ========================================
    wire controller_done;
    wire [7:0] pe_c11, pe_c12, pe_c21, pe_c22;
    wire [7:0] sa2_c11, sa2_c12, sa2_c21, sa2_c22;
    wire [7:0] sa3_c11, sa3_c12, sa3_c21, sa3_c22;
    
    controller ctrl_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(controller_done),
        // Debug outputs connected directly
        .pe_out_c11(pe_c11), .pe_out_c12(pe_c12), .pe_out_c21(pe_c21), .pe_out_c22(pe_c22),
        .sa2_out_c11(sa2_c11), .sa2_out_c12(sa2_c12), .sa2_out_c21(sa2_c21), .sa2_out_c22(sa2_c22),
        .sa3_out_c11(sa3_c11), .sa3_out_c12(sa3_c12), .sa3_out_c21(sa3_c21), .sa3_out_c22(sa3_c22)
    );
    
    // ========================================
    // Display controller instantiation
    // ========================================
    display_controller disp_ctrl (
        .clk(clk),
        .rst(rst),
        .enable(controller_done),
        .pe_c11(pe_c11), .pe_c12(pe_c12), .pe_c21(pe_c21), .pe_c22(pe_c22),
        .sa2_c11(sa2_c11), .sa2_c12(sa2_c12), .sa2_c21(sa2_c21), .sa2_c22(sa2_c22),
        .sa3_c11(sa3_c11), .sa3_c12(sa3_c12), .sa3_c21(sa3_c21), .sa3_c22(sa3_c22),
        .digit(digit),
        .seg_data(seg_data)
    );

endmodule