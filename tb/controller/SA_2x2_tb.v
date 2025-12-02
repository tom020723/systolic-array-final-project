// SA_2x2_tb.v: Testbench for the SA_2x2 module (Manual, Corrected Data Flow and Timing)

`timescale 1ns / 1ns

module SA_2x2_tb;

    // --- 1. Testbench Signals & Parameters ---
    reg clk;
    reg reset;
    reg [7:0] A_in_11, A_in_12, A_in_21, A_in_22;
    reg [7:0] B_in_11, B_in_12, B_in_21, B_in_22;
    wire [7:0] C_out_11, C_out_12, C_out_21, C_out_22;

    parameter DATA_VALUE = 8'd1;
    parameter CLOCK_PERIOD = 10;
    
    // --- 2. 테스트 데이터 저장소 (Memory 역할 대행) ---
    // for 루프 대신 수동으로 할당하기 위해 reg로 선언
    reg [7:0] A_matrix [1:4][1:4]; 
    reg [7:0] B_matrix [1:3][1:3]; 

    // --- 3. DUT (Device Under Test) 인스턴스화 ---
    SA_2x2 DUT (
        .clk(clk), .reset(reset),
        .A_in_11(A_in_11), .A_in_12(A_in_12), .A_in_21(A_in_21), .A_in_22(A_in_22),
        .B_in_11(B_in_11), .B_in_12(B_in_12), .B_in_21(B_in_21), .B_in_22(B_in_22),
        .C_out_11(C_out_11), .C_out_12(C_out_12), .C_out_21(C_out_21), .C_out_22(C_out_22)
    );

    // --- 4. Clock Generation ---
    initial begin
        clk = 1'b0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk; 
    end

    // --- 5. Stimulus (Reset & Data Injection) ---
    initial begin
        $display("Starting SA_2x2 Testbench. Expected Output: 9");

        // A, B 행렬 초기화: 수동 할당 (for 루프 오류 방지)
        // A matrix (All 1)
        A_matrix[1][1]=2; A_matrix[1][2]=1; A_matrix[1][3]=3; A_matrix[1][4]=1;
        A_matrix[2][1]=2; A_matrix[2][2]=3; A_matrix[2][3]=2; A_matrix[2][4]=1;
        A_matrix[3][1]=3; A_matrix[3][2]=2; A_matrix[3][3]=2; A_matrix[3][4]=2;
        A_matrix[4][1]=1; A_matrix[4][2]=1; A_matrix[4][3]=1; A_matrix[4][4]=2;

        // B matrix (All 1)
        B_matrix[1][1]=1; B_matrix[1][2]=3; B_matrix[1][3]=1;
        B_matrix[2][1]=2; B_matrix[2][2]=1; B_matrix[2][3]=2;
        B_matrix[3][1]=1; B_matrix[3][2]=1; B_matrix[3][3]=3;
        
        // --- 1. Reset 및 초기화 ---
        reset = 1'b1;
        {A_in_11, A_in_12, A_in_21, A_in_22, B_in_11, B_in_12, B_in_21, B_in_22} = 64'b0;

        #(CLOCK_PERIOD) reset = 1'b0; // Reset 해제

        // --- 2. 초기화 안정화 대기 (C_in_acc=0 확정) ---
        #(CLOCK_PERIOD) ; // Reset 해제 후 1 클록 사이클 대기

        // --- 3. 9번의 MAC 사이클 시작 (t=1 부터 t=9) ---
        
        // t=1: (A11, A12, A21, A22) vs B33
        #(CLOCK_PERIOD) assign_data(A_matrix[1][1], A_matrix[1][2], A_matrix[2][1], A_matrix[2][2], B_matrix[3][3]);
        
        // t=2: (A12, A13, A22, A23) vs B32
        #(CLOCK_PERIOD) assign_data(A_matrix[1][2], A_matrix[1][3], A_matrix[2][2], A_matrix[2][3], B_matrix[3][2]);

        // t=3: (A13, A14, A23, A24) vs B31
        #(CLOCK_PERIOD) assign_data(A_matrix[1][3], A_matrix[1][4], A_matrix[2][3], A_matrix[2][4], B_matrix[3][1]);
        
        // t=4: (A21, A22, A31, A32) vs B23
        #(CLOCK_PERIOD) assign_data(A_matrix[2][1], A_matrix[2][2], A_matrix[3][1], A_matrix[3][2], B_matrix[2][3]);
        
        // t=5: (A22, A23, A32, A33) vs B22
        #(CLOCK_PERIOD) assign_data(A_matrix[2][2], A_matrix[2][3], A_matrix[3][2], A_matrix[3][3], B_matrix[2][2]);
        
        // t=6: (A23, A24, A33, A34) vs B21
        #(CLOCK_PERIOD) assign_data(A_matrix[2][3], A_matrix[2][4], A_matrix[3][3], A_matrix[3][4], B_matrix[2][1]);
        
        // t=7: (A31, A32, A41, A42) vs B13
        #(CLOCK_PERIOD) assign_data(A_matrix[3][1], A_matrix[3][2], A_matrix[4][1], A_matrix[4][2], B_matrix[1][3]);
        
        // t=8: (A32, A33, A42, A43) vs B12
        #(CLOCK_PERIOD) assign_data(A_matrix[3][2], A_matrix[3][3], A_matrix[4][2], A_matrix[4][3], B_matrix[1][2]);
        
        // t=9: (A33, A34, A43, A44) vs B11 (마지막 MAC)
        #(CLOCK_PERIOD) assign_data(A_matrix[3][3], A_matrix[3][4], A_matrix[4][3], A_matrix[4][4], B_matrix[1][1]);

        // --- 4. 계산 완료 후 데이터 제거 ---
        #(CLOCK_PERIOD) assign_data(8'b0, 8'b0, 8'b0, 8'b0, 8'b0);

        // --- 5. 결과 확인 ---
        #1 $display("---------------------------------");
        #1 $display("Calculation Complete.");
        #0 $display("C11: %d, C12: %d, C21: %d, C22: %d (Expected: 9)", C_out_11, C_out_12, C_out_21, C_out_22);
        
        #100 $finish;
    end
    
    // ----------------------------------------------------
    // 태스크: 4개 PE에 A 데이터와 공통 B 데이터 할당
    // ----------------------------------------------------
    task assign_data;
        input [7:0] a11, a12, a21, a22; // 4개의 A 입력
        input [7:0] b_val;              // 공통 B 입력 (필터 회전 값)
        begin
            // A 입력 (각 PE에 다른 값)
            A_in_11 = a11; A_in_12 = a12; A_in_21 = a21; A_in_22 = a22;
            // B 입력 (모든 PE에 같은 값)
            B_in_11 = b_val; B_in_12 = b_val; B_in_21 = b_val; B_in_22 = b_val;
        end
    endtask

endmodule
