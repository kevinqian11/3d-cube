#!/bin/bash

set -e

FILES="src/rotation.sv src/trig.sv src/vertex.sv src/pll.sv src/vga_timings.sv src/control.sv src/color.sv src/draw.sv"

TOP_MODULE="draw"

echo -n "Synthesizing..."

yosys -q -f "verilog -sv" -p "
    read_verilog -sv $FILES
    synth_ecp5 -json build/synthesis.json -top draw"

echo "done!"
echo -n "Compressing..."

nextpnr-ecp5 --12k --json build/synthesis.json --lpf src/constraints.lpf --textcfg build/pnr_out.config --package CABGA381 -q

ecppack --compress build/pnr_out.config build/bitstream.bit

echo "done!"

fujprog build/bitstream.bit > /dev/null