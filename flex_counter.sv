// $Id: $
// File name:   flex_counter.sv
// Created:     2/1/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module flex_counter#(parameter NUM_CNT_BITS = 4)
(
	input logic clk, 
	input logic n_rst, 
	input logic clear, 
	input logic count_enable, 
	input logic [2:0] reset_val,
	input logic [NUM_CNT_BITS-1:0]rollover_val, 
	output logic [NUM_CNT_BITS-1:0]count_out, 
	output logic rollover_flag
);
logic [(NUM_CNT_BITS-1):0]cout;
logic flag;

always_ff @ (posedge clk, negedge n_rst) begin
	if (n_rst == 1'b0) begin
		count_out <= 0;
		rollover_flag <= 0;
	end
	else begin
		count_out <= cout;
		rollover_flag <= flag;
	end
end
always_comb begin 
	cout = count_out;
	flag = 0;
	if (clear == 1'b1) begin
		cout = reset_val;
		flag = 0;
	end
	else if(count_enable == 1'b1) begin
		if(count_out == rollover_val - 1) begin
			flag = 1;
			cout = count_out + 1;
			
		end
		else if (count_out == rollover_val) begin
			cout = 1;
		end
		else begin
			cout = count_out + 1;
		end
	end
	else begin
		flag = rollover_flag;
		cout = count_out;
	end
	
end
endmodule
