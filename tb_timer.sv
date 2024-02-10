// $Id: $
// File name:   tb_timer.sv
// Created:     4/23/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: test bench for timer
module tb_timer();
  // Define local parameters used by the test bench
  localparam  CLK_PERIOD    = 2.5;
  // Declare DUT portmap signals
  reg tb_clk;
  reg tb_n_rst;
  reg tb_count_enable;
  reg tb_clear;
  reg [3:0] tb_count_out;
  reg [3:0] tb_rollover_val;
  reg tb_rollover_flag; // Declare test bench signals
  integer tb_test_num;
  string tb_test_case;

  task reset_dut;
    begin
        tb_n_rst = 1'b0;
        @posedge(tb_clk);
        @posedge(tb_clk);
        
    end
  endtask
endmodule
