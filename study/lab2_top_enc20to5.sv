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
  logic [4:0] enc_out;
  logic       enc_strobe;
  logic [3:0] enc_ones;
  logic [3:0] enc_tens;

  assign left = 8'b0;
  assign right[7:5] = 3'b0;

  assign ss7 = 8'b0;
  assign ss6 = 8'b0;
  assign ss5 = 8'b0;
  assign ss4 = 8'b0;
  assign ss3[7] = 1'b0;
  assign ss2[7] = 1'b0;
  assign ss1 = 8'b0;
  assign ss0 = 8'b0;

  assign green = 1'b0;
  assign blue  = 1'b0;
  assign txdata = 8'b0;
  assign txclk  = 1'b0;
  assign rxclk  = 1'b0;

  enc20to5 encoder (
      .in(pb[19:0]),
      .out(enc_out),
      .strobe(enc_strobe)
  );

  assign right[4:0] = enc_out;
  assign red = enc_strobe;
  assign enc_tens = (enc_out >= 5'd10) ? 4'd1 : 4'd0;
  assign enc_ones = (enc_out >= 5'd10) ? (enc_out[3:0] - 4'd10) : enc_out[3:0];

  ssdec enc_tens_display (
      .in(enc_tens),
      .enable(~enc_strobe),
      .out(ss3[6:0])
  );

  ssdec enc_ones_display (
      .in(enc_ones),
      .enable(~enc_strobe),
      .out(ss2[6:0])
  );

endmodule
