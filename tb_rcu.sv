// $Id: $
// File name:   tb_rcu.sv
// Created:     4/23/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module tb_rcu();
    localparam clk_period = 2.5;
    logic tb_clk;
    logic tb_n_rst;
    logic tb_shift_enable;
    logic [7:0] tb_rcv_data;
    logic tb_d_edge;
    logic tb_eop;
    logic tb_byte_received;
    logic [6:0] tb_buffer_occupancy;
    logic tb_byte_en;
    logic tb_addr_en;
    logic tb_rcving;
    logic tb_r_error;
    logic [2:0] tb_pid;
    string tb_test_case;
    logic tb_store_rx_packet_data;
    logic tb_flush;
    logic tb_address_comp;

rcu DUT3 (.clk(tb_clk), .n_rst(tb_n_rst), .shift_enable(tb_shift_enable),
    .addr_en(tb_addr_en), .byte_en(tb_byte_en),
    .rcv_data(tb_rcv_data), .d_edge(tb_d_edge), .eop(tb_eop),
    .byte_received(tb_byte_received), .rcving(tb_rx_transfer_active), 
    .buffer_occupancy(tb_buffer_occupancy),.address_comp(tb_address_comp),
    .r_error(tb_rx_error), .store_rx_packet_data(tb_store_rx_packet_data), 
    .pid(tb_pid),.flush(tb_flush));

always begin
    tb_clk = 1'b0;
    #(clk_period / 2.0);
    tb_clk = 1'b1;
    #(clk_period / 2.0);
end

initial begin
    tb_n_rst = 1'b1;
    tb_shift_enable = 0;
    tb_rcv_data = 0;
    tb_d_edge = 0;
    tb_eop = 0;
    tb_address_comp = 0;
    tb_byte_received = 0;
    tb_buffer_occupancy = 0;
    //reset 
    tb_test_case = "Power on Reset";
    tb_n_rst = 1'b0;
    #(clk_period * 1);
    @(negedge tb_clk);
    tb_n_rst = 1'b1;
    #(clk_period / 2.0);
    #(clk_period *4);
    
    //normal input with synckey
    tb_shift_enable = 1;
    tb_d_edge = 1;
    #(clk_period * 1);
    tb_d_edge = 0;
    tb_rcv_data = 8'b00000001;
    #(clk_period * 1);
    tb_byte_received = 1;
    #(clk_period * 1);
    tb_rcv_data = 8'b00011110;
    #(clk_period * 1);
    tb_address_comp = 1;
    tb_eop = 1;
    #(clk_period * 3);
    tb_eop = 0;
    tb_d_edge = 1;
    #(clk_period * 1);

    //normal input without synckey
    tb_shift_enable = 1;
    tb_d_edge = 1;
    tb_rcv_data = 8'b00001100;
    tb_byte_received = 1;
    #(clk_period * 1);
    tb_rcv_data = 8'b00011110;
    #(clk_period * 1);
    tb_eop = 1;
    #(clk_period * 4);
//synckey with pid = data
    tb_shift_enable = 1;
    tb_d_edge = 1;
    #(clk_period * 1);
    tb_d_edge = 0;
    tb_rcv_data = 8'b00000001;
    #(clk_period * 1);
    tb_byte_received = 1;
    #(clk_period * 1);
    tb_rcv_data = 8'b00111100;
    #(clk_period * 1);
    tb_address_comp = 1;
    tb_rcv_data = 8'b10110100;
    #(clk_period * 8);
    tb_eop = 1;
    #(clk_period * 3);
    tb_eop = 0;
    tb_d_edge = 1;
    #(clk_period * 1);



$stop();
end
endmodule
