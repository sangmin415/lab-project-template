`default_nettype none

module top (
  // I/O ports
  input  logic hz100, reset,
  input  logic [20:0] pb,
  output logic [7:0] left, right,
         ss7, ss6, ss5, ss4, ss3, ss2, ss1, ss0,
  output logic red, green, blue,

  // UART ports
  output logic [7:0] txdata,
  input  logic [7:0] rxdata,
  output logic txclk, rxclk,
  input  logic txready, rxready
);
  logic [3:0] bcd_sum;
  logic       bcd_cout;

  assign left  = 8'b0;
  assign right = 8'b0;

  assign ss7[7] = 1'b0;
  assign ss6 = 8'b0;
  assign ss5[7] = 1'b0;
  assign ss4 = 8'b0;
  assign ss3 = 8'b0;
  assign ss2 = 8'b0;
  assign ss1[7] = 1'b0;
  assign ss0[7] = 1'b0;

  assign red   = 1'b0;
  assign green = 1'b0;
  assign blue  = 1'b0;
  assign txdata = 8'b0;
  assign txclk  = 1'b0;
  assign rxclk  = 1'b0;

  bcdadd1 bcd_adder (
      .A(pb[3:0]),
      .B(pb[7:4]),
      .Cin(pb[8]),
      .S(bcd_sum),
      .Cout(bcd_cout)
  );

  ssdec bcd_a_display (
      .in(pb[3:0]),
      .enable(1'b0),
      .out(ss7[6:0])
  );

  ssdec bcd_b_display (
      .in(pb[7:4]),
      .enable(1'b0),
      .out(ss5[6:0])
  );

  ssdec bcd_cout_display (
      .in({3'b0, bcd_cout}),
      .enable(1'b0),
      .out(ss1[6:0])
  );

  ssdec bcd_sum_display (
      .in(bcd_sum),
      .enable(1'b0),
      .out(ss0[6:0])
  );

endmodule
