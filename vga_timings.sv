`default_nettype none
module vga_timings
  (input logic clk, reset,
  output logic hsync, vsync,
  output logic [9:0] x, y,
  output logic display);

  // horizontal and vertical timings
  always_comb begin
    hsync = ~(x >= 655 && x < 751);
    vsync = ~(y >= 489 && y < 491);
    display = (x <= 639 && y <= 479);
  end
  
  // count xy screen position
  always_ff @(posedge clk) begin
    if(reset) begin
      x <= 0;
      y <= 0;
    end
    else begin
      if(x == 799) begin
        x <= 0;
        y <= (y == 524) ? 0 : y + 1;
      end
      else begin
        x <= x + 1;
      end
    end
  end
endmodule: vga_timings