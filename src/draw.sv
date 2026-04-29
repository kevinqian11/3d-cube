`default_nettype none
module draw
  (input logic clkin, reset,
  input logic left, right, up, down, leftz, rightz,
  output logic hsync, vsync,
  output logic [1:0] r, g, b);

  // generate 25.2 MHz clock signal
  logic clk, locked;
  pll set252(.*);

  // VGA display timings
  logic [9:0] row, col;
  logic display;
  logic vblank;
  vga_timings timing(.*);

  // display blanking intervals
  logic [1:0] rbuf, gbuf, bbuf;
  always_comb begin
    r = (display) ? rbuf : 2'b00;
    g = (display) ? gbuf : 2'b00;
    b = (display) ? bbuf : 2'b00;
  end

  // Y-axis angle control
  logic [7:0] angleY;
  Y_angle Y_rotate(.*);

  // X-axis angle control
  logic [7:0] angleX;
  X_angle X_rotate(.*);

  // Z-axis angle control
  logic [7:0] angleZ;
  Z_angle Z_rotate(.*);

  // sequential vertex processing
  logic [7:0][10:0] sx, sy;
  vertex map(.*);

  // display match vertex
  logic [7:0] vertex_match; 
  always_comb begin
    vertex_match = 8'b0;
    for(int i = 0; i < 8; i++) begin
      vertex_match[i] = (col[9:1] == sx[i][9:1]) && (row[9:1] == sy[i][9:1]);
    end
  end

  // display color vertex
  // Later Implement Further Z direction = Lower Shade if there's room
  // Color each vertex a distinct color for emulation
  two_face color_vertex(.*);

endmodule: draw
