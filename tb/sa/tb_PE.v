module tb_pe;

    reg        clk;
    reg        rst;
    reg        clear;
    reg  [7:0] a_in;
    reg  [7:0] b_in;

    wire [7:0] a_out;
    wire [7:0] b_out;
    wire [7:0] out;

    reg  [7:0] ans;   // TB에서 계산한 정답 (mod 256)

    // DUT 인스턴스
    pe #(
        .DATA_W(8),
        .ACC_W(8)
    ) dut (
        .clk   (clk),
        .rst   (rst),
        .clear (clear),
        .a_in  (a_in),
        .b_in  (b_in),
        .out   (out),
        .a_out (a_out),
        .b_out (b_out)
    );

    // 클럭 생성 (20ns 주기)
    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    // 초기값
    initial begin
        rst   = 1'b0;
        clear = 1'b0;
        a_in  = 8'd0;
        b_in  = 8'd0;
        ans   = 8'd0;
    end

    // 자극 발생
    // 예시: 3x3 한 칸 dot product처럼 9쌍 넣어서 MAC 동작 확인
    // (A, B는 그냥 예시용 값)
    initial begin
        $dumpfile("pe_output.vcd");
        $dumpvars(0, tb_pe);

        // reset
        #5  rst = 1'b1;
        #20 rst = 1'b0;

        // 누산기, 파이프라인 레지스터 clear
        pulse_clear();

        // 각 사이클마다 (a_in, b_in) 넣어주고,
        // ans = ans + a_in * b_in (8비트라 자동으로 하위 8비트만 남음)

        mac_step(8'd1, 8'd9);   // 예: 1*9
        mac_step(8'd2, 8'd8);   //    2*8
        mac_step(8'd3, 8'd7);   //    3*7
        mac_step(8'd4, 8'd3);   //    4*3
        mac_step(8'd5, 8'd2);   //    5*2
        mac_step(8'd6, 8'd1);   //    6*1
        mac_step(8'd7, 8'd8);   //    7*8
        mac_step(8'd8, 8'd9);   //    8*9
        mac_step(8'd9, 8'd2);   //    9*2

        // 마지막 값이 레지스터에 제대로 잡히도록 몇 클럭 기다림
        #40;

        $display("========================================");
        $display("ANS (expected) = %0d (0x%02h)", ans, ans);
        $display("OUT (from PE)  = %0d (0x%02h)", out, out);
        $display("========================================");

        $finish;
    end

    // 한 번의 MAC 스텝: 네거티브 엣지에서 입력 바꾸고 ans 업데이트
    task mac_step(input [7:0] a, input [7:0] b);
    begin
        @(negedge clk);
        a_in = a;
        b_in = b;
        ans  = ans + a * b;  // 8비트라 overflow 나면 자동으로 잘림
    end
    endtask

    // clear를 한 사이클 동안 1로 만들어서 reg8 세 개 다 0으로 초기화
    task pulse_clear;
    begin
        @(negedge clk);
        clear = 1'b1;
        @(negedge clk);
        clear = 1'b0;
    end
    endtask

endmodule