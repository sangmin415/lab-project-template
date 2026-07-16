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

  assign left  = 8'b0;
  assign right = 8'b0;

  assign ss7 = 8'b0;
  assign ss6 = 8'b0;
  assign ss5 = 8'b0;
  assign ss4 = 8'b0;
  assign ss3 = 8'b0;
  assign ss2 = 8'b0;
  assign ss1 = 8'b0;
  assign ss0[7] = 1'b0;

  assign red   = 1'b0;
  assign green = 1'b0;
  assign blue  = 1'b0;
  assign txdata = 8'b0;
  assign txclk  = 1'b0;
  assign rxclk  = 1'b0;

  ssdec display (
      .in(pb[3:0]),
      .enable(pb[4]),
      .out(ss0[6:0])
  );

endmodule
