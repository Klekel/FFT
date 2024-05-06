`timescale 1ns / 1ps

module tb_butterfly(

    );
localparam DATA_WIDTH = 50;

logic                    clk_i;
logic                    rst_i;
logic                    valid_o;
logic [DATA_WIDTH - 1:0] input_signal         [0:7];
logic [49:0]             output_signal        [0:7];

always begin
    #10 clk_i = ~clk_i;
end

FFT_core dut1(

.clk_i(clk_i),
.rst_i(rst_i),
.input_signal(input_signal),
.output_signal(output_signal)
);


initial 
begin
rst_i = 0;
#10
clk_i = 1;
rst_i = 1;

input_signal[0] = 50'b00000000000000000000000010000000000000000000000001;
input_signal[1] = 50'b00000000000000100000000000000000000000001000000000;
input_signal[2] = 50'b11111111111111111111111010000000000000000000000001;
input_signal[3] = 50'b00000000000000000000000101111111111111111111111110;
input_signal[4] = 50'b00000000000000000000000010000000000000000000000000; 
input_signal[5] = 50'b00000000000000000100000001111111111111111111100000;
input_signal[6] = 50'b00000000000000000000000010000000000000000000000000;
input_signal[7] = 50'b00000000000000000000000110000000000000000000000000;

#205
rst_i = 0;

end



endmodule
