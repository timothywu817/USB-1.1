
`timescale 1ns / 10ps

module tb_usb_tx ();
localparam  CLK_PERIOD = 2.5;
string      tb_test_case;
integer     tb_test_case_num;

//*****************************************************************************
// General System signals
//*****************************************************************************
logic tb_clk;
logic tb_n_rst;

//*****************************************************************************
// USB-TX-Slave side signals
//*****************************************************************************
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
logic [2 : 0] tb_tx_packet;
logic tb_tx_transfer_active;
logic tb_tx_error;
logic tb_data_orig;
logic tb_dplus_out;
logic tb_dminus_out;

	
data_buffer DUT4(.clk(tb_clk), .n_rst(tb_n_rst), 
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
                  .tx_packet_data(tb_tx_packet_data));

usb_tx DUT5(.clk(tb_clk), .n_rst(tb_n_rst), 
            .buffer_occupancy(tb_buffer_occupancy), 
            .tx_packet_data(tb_tx_packet_data), 
            .tx_packet(tb_tx_packet),
            .get_tx_packet_data(tb_get_tx_packet_data), 
            .tx_transfer_active(tb_tx_transfer_active), 
            .tx_error(tb_tx_error), 
            .dplus_out(tb_dplus_out), 
            .dminus_out(tb_dminus_out));

//*****************************************************************************
// Clock generation
//*****************************************************************************
// Generate clock signal
always begin
  tb_clk = 1'b0;
  #(CLK_PERIOD/2.0);
  tb_clk = 1'b1;
  #(CLK_PERIOD/2.0);
end

//*****************************************************************************
// DUT Related TB Tasks
//*****************************************************************************
// Task for standard DUT reset procedure
task reset_dut;
begin
  // Activate the reset
  tb_n_rst = 1'b0;

  // Maintain the reset for more than one cycle
  @(posedge tb_clk);
  @(posedge tb_clk);

  // Wait until safely away from rising edge of the clock before releasing
  @(negedge tb_clk);
  tb_n_rst = 1'b1;

  // Leave out of reset for a couple cycles before allowing other stimulus
  // Wait for negative clock edges, 
  // since inputs to DUT should normally be applied away from rising clock edges
  @(negedge tb_clk);
  @(negedge tb_clk);
end
endtask

//*****************************************************************************
// Bus Model Usage Related TB Tasks
//*****************************************************************************
// Task to pulse the reset for the bus model
initial begin
  tb_store_rx_packet_data = 1'b0;
  tb_store_tx_data = 1'b0;
  tb_get_rx_data = 1'b0;
  tb_flush = 1'b0;
  tb_clear = 1'b0;
  tb_rx_packet_data = 8'b0;
  tb_tx_data = 8'b0;
  tb_tx_packet = 3'd0;
  tb_test_case_num = 0;
  tb_test_case = "Power on Reset";
  $info("Test Case %s begin", tb_test_case);
  reset_dut();
  $info("Test Case %s Succuess", tb_test_case);


  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "Send data";
  $info("Test Case %s begin", tb_test_case);
  tb_store_tx_data = 1'b1;
  tb_tx_data = 8'b01001101;
  #(CLK_PERIOD * 1);
  tb_tx_data = 8'b10101010;
  #(CLK_PERIOD * 1);
  tb_tx_data = 8'b10111110;
  #(CLK_PERIOD * 1);
  tb_store_tx_data = 1'b0;
  #(CLK_PERIOD * 3);
  tb_tx_packet = 3'd1;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 600);
  $info("Test Case %s Succuess", tb_test_case);

  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "empty send data";
  $info("Test Case %s begin", tb_test_case);
  tb_tx_packet = 3'd1;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 200);
  $info("Test Case %s Succuess", tb_test_case);

  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "ACK";
  $info("Test Case %s begin", tb_test_case);
  tb_tx_packet = 3'd2;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 200);
  $info("Test Case %s Succuess", tb_test_case);

  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "NAK";
  $info("Test Case %s begin", tb_test_case);
  tb_tx_packet = 3'd3;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 200);
  $info("Test Case %s Succuess", tb_test_case);

  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "STALL";
  $info("Test Case %s begin", tb_test_case);
  tb_tx_packet = 3'd4;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 200);
  $info("Test Case %s Succuess", tb_test_case);

  tb_test_case_num = tb_test_case_num + 1;
  tb_test_case = "invalid id";
  $info("Test Case %s begin", tb_test_case);
  tb_tx_packet = 3'd7;
  #(CLK_PERIOD * 1);
  tb_tx_packet = 3'd0;
  #(CLK_PERIOD * 100);
  $info("Test Case %s Succuess", tb_test_case);
  
  $stop();
end

endmodule
