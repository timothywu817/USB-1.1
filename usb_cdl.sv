// $Id: $
// File name:   ahb_lite_slave_cdl.sv
// Created:     3/7/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .

module usb_cdl(
    input logic clk,
    input logic n_rst,
    input logic hsel,
    input logic [7:0] haddr,
    input logic [1:0] hsize,
    input logic [1:0] htrans,
    input logic [2:0] hburst,
    input logic hwrite,
    input logic [31:0] hwdata,
    output logic [31:0] hrdata,
    output logic hresp,
    output logic hready,
    input logic dplus_in,
    input logic dminus_in,
    output logic dplus_out,
    output logic dminus_out,
    output logic d_mode
);
    // USB RX internal logic
    logic [2:0] rx_packet;
    logic rx_data_ready, rx_transfer_active, rx_error, flush, store_rx_packet_data;
    // USB TX internal logic
    logic [2:0] tx_packet;
    logic tx_data_ready, tx_transfer_active, tx_error, get_tx_packet_data;
    // Data Buffer internal logic
    logic get_rx_data, store_rx_data, get_tx_data, store_tx_data, clear;
    logic [6:0] buffer_occupancy;
    logic [7:0] rx_data, tx_data, tx_packet_data, rx_packet_data;


    ahb_lite_slave_cdl DUT1(
		.clk(clk), .n_rst(n_rst),
        .rx_packet(rx_packet),
        .rx_data_ready(rx_data_ready),
        .rx_transfer_active(rx_transfer_active),
        .rx_error(rx_error),
        .buffer_occupancy(buffer_occupancy),
        .tx_transfer_active(tx_transfer_active),
        .tx_error(tx_error),
        .rx_data(rx_data),
        .get_rx_data(get_rx_data),
        .store_tx_data(store_tx_data),
        .tx_data(tx_data),
        .clear(clear),
        .tx_packet(tx_packet),
        .d_mode(d_mode),
        .hsel(hsel),
        .haddr(haddr),
        .hsize(hsize),
        .htrans(htrans),
        .hburst(hburst),
        .hwrite(hwrite),
        .hwdata(hwdata),
        .hrdata(hrdata),
        .hresp(hresp),
        .hready(hready)
    );
    
    usb_rx DUT2 (
		.clk(clk), .n_rst(n_rst),
        .dplus_in(dplus_in),
        .dminus_in(dminus_in),
        .buffer_occupancy(buffer_occupancy),
        .rx_packet(rx_packet),
        .rx_data_ready(rx_data_ready),
        .rx_transfer_active(rx_transfer_active),
        .rx_error(rx_error),
        .flush(flush),
        .store_rx_packet_data(store_rx_packet_data),
        .rx_packet_data(rx_packet_data)
    );
    
    usb_tx DUT3 (
		.clk(clk), .n_rst(n_rst),
        .tx_packet(tx_packet),
        .tx_packet_data(tx_packet_data),
        .buffer_occupancy(buffer_occupancy),
        .tx_transfer_active(tx_transfer_active),
        .tx_error(tx_error),
        .get_tx_packet_data(get_tx_packet_data),
        .dplus_out(dplus_out),
        .dminus_out(dminus_out)
    );
    
    data_buffer DUT4 (
		.clk(clk), .n_rst(n_rst),
        .buffer_occupancy(buffer_occupancy),
        .rx_data(rx_data),
        .get_rx_data(get_rx_data),
        .store_tx_data(store_tx_data),
        .tx_data(tx_data),
        .clear(clear),
        .tx_packet_data(tx_packet_data),
        .get_tx_packet_data(get_tx_packet_data),
        .rx_packet_data(rx_packet_data),
        .store_rx_packet_data(store_rx_packet_data),
        .flush(flush)
    );

endmodule
