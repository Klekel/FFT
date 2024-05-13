`timescale 1ns / 1ps
module fft_core(

input  logic        clk_i,
input  logic        rst_i,
input  logic [49:0] signal_i,
input  logic        ready_i,
input  logic        valid_i,
output logic [49:0] signal_o,
output logic        valid_o,
output logic        ready_o
);

logic [49:0] stage1_signal;
logic [49:0] stage2_signal;
logic [49:0] stage3_signal;
logic        valid_stage1;
logic        ready_stage12;
logic        valid_stage2;
logic        ready_stage23;
logic        ready_stage11;
// logic        clk_stage2;
// logic        clk_stage3;

fft_butterfly_stage1  stage1
(
.clk_i(clk_i),
.rst_i(rst_i),
.signal_i(signal_i),
.valid_i(valid_i),
.ready_i(ready_stage12),
.signal_o(stage1_signal),
.valid_o(valid_stage1),
.ready_o(ready_stage11)
);

fft_butterfly_stage2  stage2
(
.clk_i(clk_i),
.rst_i(rst_i),
.signal_i(stage1_signal),
.valid_i(valid_stage1),
.ready_i(ready_stage23),
.signal_o(stage2_signal),
.valid_o(valid_stage2),
.ready_o(ready_stage12)
);

fft_butterfly_stage3  stage3
(
.clk_i(clk_i),
.rst_i(rst_i),
.signal_i(stage2_signal),
.valid_i(valid_stage2),
.ready_i(ready_i),
.signal_o(signal_o),
.valid_o(valid_o),
.ready_o(ready_stage23)
);

assign ready_o = ready_stage23 && ready_stage12 && ready_stage11;
// assign clk_stage2 = clk_i & valid_stage1;
// assign clk_stage3 = clk_i & valid_stage2;

endmodule