`timescale 1ms/10ns

module fa4_tb;
    logic [3:0] A, B, S;
    logic Cin, Cout;

    fa4 dut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("waves/fa4.vcd");
        $dumpvars(0, fa4_tb);

        for (integer i = 0; i < 16; i++) begin
            for (integer j = 0; j < 16; j++) begin
                for (integer k = 0; k < 2; k++) begin
                    A = i[3:0];
                    B = j[3:0];
                    Cin = k[0];
                    #1;

                    $display(
                        "A=%b, B=%b, Cin=%b => S=%b, Cout=%b",
                        A, B, Cin, S, Cout
                    );
                end
            end
        end

        #1 $finish;
    end
endmodule
