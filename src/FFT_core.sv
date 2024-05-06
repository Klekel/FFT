`timescale 1ns / 1ps
module FFT_core(

input  logic        clk_i,
input  logic        rst_i,
input  logic [49:0] input_signal  [0:7],
output logic [49:0] output_signal [0:7]
);

logic [49:0] stage1_signal_o         [0:7];
logic [49:0] stage2_signal_o         [0:7];
logic [49:0] stage3_signal_o         [0:7];
logic        valid_stage1_o;
logic        valid_stage2_o;
logic        valid_stage3_o;
logic        clk_stage2;
logic        clk_stage3;

butterfly_ff  stage1
(
.clk_i(clk_i),
.rst_i(rst_i),
.input_signal(input_signal),
.output_signal(stage1_signal_o),
.valid(valid_stage1_o)
);

butterfly_stage2  stage2
(
.clk_i(clk_stage2),
.rst_i(rst_i),
.input_signal(stage1_signal_o),
.output_signal(stage2_signal_o),
.valid(valid_stage2_o)
);

butterfly_stage3  stage3
(
.clk_i(clk_stage3),
.rst_i(rst_i),
.input_signal(stage2_signal_o),
.output_signal(stage3_signal_o),
.valid(valid_stage3_o)
);
assign clk_stage2 = clk_i & valid_stage1_o;
assign clk_stage3 = clk_i & valid_stage2_o;
assign output_signal = stage3_signal_o; 

endmodule