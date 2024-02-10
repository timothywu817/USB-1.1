// $Id: $
// File name:   timer.sv
// Created:     2/16/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module timer(
    input logic clk,
    input logic n_rst,
    input logic addr_en,
    input logic rx_transfer_active,
    input logic eop_en,
    output logic shift_en,
    output logic eop_1_comp,
    output logic eop_comp,
    output logic byte_received,
    output logic address_comp

);
    logic addr_byte_en;
    flex_counter #(.NUM_CNT_BITS(4)) f1(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(rx_transfer_active), .rollover_val(4'd8), .reset_val(3'd4),.rollover_flag(shift_en));

    flex_counter #(.NUM_CNT_BITS(4)) f2(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(shift_en), .rollover_val(4'd8), .reset_val(3'd0), .rollover_flag(byte_received));

    flex_counter #(.NUM_CNT_BITS(4)) f3(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(eop_en), .rollover_val(4'd8), .reset_val(3'd0),.rollover_flag(eop_1_comp));

    flex_counter #(.NUM_CNT_BITS(5)) f4(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(eop_en), .rollover_val(5'd16), .reset_val(3'd0), .rollover_flag(eop_comp));

    flex_counter #(.NUM_CNT_BITS(4)) f5(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(addr_en), .rollover_val(4'd8),.reset_val(3'd4), .rollover_flag(addr_byte_en));

    flex_counter #(.NUM_CNT_BITS(5)) f6(.clk(clk), .n_rst(n_rst), .clear(!rx_transfer_active), 
    .count_enable(addr_byte_en), .rollover_val(5'd16),.reset_val(3'd0), .rollover_flag(address_comp));


endmodule
