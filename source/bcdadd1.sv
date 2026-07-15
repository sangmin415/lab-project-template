`default_nettype none

module bcdadd1 (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic       Cin,
    output logic [3:0] S,
    output logic       Cout
);
    logic [3:0] raw_sum;
    logic       raw_cout;
    logic       correction;
    logic [3:0] add_six;
    logic       add_six_cout;

    fa4 first_add (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(raw_sum),
        .Cout(raw_cout)
    );

    assign correction = raw_cout | (raw_sum[3] & (raw_sum[2] | raw_sum[1]));
    assign add_six = {1'b0, correction, correction, 1'b0};

    fa4 correction_add (
        .A(raw_sum),
        .B(add_six),
        .Cin(1'b0),
        .S(S),
        .Cout(add_six_cout)
    );

    assign Cout = correction;

    // The second adder's carry is intentionally not the BCD carry for sums 16-19.
    logic _unused;
    assign _unused = add_six_cout;
endmodule
