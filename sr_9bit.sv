// $Id: $
// File name:   sr_9bit.sv
// Created:     2/17/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module sr_9bit(
    input logic clk,
    input logic n_rst,
    input logic shift_strobe,
    input logic addr_en,
    input logic serial_in,
    output logic [7:0] packet_data,
    output logic [15:0] address
    );
    flex_stp_sr #(.NUM_BITS(8), .SHIFT_MSB(1)) shift_register(.clk(clk), .n_rst(n_rst), 
    .shift_enable(shift_strobe), .serial_in(serial_in), .parallel_out(packet_data));

    flex_stp_sr #(.NUM_BITS(16), .SHIFT_MSB(1)) address_reg (.clk(clk), .n_rst(n_rst), 
    .shift_enable(addr_en), .serial_in(serial_in), .parallel_out(address));
endmodule