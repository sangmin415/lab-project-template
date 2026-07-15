`timescale 1ms/10ns

module bcdadd1_tb;
    logic [3:0] A, B, S;
    logic Cin, Cout;

    bcdadd1 dut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    function automatic logic [3:0] bcd_sum(input integer value);
        integer ones;
        begin
            ones = value % 10;
            bcd_sum = ones[3:0];
        end
    endfunction

    function automatic logic bcd_cout(input integer value);
        begin
            bcd_cout = (value >= 10);
        end
    endfunction

    initial begin
        $dumpfile("waves/bcdadd1.vcd");
        $dumpvars(0, bcdadd1_tb);

        for (integer i = 0; i <= 9; i++) begin
            for (integer j = 0; j <= 9; j++) begin
                for (integer k = 0; k <= 1; k++) begin
                    A = i[3:0];
                    B = j[3:0];
                    Cin = k[0];
                    #1;
                    $display("A=%0d, B=%0d, Cin=%b => Cout=%b, S=%0d", A, B, Cin, Cout, S);
                    if (S !== bcd_sum(i + j + k) || Cout !== bcd_cout(i + j + k)) begin
                        $display(
                            "wrong output Cout=%b S=%0d, expected Cout=%b S=%0d",
                            Cout, S, bcd_cout(i + j + k), bcd_sum(i + j + k)
                        );
                    end
                end
            end
        end

        #1 $finish;
    end
endmodule
