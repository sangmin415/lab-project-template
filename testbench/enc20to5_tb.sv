`timescale 1ms/10ns

module enc20to5_tb;
    logic [19:0] in;
    logic [4:0] out;
    logic strobe;

    enc20to5 dut (
        .in(in),
        .out(out),
        .strobe(strobe)
    );

    task automatic check(input logic [19:0] value, input logic [4:0] expected_out);
        in = value;
        #1;
        $display("in=%020b, out=%0d, strobe=%b", in, out, strobe);
        if (out !== expected_out || strobe !== (|value)) begin
            $display(
                "wrong output out=%0d strobe=%b, expected out=%0d strobe=%b",
                out, strobe, expected_out, |value
            );
        end
    endtask

    initial begin
        $dumpfile("waves/enc20to5.vcd");
        $dumpvars(0, enc20to5_tb);

        check(20'b0, 5'd0);

        for (integer i = 0; i < 20; i++) begin
            check(20'b1 << i, i[4:0]);
        end

        check((20'b1 << 19) | (20'b1 << 4), 5'd19);
        check((20'b1 << 12) | (20'b1 << 3), 5'd12);
        check((20'b1 << 18) | (20'b1 << 17) | 20'b1, 5'd18);

        #1 $finish;
    end
endmodule
