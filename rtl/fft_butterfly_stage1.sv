`timescale 1ns / 1ps
module fft_butterfly_stage1  
#(
  parameter DATA_WIDTH = 50,
  parameter COEF       = 36
)
(

input  logic                    clk_i,
input  logic                    rst_i,
input  logic [DATA_WIDTH - 1:0] signal_i,
input  logic                    valid_i,
input  logic                    ready_i,
output logic [DATA_WIDTH - 1:0] signal_o,
output logic                    valid_o,
output logic                    ready_o

);

logic        [DATA_WIDTH-1:0] input_array        [0:7];
logic        [DATA_WIDTH-1:0] output_array       [0:7];

logic        [DATA_WIDTH-1:0] data_a_stage_1_ff;
logic        [DATA_WIDTH-1:0] data_a_stage_2_ff;
logic        [DATA_WIDTH-1:0] data_a_stage_3_ff;

logic        [1:0]            counter_stage_1_ff;
logic        [1:0]            counter_stage_2_ff;
logic        [1:0]            counter_stage_3_ff;
logic        [1:0]            counter_stage_4_ff;

logic        [COEF-1:0]       coef_stage_1_ff;
logic        [COEF-1:0]       coef_stage_2_ff;
logic        [COEF-1:0]       coef_stage_3_ff;
logic        [COEF-1:0]       coef_stage_4_ff;

logic        [DATA_WIDTH-1:0] sum_stage_1_ff;
logic        [DATA_WIDTH-1:0] sum_stage_2_ff;
logic        [DATA_WIDTH-1:0] sum_stage_3_ff;
logic        [DATA_WIDTH-1:0] sum_stage_4_ff;

logic        [42:0]           im1_stage_2_ff;
logic        [42:0]           re1_stage_2_ff;

logic        [42:0]           im1_stage_3_ff;
logic        [42:0]           re1_stage_3_ff;

logic        [42:0]           im2_stage_3_ff;
logic        [42:0]           re2_stage_3_ff;

logic        [DATA_WIDTH-1:0] prestage_sum;
logic        [DATA_WIDTH-1:0] prestage_dif;
logic signed [47:0]           signal_re_part;
logic signed [47:0]           signal_re_part_stage_4_ff;
logic signed [47:0]           signal_im_part;
logic signed [47:0]           signal_im_part_stage_4_ff;
logic        [COEF-1:0]       coef                     [0:3];
logic        [42:0]           im_1;
logic        [42:0]           im_2;
logic        [42:0]           re_1;
logic        [42:0]           re_2;
logic        [1: 0]           counter;
logic        [2: 0]           in_counter;
logic        [2: 0]           out_counter;
logic                         counter_stop;


initial $readmemb("fft_coef_data.mem", coef);

//запись 
always_ff @(posedge clk_i) begin
  if(rst_i )begin
    in_counter <= '0;
  end
  else if(in_counter == 7)begin
    in_counter <= 0;
  end
  else if(valid_i && ready_o)begin
    in_counter <= in_counter + 1;
  end
  else in_counter <= in_counter;
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
      for(int i=0; i<$size(input_array) ;i++) begin
    input_array[i] <= '0;
    end
  end
  else if(valid_i && ready_o)begin
    input_array[in_counter] <= signal_i;
  end
  else input_array[in_counter] <= input_array[in_counter];
end

// чтение
always_ff @(posedge clk_i) begin
  if(rst_i )begin
    out_counter <= '0;
  end
  else if(out_counter == 7)begin
    out_counter <= 0;
  end
  else if(valid_o && ready_i)begin
    out_counter <= out_counter + 1;
  end
  else out_counter <= out_counter;
end

always_comb begin
  if(rst_i)begin
    signal_o = '0;
  end
  else if(valid_o && ready_i)begin
    signal_o = output_array[out_counter];
  end
  else signal_o = signal_o;
end



always_ff @(posedge clk_i) begin
  if(rst_i)begin
    valid_o <= '0;
  end
  else if(out_counter == 7) begin
    valid_o <= '0;
  end
  else if(counter_stage_4_ff == 3) begin
    valid_o <= 1;
  end
  else valid_o <= valid_o;
  
end

always_ff @(posedge clk_i) begin
  if(rst_i) begin
    ready_o <= '1;
  end
  else if(out_counter == 7) begin
    ready_o <= '1;
  end
  else if(in_counter == 7) begin
    ready_o <= '0;
  end
  else ready_o <= ready_o;
end

always_ff @(posedge (clk_i && !ready_o ) or posedge rst_i) begin
  if(rst_i)begin
    counter <= '0;
  end
  else if(!counter_stop)begin
    if(in_counter == 7) begin
      counter <= '0;
    end
    else begin
      counter <= counter + 1;
    end
  end
  else counter <= '0;

end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    counter_stop <= '0;
  end
  else if(in_counter == 7)begin
    counter_stop <= '0;
  end
  else if(counter == 3)begin
    counter_stop <= 1;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    data_a_stage_1_ff <= '0;
    data_a_stage_2_ff <= '0;
    data_a_stage_3_ff <= '0;
  end
  else begin
    data_a_stage_1_ff <= prestage_dif;
    data_a_stage_2_ff <= data_a_stage_1_ff;
    data_a_stage_3_ff <= data_a_stage_2_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    counter_stage_1_ff <= '0;
    counter_stage_2_ff <= '0;
    counter_stage_3_ff <= '0;
    counter_stage_4_ff <= '0;
  end
  else begin
    counter_stage_1_ff <= counter;
    counter_stage_2_ff <= counter_stage_1_ff;
    counter_stage_3_ff <= counter_stage_2_ff;
    counter_stage_4_ff <= counter_stage_3_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    coef_stage_1_ff <= '0;
    coef_stage_2_ff <= '0;
    coef_stage_3_ff <= '0;
    coef_stage_4_ff <= '0;
  end
  else begin
    coef_stage_1_ff <= coef[counter];
    coef_stage_2_ff <= coef_stage_1_ff;
    coef_stage_3_ff <= coef_stage_2_ff;
    coef_stage_4_ff <= coef_stage_3_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    sum_stage_1_ff <= '0;
    sum_stage_2_ff <= '0;
    sum_stage_3_ff <= '0;
    sum_stage_4_ff <= '0;
  end
  else begin
    sum_stage_1_ff <= prestage_sum;
    sum_stage_2_ff <= sum_stage_1_ff;
    sum_stage_3_ff <= sum_stage_2_ff;
    sum_stage_4_ff <= sum_stage_3_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    im1_stage_2_ff <= '0;
    im1_stage_3_ff <= '0;
  end
  else begin
    im1_stage_2_ff <= im_1;
    im1_stage_3_ff <= im1_stage_2_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    re1_stage_2_ff <= '0;
    re1_stage_3_ff <= '0;
  end 
  else begin
    re1_stage_2_ff <= re_1;
    re1_stage_3_ff <= re1_stage_2_ff;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    im2_stage_3_ff <= '0;
  end
  else begin
    im2_stage_3_ff <= im_2;
  end
end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    re2_stage_3_ff <= '0;
  end
  else begin
    re2_stage_3_ff <= re_2;
  end

end

always_ff @(posedge clk_i) begin
  if(rst_i)begin
    signal_re_part_stage_4_ff <= '0;
    signal_im_part_stage_4_ff <= '0;
  end
  else begin
    signal_re_part_stage_4_ff <= signal_re_part;
    signal_im_part_stage_4_ff <= signal_im_part;
  end
end


assign prestage_sum = { $signed(input_array[counter][DATA_WIDTH-1:DATA_WIDTH/2]) + $signed(input_array[counter + 4][DATA_WIDTH-1:DATA_WIDTH/2]) ,
                        $signed(input_array[counter][DATA_WIDTH/2-1:0])          + $signed(input_array[counter + 4][DATA_WIDTH/2-1:0])};

assign prestage_dif = { $signed(input_array[counter][DATA_WIDTH-1:DATA_WIDTH/2]) - $signed(input_array[counter + 4][DATA_WIDTH-1:DATA_WIDTH/2]),
                        $signed(input_array[counter][DATA_WIDTH/2-1:0])          - $signed(input_array[counter + 4][DATA_WIDTH/2-1:0]) };

assign re_1           = $signed( data_a_stage_1_ff[DATA_WIDTH/2-1:0])          * $signed(coef_stage_1_ff[COEF/2-1:0]      );
assign re_2           = $signed( data_a_stage_2_ff[DATA_WIDTH-1:DATA_WIDTH/2]) * $signed(coef_stage_2_ff[COEF-1:COEF/2]   );
assign im_1           = $signed( data_a_stage_1_ff[DATA_WIDTH/2-1:0])          * $signed(coef_stage_1_ff[COEF-1:COEF/2]   ); 
assign im_2           = $signed( data_a_stage_2_ff[DATA_WIDTH-1:DATA_WIDTH/2]) * $signed(coef_stage_2_ff[COEF/2-1:0]      );
assign signal_re_part = $signed(re2_stage_3_ff) - $signed(re1_stage_3_ff);
assign signal_im_part = $signed(im2_stage_3_ff) + $signed(im1_stage_3_ff);



always_ff @(posedge clk_i ) begin
  if(rst_i) begin
    for(int i=0; i<$size(signal_o) ;i++) begin
      output_array[i] <= '0;
    end
  end
  else begin
  output_array[counter_stage_4_ff]     <= sum_stage_4_ff;
  output_array[counter_stage_4_ff + 4] <= {signal_re_part_stage_4_ff[40:16], signal_im_part_stage_4_ff[40:16]};
  end
end
endmodule        