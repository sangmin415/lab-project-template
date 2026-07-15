`timescale 1ms/10ns

module ssdec_tb;
    logic [3:0] in;
    logic enable;
    logic [6:0] out;

    ssdec dut (
        .in(in),
        .enable(enable),
        .out(out)
    );

    function automatic logic [6:0] ssto_int(input logic [3:0] digit);
        case (digit)
            4'h0: ssto_int = 7'b0111111;
            4'h1: ssto_int = 7'b0000110;
            4'h2: ssto_int = 7'b1011011;
            4'h3: ssto_int = 7'b1001111;
            4'h4: ssto_int = 7'b1100110;
            4'h5: ssto_int = 7'b1101101;
            4'h6: ssto_int = 7'b1111101;
            4'h7: ssto_int = 7'b0000111;
            4'h8: ssto_int = 7'b1111111;
            4'h9: ssto_int = 7'b1100111;
            4'ha: ssto_int = 7'b1110111;
            4'hb: ssto_int = 7'b1111100;
            4'hc: ssto_int = 7'b0111001;
            4'hd: ssto_int = 7'b1011110;
            4'he: ssto_int = 7'b1111001;
            4'hf: ssto_int = 7'b1110001;
        endcase
    endfunction

    initial begin
        $dumpfile("waves/ssdec.vcd");
        $dumpvars(0, ssdec_tb);

        enable = 1'b0;
        in = 4'h0;

        for (integer i = 0; i < 16; i++) begin
            in = i[3:0];
            #1;
            $display("in=%h, enable=%b, out=%b", in, enable, out);
            if (out !== ssto_int(in)) begin
                $display("wrong output=%b, expected=%b", out, ssto_int(in));
            end
        end

        enable = 1'b1;
        #1;
        $display("in=%h, enable=%b, out=%b", in, enable, out);
        if (out !== 7'b0000000) begin
            $display("wrong blank output=%b, expected=0000000", out);
        end

        #1 $finish;
    end
endmodule
