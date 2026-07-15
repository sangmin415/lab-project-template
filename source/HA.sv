`default_nettype none

module HA (
    input  logic A,
    input  logic B,
    output logic S,
    output logic Cout
);

    //  XOR
    assign S = A ^ B;

    // AND
    assign Cout = A & B;

endmodule 