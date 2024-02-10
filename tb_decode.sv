// $Id: $
// File name:   tb_decode.sv
// Created:     4/23/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .

`timescale 1ns/10ps

module tb_decode();

localparam clk_period = 2.5;
string tb_test_case;
logic tb_clk;
logic tb_n_rst;
logic tb_shift_en;
logic tb_eop;
logic tb_dplus_in_sync;
logic tb_d_orig;

decode DUT2(
    .clk(tb_clk), 
    .n_rst(tb_n_rst),
    .shift_enable(tb_shift_en),
    .eop(tb_eop),
    .dplus_in_sync(tb_dplus_in_sync),
    .d_orig(tb_d_orig));

always begin
    tb_clk = 1'b0;
    #(clk_period / 2.0);
    tb_clk = 1'b1;
    #(clk_period / 2.0);
end

initial begin
    tb_n_rst = 1'b1;
    tb_shift_en = 1'b0;
    tb_eop = 1'b0;
    tb_dplus_in_sync = 1'b0;
    tb_d_orig = 1'b0;
    tb_test_case = "power on reset";
    tb_n_rst = 1'b0;
    #(clk_period * 1);
    @(negedge tb_clk);
    tb_n_rst = 1'b1;
    #(clk_period / 2.0);
    #(clk_period * 2);

    //input
    tb_shift_en = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_shift_en = 1'b0;
    #(clk_period * 4);

    tb_eop = 1'b1;
    #(clk_period * 1);

    //eop
    tb_shift_en = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b1;
    #(clk_period * 1);
    tb_eop = 1'b1;
    #(clk_period * 1);
    tb_dplus_in_sync = 1'b0;
    #(clk_period * 1);
    tb_shift_en = 1'b0;
    #(clk_period * 4);






$stop();
end


endmodule
