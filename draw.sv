`default_nettype none
module draw
  (input logic clkin, reset,
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

  // automatic angle accumulator (for emulation)
  logic [7:0] angle;
  auto_angle test_rotate(.*);

  // trig look-up table
  logic signed [7:0] sin, cos;
  trig_lut lookup(.*);

  // sequential vertex processing
  logic [7:0][10:0] sx, sy;
  logic [1:0] axis = 2'b01; // temporary static spin for emulation
  vertex map(.*);

  // display match vertex
  logic point;
  logic [7:0] vertex_match; 
  always_comb begin
    vertex_match = 8'b0;
    for(int i = 0; i < 8; i++) begin
      vertex_match[i] = (col[9:1] == sx[i][9:1]) && (row[9:1] == sy[i][9:1]);
    end
  end
  assign point = |vertex_match;

  // display color vertex
  // Later Implement Further Z direction = Lower Shade if there's room
  // Color each vertex a distinct color for emulation
  party_colors test_vertex(.*);

endmodule: draw

// Automatic Angle Accumulator Emulation Module
module auto_angle
  (input logic clk, reset,
  output logic [7:0] angle);

  logic [19:0] prescaler; // slow down spin
  always_ff @(posedge clk) begin
    if(reset) begin
      angle <= 8'd0;
      prescaler <= 20'd0;
    end
    else begin
      if(prescaler == 0) begin 
        angle <= angle + 1;
      end
      prescaler <= prescaler + 1;
    end
  end
endmodule: auto_angle

// Color each vertex a distinct color for emulation
module party_colors
  (input logic [7:0] vertex_match,
  output logic [1:0] rbuf, gbuf, bbuf);

  always_comb begin
    if(vertex_match[0]) begin
      rbuf = 2'b11;
      gbuf = 2'b11;
      bbuf = 2'b11;
    end
    else if(vertex_match[1]) begin
      rbuf = 2'b00;
      gbuf = 2'b11;
      bbuf = 2'b11;
    end
    else if(vertex_match[2]) begin
      rbuf = 2'b11;
      gbuf = 2'b00;
      bbuf = 2'b11;
    end
    else if(vertex_match[3]) begin
      rbuf = 2'b11;
      gbuf = 2'b11;
      bbuf = 2'b00;
    end
    else if(vertex_match[4]) begin
      rbuf = 2'b11;
      gbuf = 2'b00;
      bbuf = 2'b00;
    end
    else if(vertex_match[5]) begin
      rbuf = 2'b00;
      gbuf = 2'b11;
      bbuf = 2'b00;
    end
    else if(vertex_match[6]) begin
      rbuf = 2'b00;
      gbuf = 2'b00;
      bbuf = 2'b11;
    end
    else if(vertex_match[7]) begin
      rbuf = 2'b10;
      gbuf = 2'b10;
      bbuf = 2'b10;
    end
    else begin
      rbuf = 2'b00;
      gbuf = 2'b00;
      bbuf = 2'b00;
    end
  end
endmodule: party_colors