# Lesson 2 / Lab 2 이론 정리

## 시작하기: 먼저 전체 그림부터

이 문서는 SystemVerilog 문법이나 인코더, 디코더를 아직 확실히 모른다는 전제로 읽는다. 지금 단계에서 중요한 것은 코드를 외우는 것이 아니라, 각 모듈이 회로에서 맡는 역할을 구분하는 것이다.

Lab 2 전체 흐름은 다음과 같다.

    버튼/입력 -> 입력을 해석하거나 계산하는 조합논리 -> LED 또는 seven-segment 출력

현재 만드는 세 부품은 모두 이 흐름의 중간에 들어간다.

    pb[9] 버튼을 누름
      -> enc20to5: "눌린 버튼 번호는 9"를 5비트 값으로 만듦
      -> ssdec: 4비트 숫자 9를 seven-segment의 A-G 켜기 신호로 바꿈
      -> seven-segment에 9가 보임

### 인코더와 디코더는 반대 방향이다

    인코더(encoder): 여러 입력선 -> 짧은 이진 번호
    디코더(decoder): 짧은 이진 번호 -> 여러 출력선

버튼 20개는 각각 독립된 선이다. 인코더는 그중 어떤 버튼이 눌렸는지를 5비트 번호로 압축한다. 반대로 seven-segment는 숫자 하나를 표시하려면 A-G라는 7개 선을 각각 켜거나 꺼야 한다. 디코더는 4비트 숫자를 받아 그 7개 선의 상태를 만든다.

### 왜 priority encoder가 필요한가

일반 encoder는 "한 번에 버튼 하나만 눌린다"고 가정한다. 하지만 실제로는 버튼 두 개가 동시에 눌릴 수 있다. 이때 어느 버튼 번호를 출력할지 정하지 않으면 결과가 모호하다.

priority encoder는 규칙을 하나 둔다. Lab 2의 규칙은 "가장 번호가 높은 버튼이 이긴다"이다.

    pb[19]와 pb[4]를 동시에 누름 -> 출력은 19

그래서 priority encoder는 버튼 입력이 여러 개 들어와도 항상 하나의 명확한 결과를 낸다. strobe는 "아무 버튼도 안 눌렀음"과 "pb[0]만 눌렀음"이 둘 다 out=0이 되는 문제를 구분하는 신호다.

### 지금 필요한 SystemVerilog 문법 네 가지

1. module: 회로 부품 하나의 설계도다. fa4, ssdec, enc20to5가 각각 하나의 부품이다.
2. input / output: 부품의 핀이다. input은 들어오는 선, output은 나가는 선이다.
3. assign: 항상 연결된 단순 논리식이다. 예를 들어 assign strobe = |in;은 입력 버튼 중 하나라도 눌리면 strobe를 1로 연결한다.
4. always_comb: 현재 입력값을 보고 현재 출력값을 결정하는 조합논리 블록이다. case, if, priority encoder에 주로 사용한다.

다음 RISC-V에서 이 부품들은 더 큰 회로 안에 들어간다. 지금은 먼저 "입력 -> 조합논리 -> 출력" 흐름과 각 부품의 입출력만 설명할 수 있으면 충분하다.

## 1. 이 랩의 핵심: 조합논리

조합논리(combinational logic)는 현재 입력만으로 현재 출력이 결정되는 회로다. 이전 값, 클록, 내부 상태를 기억하지 않는다.

    현재 입력 -> 조합논리 -> 현재 출력

가산기, 디코더, 인코더, 멀티플렉서, 비교기는 조합논리다. 반대로 레지스터, 카운터, CPU의 상태 제어는 클록과 과거 값을 가지므로 순차논리(sequential logic)다.

SystemVerilog에서는 간단한 논리를 assign으로, 조건과 우선순위가 있는 논리를 always_comb으로 표현한다.

    assign y = a & b;

    always_comb begin
        if (sel) y = b;
        else     y = a;
    end

always_comb 안에서 출력에 모든 경우의 값을 할당해야 한다. 특정 경우에 값이 빠지면 합성기가 이전 값을 저장하는 latch를 만들 수 있다. latch는 기억소자이므로 이 랩의 조합논리 목적과 맞지 않는다.

## 2. 4비트 이진 가산기와 BCD 가산기

### 보통의 4비트 가산기 fa4

fa4는 이진 덧셈을 한다.

    A + B + Cin = {Cout, S}

S는 하위 4비트, Cout는 다섯 번째 비트다. 예를 들어 7+3은:

    0111 + 0011 = 1010

1010은 이진수로 10이다. 그러나 4비트 하나를 16진 표시로 보면 A가 된다. 계산은 맞지만, 사람이 십진수 10을 기대할 때 A를 표시하면 안 된다.

### BCD란 무엇인가

BCD(Binary-Coded Decimal)는 십진수의 각 자릿수를 4비트로 따로 표현한다.

    십진수 15의 BCD: 0001 0101
                       1    5

    이진수 15:         1111
                       16진수 F

한 자리 BCD는 0부터 9까지만 유효하다. 1010부터 1111은 한 자리 BCD로는 사용하지 않는 패턴이다.

### 왜 6을 더하는가

첫 번째 fa4가 만든 raw binary sum이 0부터 9면 이미 BCD로 유효하다. 10부터 19면 보정이 필요하다.

    raw 값        원하는 BCD 하위 자리       보정
    10 (1010)     carry=1, ones=0            +6 -> 1_0000
    11 (1011)     carry=1, ones=1            +6 -> 1_0001
    ...
    15 (1111)     carry=1, ones=5            +6 -> 1_0101

차이가 항상 6이므로 0110을 더한다. 16부터 19는 첫 번째 가산기에서 raw_cout=1이고 하위 4비트가 0부터 3이다. 여기에 6을 더하면 하위 자리가 6부터 9가 되며, 십의 자리는 여전히 1이다.

보정 조건은 다음과 같다.

    correction = raw_cout OR (raw_sum > 9)

4비트 raw_sum이 9보다 큰 조건은 간단히 다음과 같이 쓸 수 있다.

    raw_sum[3] AND (raw_sum[2] OR raw_sum[1])

따라서 현재 구현의 식은 다음과 같다.

    correction = raw_cout | (raw_sum[3] & (raw_sum[2] | raw_sum[1]));

두 번째 가산기에는 correction이 0이면 0000, 1이면 0110을 넣는다.

    add_six = {1'b0, correction, correction, 1'b0};

하드웨어 구조는 다음과 같다.

    A ----\
            [ fa4 #1 ] -> raw_sum ----\
    B ----/                raw_cout    [ fa4 #2 ] -> S
    Cin ------------------------------/       ^
                                                 |
                            correction ? 0110 : 0000

    Cout = correction

중요: 최종 BCD Cout는 두 번째 가산기의 carry만 쓰면 안 된다. 총합이 16부터 19일 때 두 번째 가산기의 carry는 0일 수 있지만, 십의 자리는 반드시 1이다. 그래서 Cout=correction이다.

예시:

    7+2+0: raw=01001, correction=0 -> Cout=0, S=1001 -> 9
    7+3+0: raw=01010, correction=1 -> 1010+0110=1_0000 -> 10
    9+9+0: raw=1_0010, correction=1 -> 0010+0110=1000 -> 18

Lab 2의 bcdadd1은 입력 A와 B가 유효한 BCD 숫자 0부터 9일 때만 맞으면 된다.

## 3. Seven-segment decoder ssdec

디코더(decoder)는 적은 비트의 입력 코드를 여러 출력으로 풀어 주는 회로다. ssdec은 4비트 16진 입력을 seven-segment의 A부터 G 제어 신호로 바꾼다.

    ssX[0] = A        ssX[4] = E
    ssX[1] = B        ssX[5] = F
    ssX[2] = C        ssX[6] = G
    ssX[3] = D        ssX[7] = decimal point

ssdec은 decimal point를 담당하지 않으므로 ssX[6:0]만 연결한다. 패턴은 bit 6이 G, bit 0이 A이므로 GFEDCBA 순서다.

0의 경우 A부터 F는 켜고 G는 끈다.

    GFEDCBA = 0111111

9의 경우 D 세그먼트는 꺼져야 한다.

    GFEDCBA = 1100111

D까지 켜면 9가 아니라 작은 g처럼 보인다.

### enable의 의미

현재 프로젝트의 ssdec에서 enable은 논리적인 blank 제어다.

    enable=0 -> 입력 숫자를 표시
    enable=1 -> out=0000000, 공백

즉 active-low display enable 또는 active-high blank로 해석할 수 있다. 이것은 물리 LED가 active-low인지 active-high인지와 별개의 문제다. 근거 없이 둘 다 반전하면 안 된다.

Lab 2의 ssdec 단독 보드 연결은 다음과 같다.

    pb[3:0] -> in
    pb[4]   -> enable
    out     -> ss0[6:0]

버튼을 누르지 않으면 0이 보이고, pb[4]를 누르면 공백이 되어야 한다.

case 문은 16개의 입력 패턴을 16개의 고정 출력 패턴으로 바꾸는 truth table을 가장 직접적으로 표현한다. FPGA에서는 이것이 LUT 논리로 합성된다.

## 4. Regular encoder와 priority encoder

일반 encoder는 정확히 하나의 입력만 1이라는 가정을 한다. 여러 입력이 동시에 1이면 OR 식으로 만든 출력은 어느 입력을 뜻하는지 모호해질 수 있다.

priority encoder는 이 문제를 정책으로 해결한다. enc20to5는 가장 번호가 높은 입력을 선택한다.

    in[19]와 in[4]가 모두 1 -> out=19
    in[12]와 in[3]가 모두 1 -> out=12

입력이 20개이므로 출력에는 5비트가 필요하다. 4비트로는 0부터 15까지만 표현할 수 있다.

현재 구현은 높은 번호부터 if / else-if로 검사한다.

    if (in[19]) out = 5'd19;
    else if (in[18]) out = 5'd18;
    ...
    else if (in[0]) out = 5'd0;

먼저 참이 된 조건이 선택되므로 19가 가장 높은 우선순위를 가진다.

### strobe가 필요한 이유

out=0만으로는 두 경우를 구분할 수 없다.

    아무 버튼도 안 누름       -> default out=0
    pb[0]만 누름             -> out=0

그래서 strobe를 사용한다.

    assign strobe = |in;

|in은 reduction OR이다. 20비트 전체를 OR하므로 하나라도 버튼이 눌리면 1, 모두 놓으면 0이다.

Lab 2 보드 연결:

    pb[19:0] -> enc20to5.in
    out      -> right[4:0]
    strobe   -> red

ssdec은 4비트 입력을 16진 숫자로 표시하므로, out=10부터 19를 십진수로 보이려면 두 자리 보정이 필요하다.

    out 0..9:  tens=0, ones=out
    out 10..19: tens=1, ones=out-10

## 5. Testbench와 GTKWave

테스트벤치는 FPGA에 올라가는 코드가 아니라 시뮬레이션용 코드다. DUT를 인스턴스화하고, 입력을 바꾸고, 결과를 확인하며, VCD 파형을 만든다.

### ssdec_tb

0부터 F까지 16개 입력과 enable=1의 blank 경우를 검사한다. 기대값 함수가 seven-segment 패턴을 다시 적는 것은 의도적이다. DUT와 독립된 기대값 기준이 있어야 검증이 된다.

### bcdadd1_tb

유효한 BCD 입력만 검사한다.

    A=0..9, B=0..9, Cin=0..1
    총 10 x 10 x 2 = 200개 경우

각 경우 value=A+B+Cin에 대해:

    expected S = value % 10
    expected Cout = (value >= 10)

특히 9+0+1=10, 9+9=18, 9+9+1=19가 핵심 경계 사례다.

### enc20to5_tb

2^20 전체 입력을 시험하면 1,048,576가지라서 하지 않는다. Lab 2가 요구하는 것은:

1. 아무 버튼도 누르지 않은 경우
2. 0부터 19까지 각 버튼 하나씩 누른 경우
3. 우선순위를 증명하는 다중 버튼 사례 몇 개

가장 중요한 다중 입력 사례는 19와 4를 같이 누른 경우이며, out=19와 strobe=1이어야 한다.

WSL에서 실행한다.

    cd /mnt/c/lab-project-template
    make sim_ssdec_src
    make sim_bcdadd1_src
    make sim_enc20to5_src

GTKWave에서는 Zoom Fit을 누른다. encoder out은 Decimal로 바꾸면 0부터 19를 읽기 쉽다. ssdec.out은 bus를 펼치면 각 세그먼트 bit를 볼 수 있다.

## 6. FPGA flow와 top의 역할

ssdec, bcdadd1, enc20to5는 재사용 가능한 하위 모듈이다. top은 이 논리를 실제 보드 버튼과 LED, seven-segment 핀에 연결한다.

    buttons -> top -> Lab 2 modules -> LEDs / seven-segment

프로젝트 흐름:

    SystemVerilog
      -> Verilator lint
      -> Yosys synthesis
      -> nextpnr place and route
      -> icepack bitstream
      -> iceprog로 CRAM 또는 flash 프로그램

make cram은 전원이 꺼지면 사라지는 CRAM에 올린다. make flash는 전원을 껐다 켜도 남는 flash에 쓴다. Lab 2 시연에는 보통 cram이면 충분하다.

## 7. 다음 RISC-V에서 이어지는 개념

Lab 2의 모듈은 큰 설계 안에서 다시 등장한다.

    decoder          -> 제어 코드를 실제 동작 선택으로 바꿈
    priority encoder -> 여러 요청 중 하나를 선택
    adder            -> 연산과 주소 증가
    combinational    -> 레지스터 사이의 다음 값을 계산

RISC-V에서 가장 중요한 다음 단계는 상태와 조합논리를 구분하는 것이다.

    레지스터는 현재 상태를 저장한다.
    조합논리는 현재 상태와 입력에서 다음 값을 계산한다.
    clock edge에서 다음 값이 레지스터에 저장된다.

문법을 모두 외우는 것보다 이 구분을 이해하는 편이 훨씬 중요하다.


