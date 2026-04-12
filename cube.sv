`default_nettype none
module cube
  (input logic clkin, reset,
  output logic hsync, vsync,
  output logic [1:0] r, g, b);

  // clock signal 25.2 MHz
  logic clk, locked;
  pll set252(.*);

  logic [9:0] x, y;
  logic display;
  vga_timings timing(.*);

  // blanking intervals
  logic [1:0] rbuf, gbuf, bbuf;
  always_comb begin
    r = (display) ? rbuf : 2'b00;
    g = (display) ? gbuf : 2'b00;
    b = (display) ? bbuf : 2'b00;
  end

  // check square
  logic square;
  always_comb begin
      square = (x > 220 && x < 420) && (y > 140 && y < 340);
  end

  // color square
  always_comb begin
      rbuf = (square) ? 2'b11 : 2'b10;
      gbuf = (square) ? 2'b11 : 2'b00;
      bbuf = (square) ? 2'b11 : 2'b01;
  end
endmodule: cube