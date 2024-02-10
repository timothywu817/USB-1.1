// $Id: $
// File name:   usb_rx.sv
// Created:     4/5/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: 

module usb_rx (
    input logic clk,
    input logic n_rst,
    input logic dplus_in,
    input logic dminus_in,
    input logic [6:0] buffer_occupancy,
    output logic [2:0] rx_packet,
    output logic rx_data_ready,
    output logic rx_transfer_active,
    output logic rx_error,
    output logic flush,
    output logic store_rx_packet_data,
    output logic [7:0] rx_packet_data
);
    logic d_edge;
    logic byte_en;
    logic byte_received;
    logic d_orig;
    logic address_comp;
    logic addr_en;
    logic eop;
    logic eop_en;
    logic eop_comp;
    logic eop_1_comp;
    logic [15:0] address;
    logic shift_enable;
    sync_high sh (.clk(clk), .n_rst(n_rst), .async_in(dplus_in), .sync_out(dplus_in_sync));

    sync_low sl (.clk(clk), .n_rst(n_rst), .async_in(dminus_in), .sync_out(dminus_in_sync));

    edge_detector edge_1(.clk(clk), .n_rst(n_rst), 
    .dplus_in_sync(dplus_in_sync), .d_edge(d_edge));
    timer timer1(.clk(clk), .n_rst(n_rst),
    .addr_en(addr_en), .rx_transfer_active(rx_transfer_active),
    .shift_en(shift_enable), .eop_en(eop_en),
    .byte_received(byte_received), .address_comp(address_comp), .eop_comp(eop_comp), .eop_1_comp(eop_1_comp));
    
    decode decoder(.clk(clk), .n_rst(n_rst), .shift_enable(shift_enable), .clear(!rx_transfer_active),
    .dplus_in_sync(dplus_in_sync), .d_orig(d_orig));//good

    eop end_of_packet(.clk(clk), .n_rst(n_rst), .dminus_in_sync(dminus_in_sync), 
    .dplus_in_sync(dplus_in_sync), .eop(eop));

    sr_9bit shift_register(.clk(clk), .n_rst(n_rst), .shift_strobe(shift_enable), 
    .serial_in(d_orig),.addr_en(addr_en), .packet_data(rx_packet_data), .address(address));

    rcu controller(.clk(clk),.n_rst(n_rst),.shift_enable(shift_enable), .addr_en(addr_en),
    .rcv_data(rx_packet_data), .d_edge(d_edge), .eop(eop), .eop_comp(eop_comp), .eop_1_comp(eop_1_comp), .byte_en(byte_en),.address_comp(address_comp),
    .byte_received(byte_received),.address(address), .rcving(rx_transfer_active), 
    .buffer_occupancy(buffer_occupancy),
    .r_error(rx_error), .store_rx_packet_data(store_rx_packet_data), 
    .rx_data_ready(rx_data_ready),.pid(rx_packet),.flush(flush),.eop_en(eop_en));

    // data_buffer fifo(.clk(clk), .n_rst(n_rst),store_rx_packet_data(store_rx_packet_data),
    // .rx_packet_data(rx_packet_data),.buffer_occupancy(buffer_occupancy),.flush(flush));//good
endmodule
