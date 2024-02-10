// $Id: $
// File name:   sync_high.sv
// Created:     1/31/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: sync_high
module sync_high(input logic clk, input logic n_rst, input logic async_in, output logic sync_out);
logic intermediate;
always_ff @ (posedge clk, negedge n_rst) begin
	if(n_rst == 1'b0) begin
		sync_out <= 1'b1;
		intermediate <= 1'b1;
	end
	else begin
		intermediate <= async_in;
		sync_out <= intermediate;
	end
end
endmodule
