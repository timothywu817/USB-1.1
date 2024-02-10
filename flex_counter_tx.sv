// $Id: $
// File name:   flex_counter.sv
// Created:     2/16/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: flex counter.

module flex_counter_tx
#(
parameter NUM_CNT_BITS = 4
)
(
	input logic clk,
	input logic n_rst,
	input logic clear,
	input logic count_enable,
	input logic [NUM_CNT_BITS - 1:0]rollover_val,
	output logic [NUM_CNT_BITS - 1:0]count_out,
	output logic rollover_flag
);

logic [NUM_CNT_BITS - 1:0]count;
logic flag;

always_ff @ (posedge clk, negedge n_rst) begin
if (!n_rst) begin
	count_out <= 0;
	rollover_flag <= 0;
end
else begin
	count_out <= count;
	rollover_flag <= flag;	
end
end

always_comb begin
if (clear) begin
	flag = 0;
end
else if (count_out == (rollover_val - 1) && count_enable) begin
	flag = 1;
end
else if (count_enable == 1'b0) begin
	flag = rollover_flag;
end
else begin
	flag = 0;
end
end

always_comb begin
if (clear) begin
	count = 0;
end
else if (count_enable == 1'b0) begin
	count = count_out;
end
else if (count_out == rollover_val) begin
	count = 1;
end
else begin
	count = count_out + 1;
end
end
endmodule
