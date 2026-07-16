`default_nettype none

module fa (
    input  logic A,
    input  logic B,
    input  logic Cin,
    output logic S,
    output logic Cout
);
    logic ha0_sum, ha0_carry, ha1_carry;

    HA ha0 (
        .A(A),
        .B(B),
        .S(ha0_sum),
        .Cout(ha0_carry)
    );

    HA ha1 (
        .A(ha0_sum),
        .B(Cin),
        .S(S),
        .Cout(ha1_carry)
    );

    assign Cout = ha0_carry | ha1_carry;
endmodule
