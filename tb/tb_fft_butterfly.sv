`timescale 1ns / 1ps

module tb_fft_butterfly(

    );
localparam DATA_WIDTH = 50;

logic                    clk_i;
logic                    rst_i;
logic                    valid_o;
logic                    ready_o;
logic                    valid_i;
logic                    ready_i;
logic [DATA_WIDTH - 1:0] signal_i;
logic [49:0]             signal_o;

always begin
    #10 clk_i = ~clk_i;
end

fft_core dut1(
.clk_i(clk_i),
.rst_i(rst_i),
.signal_i(signal_i),
.ready_i(ready_i),
.valid_i(valid_i),
.signal_o(signal_o),
.valid_o(valid_o),
.ready_o(ready_o)
);



initial 
begin
rst_i = 1;
ready_i = 1;
clk_i = 1;
#10

rst_i = 0;

#205
rst_i = 0;
valid_i = 1;
signal_i = 50'b00000000000000000000000010000000000000000000000001;
#20
signal_i = 50'b00000000000000100000000000000000000000001000000000;
#20
signal_i = 50'b11111111111111111111111010000000000000000000000001;
#20
signal_i = 50'b00000000000000000000000101111111111111111111111110;
#20
signal_i = 50'b00000000000000000000000010000000000000000000000000;
#20
signal_i = 50'b00000000000000000100000001111111111111111111100000;
#20
signal_i = 50'b00000000000000000000000010000000000000000000000000;
#20
signal_i = 50'b00000000000000000000000110000000000000000000000000;

#10;
valid_i = 0;

end



endmodule
