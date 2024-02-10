// $Id: $
// File name:   edge_detector.sv
// Created:     4/6/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module edge_detector(
    input logic clk,
    input logic n_rst,
    input logic dplus_in_sync,
    output logic d_edge
);

logic dplus_in_prev;

always_ff @(posedge clk, negedge n_rst) begin
    if(n_rst == 1'b0) begin
        dplus_in_prev <= 0;
    end
    else begin
        dplus_in_prev <= dplus_in_sync;
    end
end

assign d_edge = dplus_in_prev & !dplus_in_sync;
endmodule