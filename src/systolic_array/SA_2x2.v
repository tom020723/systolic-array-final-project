
// 2x2 Systolic Array Module (SA_2x2)
// 4개의 PE가 독립적으로 누적 계산을 수행하는 병렬 구조입니다.

module SA_2x2 (
    // 클록 및 제어 신호
    input wire clk,
    input wire reset,         // PE 내부 누산기 초기화 신호 (Controller에서 제어)
    
    // 데이터 입력 (Memory에서 Controller의 명령에 따라 클록마다 공급됨)
    // 4x4 행렬의 4개 PE 영역에 필요한 현재 클록의 A 입력
    // A_in_11: C11 계산 영역의 A 데이터
    input wire [7:0] A_in_11, A_in_12, A_in_21, A_in_22, 
    
    // 3x3 필터의 4개 PE 영역에 필요한 현재 클록의 B 입력
    input wire [7:0] B_in_11, B_in_12, B_in_21, B_in_22,
    
    // 출력 (4개의 최종 계산 결과)
    output wire [7:0] C_out_11, C_out_12, C_out_21, C_out_22
);
    
    // 내부 와이어: PE 간 피드백 루프를 위한 와이어 선언 (16비트 누적 값)
    // C_acc_reg_xx: 각 PE의 이전 클록 누적 값을 저장하고 PE의 C_in_acc로 피드백됩니다.
    // PE 모듈 내부에서 C_out_acc가 reg로 선언되어 있다면, 별도의 reg 선언 없이 PE의 C_out_acc를 C_in_acc에 연결합니다.
    
    // 4개의 PE 인스턴스화 및 구조적 연결 (Structural Modeling)
    
    // ----------------------------------------------------
    // PE_11 (C_11 계산 담당) - 자기 피드백 (Self-Feedback)
    // ----------------------------------------------------
    PE_8bit PE_11 (
        .clk(clk),
        .reset(reset),
        
        // 데이터 입력: Memory로부터 직접 공급
        .A_in(A_in_11), 
        .B_in(B_in_11), 
        
        // 누적 값 입력 (C_in_acc): 자기 자신의 C_out_acc와 연결하여 피드백
        // 즉, 이전 클록 사이클에 PE가 계산했던 누적 값을 다시 입력으로 받습니다.
        .C_in_acc(PE_11.C_out_acc), 
        
        // 누적 값 출력 (C_out_acc): 다음 사이클 피드백을 위해 출력 (내부적으로 reg)
        .C_out_acc(), // 이 PE의 누적 레지스터를 피드백에 바로 사용
        
        // 최종 8비트 출력
        .C_out_final(C_out_11)
    );
    
    // ----------------------------------------------------
    // PE_12 (C_12 계산 담당) - 독립적 계산
    // ----------------------------------------------------
    PE_8bit PE_12 (
        .clk(clk), .reset(reset),
        .A_in(A_in_12), .B_in(B_in_12), 
        
        // 자기 피드백
        .C_in_acc(PE_12.C_out_acc),
        .C_out_acc(), 
        
        .C_out_final(C_out_12)
    );
    
    // ----------------------------------------------------
    // PE_21 (C_21 계산 담당) - 독립적 계산
    // ----------------------------------------------------
    PE_8bit PE_21 (
        .clk(clk), .reset(reset),
        .A_in(A_in_21), .B_in(B_in_21), 
        
        // 자기 피드백
        .C_in_acc(PE_21.C_out_acc),
        .C_out_acc(),
        
        .C_out_final(C_out_21)
    );

    // ----------------------------------------------------
    // PE_22 (C_22 계산 담당) - 독립적 계산
    // ----------------------------------------------------
    PE_8bit PE_22 (
        .clk(clk), .reset(reset),
        .A_in(A_in_22), .B_in(B_in_22), 
        
        // 자기 피드백
        .C_in_acc(PE_22.C_out_acc),
        .C_out_acc(),
        
        .C_out_final(C_out_22)
    );
    
endmodule
