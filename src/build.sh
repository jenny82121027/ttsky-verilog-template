
yosys -p "read_verilog -sv project.v; synth_ecp5 -json synth.json -top ChipInterface"    


nextpnr-ecp5 --12k --package CABGA381 --json synth.json --lpf constraints.lpf --textcfg pnr_out.config --lpf-allow-unconstrained

//ecppack --compress pnr_out.config bitstream.bit && fujprog bitstream.bit
