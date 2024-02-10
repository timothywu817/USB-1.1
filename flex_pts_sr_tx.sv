// $Id: $
// File name:   flex_stp_sr.sv
// Created:     2/7/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: Serial to parallel design.

module flex_pts_sr_tx
#(
	parameter NUM_BITS = 4,
	parameter SHIFT_MSB = 1'b1
)
(
	input logic clk,
	input logic n_rst,
	input logic load_enable,
	input logic shift_enable,
	input logic [NUM_BITS - 1:0] parallel_in,
	output logic serial_out
);

logic [NUM_BITS - 1:0] out;
logic [NUM_BITS - 1:0] next_out;

always_ff @ (posedge clk, negedge n_rst) begin
if (n_rst == 1'b0) begin
	out <= '1;
end
else begin
	out <= next_out;
end
end

always_comb begin
if (SHIFT_MSB) begin
	serial_out <= out[NUM_BITS - 1];
end
else begin
	serial_out <= out[0];
end
end

always_comb begin
if (load_enable == 1'b1) begin
	next_out = parallel_in;
end
else if (shift_enable == 1'b1) begin
	next_out = SHIFT_MSB ? {out[NUM_BITS - 2:0], 1'b1} : {1'b1, out[NUM_BITS - 1:1]};
	// if (SHIFT_MSB) begin
	// next_out = {out[NUM_BITS - 2:0], 1'b1};
	// end
	// else begin
	// next_out = {1'b1, out[NUM_BITS - 1:1]};
	// end
end
else begin
	next_out = out;
end
end

endmodule
