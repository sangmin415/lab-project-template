`default_nettype none

module enc20to5 (
    input  logic [19:0] in,
    output logic [4:0]  out,
    output logic        strobe
);
    always @* begin
        out = 5'd0;
        if (in[19]) out = 5'd19;
        else if (in[18]) out = 5'd18;
        else if (in[17]) out = 5'd17;
        else if (in[16]) out = 5'd16;
        else if (in[15]) out = 5'd15;
        else if (in[14]) out = 5'd14;
        else if (in[13]) out = 5'd13;
        else if (in[12]) out = 5'd12;
        else if (in[11]) out = 5'd11;
        else if (in[10]) out = 5'd10;
        else if (in[9]) out = 5'd9;
        else if (in[8]) out = 5'd8;
        else if (in[7]) out = 5'd7;
        else if (in[6]) out = 5'd6;
        else if (in[5]) out = 5'd5;
        else if (in[4]) out = 5'd4;
        else if (in[3]) out = 5'd3;
        else if (in[2]) out = 5'd2;
        else if (in[1]) out = 5'd1;
        else if (in[0]) out = 5'd0;
    end

    assign strobe = |in;
endmodule
