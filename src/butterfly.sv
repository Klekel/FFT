`timescale 1ns / 1ps
module butterfly(

input  logic        clk_i,
input  logic        rst_i,
input  logic [49:0] signal_a_i,
input  logic [49:0] signal_b_i,
output logic [47:0] out_stage1_signal    [0:7],
output logic        flag

);

logic        [49:0] stage1_sum;
logic        [49:0] stage1_dif;
logic        [47:0] stage1_mult;
logic signed [47:0] stage1_mult_re;
logic signed [47:0] stage1_mult_im;
logic        [47:0] result_stage1_signal [0:7];
logic        [35:0] coef                 [0:3];
logic        [24:0] real_part;
logic        [24:0] imag_part;
logic        [1: 0] counter;

initial $readmemb("coef_data.mem", coef);

always_ff @(posedge clk_i) begin
    if(rst_i)begin
        counter <= '0;
        flag <= '0;
    end
    else if(counter == 3)begin
        counter <= counter;
    end
    else begin
        counter <= counter + 1;
    end
end


assign stage1_sum = { $signed(signal_a_i[49:25]) + $signed(signal_b_i[49:25]) , ($signed(signal_a_i[24:0]) + $signed(signal_b_i[24:0]))};

assign stage1_dif = { $signed(signal_a_i[49:25]) - $signed(signal_b_i[49:25]), $signed(signal_a_i[24:0]) - $signed(signal_b_i[24:0]) };

assign stage1_mult_re = $signed(stage1_dif[49:25]) * $signed(coef[counter][35:18]) - $signed(stage1_dif[24:0]) * $signed(coef[counter][17:0]) ;
assign stage1_mult_im = $signed(stage1_dif[49:25]) * $signed(coef[counter][17:0]) + $signed(stage1_dif[24:0]) * $signed(coef[counter][35:18]) ;

assign stage1_mult = {stage1_mult_re[47:23] , stage1_mult_im[47:23]};

always_ff @(posedge clk_i) begin
    result_stage1_signal[counter] <= stage1_sum;
    result_stage1_signal[counter + 4] <= stage1_mult;
    if(counter == 3) begin
    out_stage1_signal <= result_stage1_signal;
    flag <= 1;
    end
end
endmodule