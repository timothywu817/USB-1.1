// $Id: $
// File name:   timer.sv
// Created:     2/17/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: Timer

module timer_tx
(
	input logic clk,
	input logic n_rst,
	input logic enable_timer,
	output logic shift_strobe,
	output logic packet_done
);

typedef enum logic [1:0] {IDLE, SHORT1, SHORT2, LONG} period_type;

period_type state, next_state;

logic temp_packet_done, enable_timer_reg;
logic [3:0] bit_period;

flex_counter_tx #(.NUM_CNT_BITS(4)) c1 (
	.clk(clk), .n_rst(n_rst),
	.clear(!enable_timer),
	.count_enable(enable_timer),
	.rollover_val(bit_period),
	.rollover_flag(shift_strobe)
	);

flex_counter_tx #(.NUM_CNT_BITS(4)) c2 (
	.clk(clk), .n_rst(n_rst),
	.clear(!enable_timer),
	.count_enable(shift_strobe || (enable_timer && (!enable_timer_reg))),
	.rollover_val(4'd8),
	.rollover_flag(temp_packet_done)
	);

always_ff @ (posedge clk, negedge n_rst) begin
	if (!n_rst) begin
		state <= IDLE;
		enable_timer_reg <= 1'b0;
	end
	else begin
		state <= next_state;
		enable_timer_reg <= enable_timer;
	end
end

always_comb begin : next_state_logic
	next_state = state;
	bit_period = 4'd8;
	case (state)
	IDLE: begin
		if (enable_timer) begin
			next_state = SHORT1;
		end
	end
	SHORT1: begin
		if (enable_timer && shift_strobe) begin
			next_state = SHORT2;
		end
		else if (enable_timer == 1'b0) begin
			next_state = IDLE;
		end
	end
	SHORT2: begin
		if (enable_timer && shift_strobe) begin
			next_state = LONG;
		end
		else if (enable_timer == 1'b0) begin
			next_state = IDLE;
		end
	end
	LONG: begin
		bit_period = 4'd9;
		if (enable_timer && shift_strobe) begin
			next_state = SHORT1;
		end
		else if (enable_timer == 1'b0) begin
			next_state = IDLE;
		end
	end
	endcase

end

assign packet_done = temp_packet_done && shift_strobe;

endmodule
