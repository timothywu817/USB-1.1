// $Id: $
// File name:   decode.sv
// Created:     4/7/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module decode(
    input logic clk,
    input logic n_rst,
    input logic shift_enable,
    input logic clear,
    input logic dplus_in_sync,
    output logic d_orig
);
logic dplus_in_nxt, dplus_in_prev;

always_ff @ (posedge clk, negedge n_rst) begin
    if(n_rst == 0) begin
        dplus_in_prev <= 1;
    end
    else begin
        dplus_in_prev <= dplus_in_nxt;
    end
end

always_comb begin
    dplus_in_nxt = dplus_in_prev;
    if(clear) begin
        dplus_in_nxt = 1;
    end
    else if(shift_enable) begin
        dplus_in_nxt = dplus_in_sync;
    end
end

assign d_orig = !(dplus_in_sync ^ dplus_in_prev);

endmodule