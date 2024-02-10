// $Id: $
// File name:   eop.sv
// Created:     4/7/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module eop(
    input logic clk,
    input logic n_rst,
    input logic dminus_in_sync,
    input logic dplus_in_sync,
    output logic eop
);
assign eop = !dminus_in_sync && !dplus_in_sync;
endmodule