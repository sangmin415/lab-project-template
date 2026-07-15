`default_nettype none

module fa4 (
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic       Cin,
    output logic [3:0] S,
    output logic       Cout
);
    logic [2:0] carry;

    fa fa0 (
        .A(A[0]),
        .B(B[0]),
        .Cin(Cin),
        .S(S[0]),
        .Cout(carry[0])
    );

    fa fa1 (
        .A(A[1]),
        .B(B[1]),
        .Cin(carry[0]),
        .S(S[1]),
        .Cout(carry[1])
    );

    fa fa2 (
        .A(A[2]),
        .B(B[2]),
        .Cin(carry[1]),
        .S(S[2]),
        .Cout(carry[2])
    );

    fa fa3 (
        .A(A[3]),
        .B(B[3]),
        .Cin(carry[2]),
        .S(S[3]),
        .Cout(Cout)
    );
endmodule
