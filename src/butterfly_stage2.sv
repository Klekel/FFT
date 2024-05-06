`timescale 1ns / 1ps
module butterfly_stage2  
#(
    parameter DATA_WIDTH = 50,
    parameter COEF       = 36
)
(

input  logic                    clk_i,
input  logic                    rst_i,
input  logic [DATA_WIDTH - 1:0] input_signal         [0:7],
output logic [DATA_WIDTH - 1:0] output_signal        [0:7],
output logic                    valid

);

logic        [DATA_WIDTH-1:0] data_A_stage_1_ff;
logic        [DATA_WIDTH-1:0] data_A_stage_2_ff;
logic        [DATA_WIDTH-1:0] data_A_stage_3_ff;

logic        [1:0] counter_stage_1_ff;
logic        [1:0] counter_stage_2_ff;
logic        [1:0] counter_stage_3_ff;
logic        [1:0] counter_stage_4_ff;

logic        [COEF-1:0] coef_stage_1_ff;
logic        [COEF-1:0] coef_stage_2_ff;
logic        [COEF-1:0] coef_stage_3_ff;
logic        [COEF-1:0] coef_stage_4_ff;

logic        [DATA_WIDTH-1:0] sum_stage_1_ff;
logic        [DATA_WIDTH-1:0] sum_stage_2_ff;
logic        [DATA_WIDTH-1:0] sum_stage_3_ff;
logic        [DATA_WIDTH-1:0] sum_stage_4_ff;


logic        [DATA_WIDTH-1:0] im1_stage_2_ff;
logic        [DATA_WIDTH-1:0] re1_stage_2_ff;

logic        [DATA_WIDTH-1:0] im1_stage_3_ff;
logic        [DATA_WIDTH-1:0] re1_stage_3_ff;

logic        [DATA_WIDTH-1:0] im2_stage_3_ff;
logic        [DATA_WIDTH-1:0] re2_stage_3_ff;

logic        [DATA_WIDTH-1:0] prestage_sum;
logic        [DATA_WIDTH-1:0] prestage_dif;
logic signed [47:0]           RE_part;
logic signed [47:0]           RE_part_stage4_ff;
logic signed [47:0]           IM_part;
logic signed [47:0]           IM_part_stage4_ff;
logic        [COEF-1:0]       coef                   [0:3];
logic        [42:0]           im_1;
logic        [42:0]           im_2;
logic        [42:0]           re_1;
logic        [42:0]           re_2;
logic        [1: 0]           counter;

logic [DATA_WIDTH - 1:0] mixed_signal                [0:7];
logic [DATA_WIDTH - 1:0] mix_out_signal              [0:7];

initial $readmemb("coef_data.mem", coef);

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        counter <= '0;
        valid   <= '0;
    end
    else if(counter == 3)begin
        counter <= counter;
    end
    else begin
        counter <= counter + 1;
    end
    if(counter_stage_4_ff == 3) begin
        valid <= 1;
    end
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        data_A_stage_1_ff <= '0;
        data_A_stage_2_ff <= '0;
        data_A_stage_3_ff <= '0;
    end
        data_A_stage_1_ff <= prestage_dif;
        data_A_stage_2_ff <= data_A_stage_1_ff;
        data_A_stage_3_ff <= data_A_stage_2_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        counter_stage_1_ff <= '0;
        counter_stage_2_ff <= '0;
        counter_stage_3_ff <= '0;
        counter_stage_4_ff <= '0;
    end
        counter_stage_1_ff <= counter;
        counter_stage_2_ff <= counter_stage_1_ff;
        counter_stage_3_ff <= counter_stage_2_ff;
        counter_stage_4_ff <= counter_stage_3_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        coef_stage_1_ff <= '0;
        coef_stage_2_ff <= '0;
        coef_stage_3_ff <= '0;
        coef_stage_4_ff <= '0;
    end
        coef_stage_1_ff <= coef[2 * (counter % 2)];
        coef_stage_2_ff <= coef_stage_1_ff;
        coef_stage_3_ff <= coef_stage_2_ff;
        coef_stage_4_ff <= coef_stage_3_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        sum_stage_1_ff <= '0;
        sum_stage_2_ff <= '0;
        sum_stage_3_ff <= '0;
        sum_stage_4_ff <= '0;
    end
        sum_stage_1_ff <= prestage_sum;
        sum_stage_2_ff <= sum_stage_1_ff;
        sum_stage_3_ff <= sum_stage_2_ff;
        sum_stage_4_ff <= sum_stage_3_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        im1_stage_2_ff <= '0;
        im1_stage_3_ff <= '0;
    end
        im1_stage_2_ff     <= im_1;
        im1_stage_3_ff     <= im1_stage_2_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        re1_stage_2_ff <= '0;
        re1_stage_3_ff <= '0;
    end
        re1_stage_2_ff     <= re_1;
        re1_stage_3_ff     <= re1_stage_2_ff;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        im2_stage_3_ff <= '0;
    end
        im2_stage_3_ff     <= im_2;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        re2_stage_3_ff <= '0;
    end
        re2_stage_3_ff     <= re_2;
end

always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        RE_part_stage4_ff <= '0;
        IM_part_stage4_ff <= '0;
    end
        RE_part_stage4_ff <= RE_part;
        IM_part_stage4_ff <= IM_part;
end


assign prestage_sum = { $signed(mixed_signal[counter][DATA_WIDTH-1:DATA_WIDTH/2]) + $signed(mixed_signal[counter + 4][DATA_WIDTH-1:DATA_WIDTH/2]) ,
                        $signed(mixed_signal[counter][DATA_WIDTH/2-1:0])          + $signed(mixed_signal[counter + 4][DATA_WIDTH/2-1:0])};

assign prestage_dif = { $signed(mixed_signal[counter][DATA_WIDTH-1:DATA_WIDTH/2]) - $signed(mixed_signal[counter + 4][DATA_WIDTH-1:DATA_WIDTH/2]),
                        $signed(mixed_signal[counter][DATA_WIDTH/2-1:0])          - $signed(mixed_signal[counter + 4][DATA_WIDTH/2-1:0]) };

assign re_1    = $signed( data_A_stage_1_ff[DATA_WIDTH/2-1:0])          * $signed(coef_stage_1_ff[COEF/2-1:0]      );
assign re_2    = $signed( data_A_stage_2_ff[DATA_WIDTH-1:DATA_WIDTH/2]) * $signed(coef_stage_2_ff[COEF-1:COEF/2]   );
assign im_1    = $signed( data_A_stage_1_ff[DATA_WIDTH/2-1:0])          * $signed(coef_stage_1_ff[COEF-1:COEF/2]   ); 
assign im_2    = $signed( data_A_stage_2_ff[DATA_WIDTH-1:DATA_WIDTH/2]) * $signed(coef_stage_2_ff[COEF/2-1:0]      );
assign RE_part = $signed(re2_stage_3_ff) - $signed(re1_stage_3_ff);
assign IM_part = $signed(im2_stage_3_ff) + $signed(im1_stage_3_ff);

always_comb begin
    mixed_signal[0] = input_signal[0];
    mixed_signal[1] = input_signal[1]; 
    mixed_signal[2] = input_signal[4];
    mixed_signal[3] = input_signal[5];
    mixed_signal[4] = input_signal[2];
    mixed_signal[5] = input_signal[3];
    mixed_signal[6] = input_signal[6];
    mixed_signal[7] = input_signal[7];
end

always_comb begin
    output_signal[0] = mix_out_signal[0];
    output_signal[1] = mix_out_signal[1]; 
    output_signal[2] = mix_out_signal[4];
    output_signal[3] = mix_out_signal[5];
    output_signal[4] = mix_out_signal[2];
    output_signal[5] = mix_out_signal[3];
    output_signal[6] = mix_out_signal[6];
    output_signal[7] = mix_out_signal[7];
end


always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        output_signal[0] <= '0;
        output_signal[1] <= '0;
        output_signal[2] <= '0;
        output_signal[3] <= '0;
        output_signal[4] <= '0;
        output_signal[5] <= '0;
        output_signal[6] <= '0;
        output_signal[7] <= '0;
    end
end
always_ff @(posedge clk_i or posedge rst_i) begin
    if(rst_i)begin
        mix_out_signal[0] <= '0;
        mix_out_signal[1] <= '0;
        mix_out_signal[2] <= '0;
        mix_out_signal[3] <= '0;
        mix_out_signal[4] <= '0;
        mix_out_signal[5] <= '0;
        mix_out_signal[6] <= '0;
        mix_out_signal[7] <= '0;
    end
    mix_out_signal[counter_stage_4_ff] <= sum_stage_4_ff;
    mix_out_signal[counter_stage_4_ff + 4] <= {RE_part_stage4_ff[40:16], IM_part_stage4_ff[40:16]};
end
endmodule