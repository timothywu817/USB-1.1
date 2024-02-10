// $Id: $
// File name:   tb_data_buffer.sv
// Created:     4/23/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .

`timescale 1ns/10ps
module tb_data_buffer ();

    localparam clk_period = 2.5;
	string tb_test_case;	
	logic tb_clk;
	logic tb_n_rst;
	logic tb_store_rx_packet_data;
	logic tb_store_tx_data;
	logic tb_get_rx_data;
	logic tb_get_tx_packet_data;
	logic tb_flush;
	logic tb_clear;
	logic [7 : 0] tb_rx_packet_data;
	logic [7 : 0] tb_tx_data;
	logic [7 : 0] tb_rx_data;
	logic [7 : 0] tb_tx_packet_data;
	logic [6 : 0] tb_buffer_occupancy;
    data_buffer DUT1(
        .clk(tb_clk), 
        .n_rst(tb_n_rst), 
        .store_rx_packet_data(tb_store_rx_packet_data), 
        .store_tx_data(tb_store_tx_data), 
        .get_rx_data(tb_get_rx_data), 
        .get_tx_packet_data(tb_get_tx_packet_data),
        .flush(tb_flush), 
        .clear(tb_clear), 
        .rx_packet_data(tb_rx_packet_data), 
        .tx_data(tb_tx_data), 
        .buffer_occupancy(tb_buffer_occupancy),
        .rx_data(tb_rx_data), 
        .tx_packet_data(tb_tx_packet_data)
    );
always begin
    tb_clk = 1'b0;
    #(clk_period / 2.0);
    tb_clk = 1'b1;
    #(clk_period / 2.0);
end

initial begin
    tb_n_rst = 1'b1;
    tb_store_rx_packet_data = 1'b0;
    tb_store_tx_data = 1'b0;
    tb_get_rx_data = 1'b0;
    tb_get_tx_packet_data = 1'b0;
    tb_flush = 1'b0;
    tb_clear = 1'b0;
    tb_rx_packet_data = 8'b0;
    tb_tx_data = 8'b0;
    tb_test_case = "Power on Reset";
    // reset dut
    tb_n_rst = 1'b0;
    #(clk_period * 1);
    @(negedge tb_clk);
    tb_n_rst = 1'b1;
    #(clk_period / 2.0);
    #(clk_period *4);

    // normal store rx_packet_data
    tb_test_case = "normal store rx_packet_data";
    tb_store_rx_packet_data = 1'b1;
    tb_rx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 4);

    // normal drain rx_packet_data
    tb_test_case = "normal drain rx_packet_data";
    tb_get_rx_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_get_rx_data = 1'b0;
    #(clk_period * 4);

    // normal store tx_packet_data
    tb_test_case = "normal store tx_packet_data";
    tb_store_tx_data = 1'b1;
    tb_tx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_store_tx_data = 1'b0;
    #(clk_period * 4);

    // normal drain tx_packet_data
    tb_test_case = "normal drain tx_packet_data";
    tb_get_tx_packet_data = 1'b1;
    // tb_tx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_get_tx_packet_data = 1'b0;
    #(clk_period * 4);

    //store 4 rx_packet_data
    tb_test_case = "store 4 rx_packet_data";
    tb_store_rx_packet_data = 1'b1;
    tb_rx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd29;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd87;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd118;
    #(clk_period * 1);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 4);

    // drain 4 rx_packet_data
    tb_test_case = "drain 4 rx_packet_data";
    tb_get_rx_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 4);
    tb_get_rx_data = 1'b0;
    #(clk_period * 4);

    //store 4 tx_data
    tb_test_case = "store 4 tx_data";
    tb_store_tx_data = 1'b1;
    tb_tx_data = 8'd100;
    #(clk_period * 1);
    tb_tx_data = 8'd29;
    #(clk_period * 1);
    tb_tx_data = 8'd87;
    #(clk_period * 1);
    tb_tx_data = 8'd118;
    #(clk_period * 1);
    tb_store_tx_data = 1'b0;
    #(clk_period * 4);

    // drain 4 tx_packet_data
    tb_test_case = "drain 4 rx_packet_data";
    tb_get_tx_packet_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 4);
    tb_get_tx_packet_data = 1'b0;
    #(clk_period * 4);

    //store to full
    tb_test_case = "store full";
    tb_store_rx_packet_data = 1'b1;
    tb_rx_packet_data = 8'd100;
    #(clk_period * 64);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 4);

    //continue to write
    tb_test_case = "continue to write full";
    tb_store_rx_packet_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 2);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 4);

    
    // drain empty
    tb_test_case = "drain empty";
    tb_get_tx_packet_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 66);
    tb_get_tx_packet_data = 1'b0;
    #(clk_period * 4);

    //continue to drain
    tb_test_case = "continue to drain empty";
    tb_get_tx_packet_data = 1'b1;
    // tb_rx_packet_data = 8'd100;
    #(clk_period * 2);
    tb_get_tx_packet_data = 1'b0;
    #(clk_period * 4);

    //flush
    tb_test_case = "flush";
    tb_store_rx_packet_data = 1'b1;
    tb_rx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd29;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd87;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd118;
    #(clk_period * 1);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 1);
    tb_flush = 1'b1;
    #(clk_period * 2);
    tb_flush = 1'b0;
    #(clk_period * 4);

    //clear
    tb_test_case = "clear";
    tb_store_rx_packet_data = 1'b1;
    tb_rx_packet_data = 8'd100;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd29;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd87;
    #(clk_period * 1);
    tb_rx_packet_data = 8'd118;
    #(clk_period * 1);
    tb_store_rx_packet_data = 1'b0;
    #(clk_period * 1);
    tb_clear = 1'b1;
    #(clk_period * 2);
    tb_clear = 1'b0;
    #(clk_period * 4);

$stop();
end

endmodule
