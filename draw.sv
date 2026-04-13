`default_nettype none
module draw
  (input logic clkin, reset,
  output logic hsync, vsync,
  output logic [1:0] r, g, b);

  // clock signal 25.2 MHz
  logic clk, locked;
  pll set252(.*);

  // VGA display timings
  logic [9:0] row, col;
  logic display;
  vga_timings timing(.*);

  // display blanking intervals
  logic [1:0] rbuf, gbuf, bbuf;
  always_comb begin
    r = (display) ? rbuf : 2'b00;
    g = (display) ? gbuf : 2'b00;
    b = (display) ? bbuf : 2'b00;
  end

  // cube vertices
  logic signed [7:0][7:0] x = {-8'sd64, 8'sd64, -8'sd64, -8'sd64, 8'sd64, -8'sd64, 8'sd64, 8'sd64};
  logic signed [7:0][7:0] y = {-8'sd64, -8'sd64, 8'sd64, -8'sd64, 8'sd64, 8'sd64, -8'sd64, 8'sd64};
  logic signed [7:0][7:0] z = {-8'sd64, -8'sd64, -8'sd64, 8'sd64, -8'sd64, 8'sd64, 8'sd64, 8'sd64};

  // display check vertex
  logic [7:0][10:0] sx;
  logic [7:0][10:0] sy;
  logic vertex;
  always_comb begin
    vertex = 0;
    for(int i = 0; i < 8; i++) begin
      sx[i] = {{3{x[i][7]}}, x[i]} + 11'd320;
      sy[i] = {{3{y[i][7]}}, y[i]} + 11'd240;

      if(col == sx[i] && row == sy[i]) begin
        vertex = 1;
      end
    end
  end

  // display color vertex
  always_comb begin
    rbuf = (vertex) ? 2'b11 : 2'b00;
    gbuf = (vertex) ? 2'b11 : 2'b00;
    bbuf = (vertex) ? 2'b11 : 2'b00;
  end
endmodule: draw