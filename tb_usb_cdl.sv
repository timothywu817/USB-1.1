// $Id: $
// File name:   tb_usb_1.sv
// Created:     4/27/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module tb_usb_cdl();

localparam clk_period = 2.5;
integer tb_case_num = 0;
logic tb_clk;
logic tb_n_rst;
string tb_test_case;
logic tb_send_data[];
logic tb_dplus_in;
logic tb_dminus_in;
logic [6:0] tb_buffer_occupancy;
logic [7:0] tb_rx_packet_data;
logic tb_store_rx_packet_data;
logic tb_rx_transfer_active;
logic tb_flush;
logic tb_rx_data_ready;
logic tb_rx_error;
logic [2:0] tb_rx_packet;
logic tb_store_tx_data;
logic tb_get_rx_data;
logic tb_get_tx_packet_data;
logic tb_clear;
logic [7:0] tb_tx_data;
logic [7:0] tb_rx_data;
logic [7:0] tb_tx_packet_data;
logic [2:0] tb_tx_packet;
logic tb_dplus_out;
logic tb_dminus_out;
logic tb_tx_transfer_active;
localparam BUS_DELAY  = 800ps; // Based on FF propagation delay

// Sizing related constants
localparam DATA_WIDTH      = 4;
localparam ADDR_WIDTH      = 8;
localparam DATA_WIDTH_BITS = DATA_WIDTH * 8;
localparam DATA_MAX_BIT    = DATA_WIDTH_BITS - 1;
localparam ADDR_MAX_BIT    = ADDR_WIDTH - 1;

// HTRANS Codes
localparam TRANS_IDLE = 2'd0;
localparam TRANS_BUSY = 2'd1;
localparam TRANS_NSEQ = 2'd2;
localparam TRANS_SEQ  = 2'd3;

// HBURST Codes
localparam BURST_SINGLE = 3'd0;
localparam BURST_INCR   = 3'd1;
localparam BURST_WRAP4  = 3'd2;
localparam BURST_INCR4  = 3'd3;
localparam BURST_WRAP8  = 3'd4;
localparam BURST_INCR8  = 3'd5;
localparam BURST_WRAP16 = 3'd6;
localparam BURST_INCR16 = 3'd7;

// Define our address mapping scheme via constants
localparam ADDR_READ_MIN  = 8'd0;
localparam ADDR_READ_MAX  = 8'd127;
localparam ADDR_WRITE_MIN = 8'd64;
localparam ADDR_WRITE_MAX = 8'd255;

//*****************************************************************************
// Declare TB Signals (Bus Model Controls)
//*****************************************************************************
// Testing setup signals
bit                          tb_enqueue_transaction;
bit                          tb_transaction_write;
bit                          tb_transaction_fake;
bit [(ADDR_WIDTH - 1):0]     tb_transaction_addr;
bit [((DATA_WIDTH*8) - 1):0] tb_transaction_data [];
bit [2:0]                    tb_transaction_burst;
bit                          tb_transaction_error;
bit [2:0]                    tb_transaction_size;
// Testing control signal(s)
logic    tb_model_reset;
logic    tb_enable_transactions;
integer  tb_current_addr_transaction_num;
integer  tb_current_addr_beat_num;
logic    tb_current_addr_transaction_error;
integer  tb_current_data_transaction_num;
integer  tb_current_data_beat_num;
logic    tb_current_data_transaction_error;

string                 tb_test_case;
integer                tb_test_case_num;
bit   [DATA_MAX_BIT:0] tb_test_data [];
string                 tb_check_tag;
logic                  tb_mismatch;
logic                  tb_check;
integer                tb_i;

//*****************************************************************************
// General System signals
//*****************************************************************************
logic tb_clk;
logic tb_n_rst;

//*****************************************************************************
// AHB-Lite-Slave side signals
//*****************************************************************************
logic                          tb_hsel;
logic [1:0]                    tb_htrans;
logic [2:0]                    tb_hburst;
logic [(ADDR_WIDTH - 1):0]     tb_haddr;
logic [2:0]                    tb_hsize;
logic                          tb_hwrite;
logic [((DATA_WIDTH*8) - 1):0] tb_hwdata;
logic [((DATA_WIDTH*8) - 1):0] tb_hrdata;
logic                          tb_hresp;
logic                          tb_hready;
logic                          tb_d_mode;
logic [2:0]                    tb_tx_packet;
logic                          tb_clear;
logic [7:0]                    tb_tx_data;
logic                          tb_store_tx_data;
logic                          tb_get_rx_data;
logic [7:0]                    tb_rx_data;
logic                          tb_tx_error;
logic                          tb_tx_transfer_active;
logic [7:0]                    tb_buffer_occupancy;
logic                          tb_rx_error;
logic                          tb_rx_transfer_active;
logic                          tb_rx_data_ready;
logic [3:0]                    tb_rx_packet;
logic                           tb_send_data[];

ahb_lite_bus_cdl 
              #(  .DATA_WIDTH(4),
                  .ADDR_WIDTH(8))
              BFM(.clk(tb_clk),
                  // Testing setup signals
                  .enqueue_transaction(tb_enqueue_transaction),
                  .transaction_write(tb_transaction_write),
                  .transaction_fake(tb_transaction_fake),
                  .transaction_addr(tb_transaction_addr),
                  .transaction_size(tb_transaction_size),
                  .transaction_data(tb_transaction_data),
                  .transaction_burst(tb_transaction_burst),
                  .transaction_error(tb_transaction_error),
                  // Testing controls
                  .model_reset(tb_model_reset),
                  .enable_transactions(tb_enable_transactions),
                  .current_addr_transaction_num(tb_current_addr_transaction_num),
                  .current_addr_beat_num(tb_current_addr_beat_num),
                  .current_addr_transaction_error(tb_current_addr_transaction_error),
                  .current_data_transaction_num(tb_current_data_transaction_num),
                  .current_data_beat_num(tb_current_data_beat_num),
                  .current_data_transaction_error(tb_current_data_transaction_error),
                  // AHB-Lite-Slave Side
                  .hsel(tb_hsel),
                  .haddr(tb_haddr),
                  .hsize(tb_hsize),
                  .htrans(tb_htrans),
                  .hburst(tb_hburst),
                  .hwrite(tb_hwrite),
                  .hwdata(tb_hwdata),
                  .hrdata(tb_hrdata),
                  .hresp(tb_hresp),
                  .hready(tb_hready));
usb_cdl DTU1 ( .clk(tb_clk), .n_rst(tb_n_rst),
                        // AHB-Lite-Slave Side Bus
                        .hsel(tb_hsel),
                        .haddr(tb_haddr),
                        .hsize(tb_hsize[1:0]),
                        .htrans(tb_htrans),
                        .hburst(tb_hburst),
                        .hwrite(tb_hwrite),
                        .hwdata(tb_hwdata),
                        .hrdata(tb_hrdata),
                        .hresp(tb_hresp),
                        .d_mode(tb_d_mode),
                        .dplus_in(dplus_in),
                        .dminus_in(dminus_in),
                        .dplus_out(dplus_out),
                        .dminus_out(dminus_out));

always begin
    tb_clk = 1'b0;
    #(clk_period/2.0);
    tb_clk = 1'b1;
    #(clk_period/2.0);
end
task enqueue_transaction;
  input bit for_dut;
  input bit write_mode;
  input bit [ADDR_MAX_BIT:0] address;
  input bit [DATA_MAX_BIT:0] data [];
  input bit [2:0] burst_type;
  input bit expected_error;
  input bit [1:0] size;
begin
  // Make sure enqueue flag is low (will need a 0->1 pulse later)
  tb_enqueue_transaction = 1'b0;
  #0.1ns;

  // Setup info about transaction
  tb_transaction_fake  = ~for_dut;
  tb_transaction_write = write_mode;
  tb_transaction_addr  = address;
  tb_transaction_data  = data;
  tb_transaction_error = expected_error;
  tb_transaction_size  = {1'b0,size};
  tb_transaction_burst = burst_type;

  // Pulse the enqueue flag
  tb_enqueue_transaction = 1'b1;
  #0.1ns;
  tb_enqueue_transaction = 1'b0;
end
endtask

task  taskName(arguments);
  
endtask //
task send_packet;
    input data [];
    input time data_period;
    integer i;
begin
    for(i = 0; i<tb_send_data.size(); i=i+1)
    begin
        tb_dplus_in = tb_send_data[i];
        tb_dminus_in = ~tb_send_data[i];
        #data_period;
    end
    //EOP
    tb_dplus_in = 1'b0;
    tb_dminus_in = 1'b0;
    #data_period;
    #data_period;
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #data_period;
end
endtask
// Task to wait for multiple transactions to happen
task execute_transactions;
  input integer num_transactions;
  integer wait_var;
begin
  // Activate the bus model
  tb_enable_transactions = 1'b1;
  @(posedge tb_clk);

  // Process the transactions (all but last one overlap 1 out of 2 cycles
  for(wait_var = 0; wait_var < num_transactions; wait_var++) begin
    @(posedge tb_clk);
  end

  // Run out the last one (currently in data phase)
  @(posedge tb_clk);

  // Turn off the bus model
  @(negedge tb_clk);
  tb_enable_transactions = 1'b0;
end
endtask
initial begin
  // Initialize Test Case Navigation Signals
  tb_test_case       = "Initialization";
  tb_test_case_num   = -1;
  tb_test_data       = new[1];
  tb_check_tag       = "N/A";
  tb_check           = 1'b0;
  tb_mismatch        = 1'b0;
  // Initialize all of the directly controled DUT inputs
  tb_n_rst          = 1'b1;
  // Initialize all of the bus model control inputs
  tb_model_reset          = 1'b0;
  tb_enable_transactions  = 1'b0;
  tb_enqueue_transaction  = 1'b0;
  tb_transaction_write    = 1'b0;
  tb_transaction_fake     = 1'b0;
  tb_transaction_addr     = '0;
  tb_transaction_data     = new[1];
  tb_transaction_error    = 1'b0;
  tb_transaction_size     = 3'd0;
  tb_transaction_burst    = 3'd0;
  tb_rx_packet            = 3'd0;
  tb_rx_data_ready        = 1'b0;
  tb_rx_transfer_active   = 1'b0;
  tb_rx_error             = 1'b0;
  tb_buffer_occupancy     = 8'd0;
  tb_tx_transfer_active   = 1'b0;
  tb_tx_error             = 1'b0;
  tb_rx_data              = 8'b0;


  // Wait some time before starting first test case
  #(0.1);

  // Clear the bus model
  reset_model();

  //*****************************************************************************
  // Host to End success
  //*****************************************************************************
    tb_test_case = "host to end success";
    tb_case_num = tb_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    $info("send out to rx");
    tb_send_data = '{0,1,0,1,0,1,0,0, 1,1,1,0,0,1,0,0, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    send_packet(tb_send_data, 8 * CLK_PERIOD);
    $info("check out");
    enqueue_transaction(1'b1, 1'b0, 4'd4, {32'h4}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("occupancy check = 0");
    enqueue_transaction(1'b1, 1'b0, 4'd8, {32'h0}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("try to receive few bytes");
    tb_send_data = '{0,1,0,1,0,1,0,0, 0,0,1,0,1,0,1,0,  1,1,0,0,1,1,0,0,    1,1,0,0,1,1,0,0,   1,1,0,0,1,1,0,0,   
    1,1,0,0,1,1,0,0,   1,1,0,0,1,1,0,0,   1,1,0,0,1,1,0,0,   1,1,0,0,1,1,0,0};
    send_packet(tb_send_data, 8 * CLK_PERIOD);
    $info("check ack");
    enqueue_transaction(1'b1, 1'b1, 4'hC, {32'h2}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("check bytes num = 7");
    enqueue_transaction(1'b1, 1'b0, 4'd8, {32'h7}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("check first 4 bytes");
    enqueue_transaction(1'b1, 1'b0, 4'd0, {32'hAAAAAAAA}, BURST_SINGLE, 1'b0, 2'd2);
    execute_transactions(1);
    $info("check nxt byte");
    enqueue_transaction(1'b1, 1'b0, 4'd1, {32'hAA000}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("check last two byte");
    enqueue_transaction(1'b1, 1'b0, 4'd3, {32'hAAAA0000}, BURST_SINGLE, 1'b0, 2'd1);
    execute_transactions(1);
    $info("occupancy check = 0");
    enqueue_transaction(1'b1, 1'b0, 4'd8, {32'h0}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
  //*****************************************************************************
  // END to Host success
  //*****************************************************************************
    tb_test_case = "end to host success";
    tb_case_num = tb_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    $info("send in to rx");
    tb_send_data = '{0,1,0,1,0,1,0,0,   0,1,0,0,1,1,0,0,   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    send_packet(tb_send_data, 8 * CLK_PERIOD);
    $info("check in received");
    enqueue_transaction(1'b1, 1'b0, 4'd4, {32'h2}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("make sure the buffer is empty by clearing it");
    enqueue_transaction(1'b1, 1'b1, 4'hD, {32'h1}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("check the buffer is empty");
    enqueue_transaction(1'b1, 1'b0, 4'd8, {32'h0}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("Wrtie bytes to host");
    enqueue_transaction(1'b1, 1'b1, 4'd0, {32'hAAAAAAAA}, BURST_SINGLE, 1'b0, 2'd2);
    execute_transactions(1);
    enqueue_transaction(1'b1, 1'b1, 4'd1, {32'hAA000}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    enqueue_transaction(1'b1, 1'b1, 4'd3, {32'hAAAA0000}, BURST_SINGLE, 1'b0, 2'd1);
    execute_transactions(1);
    $info("occupancy check = 7");
    enqueue_transaction(1'b1, 1'b0, 4'd8, {32'h7}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    $info("send packet to tx");
    enqueue_transaction(1'b1, 1'b0, 4'd12, {32'h1}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);

    $info("sending packet to host");
    enqueue_transaction(1'b1, 1'b0, 4'd4, {32'h200}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);
    #(CLK_PERIOD * 1000);
//////////////////////////////////////////////////////////////////////////
//NOT DONE
    $info("ACK received");//Not done yet//
    tb_send_data = '{0,1,0,1,0,1,0,0,   0,1,1,1,0,0,1,0};
    send_packet(tb_send_data, 8 * CLK_PERIOD);
    enqueue_transaction(1'b1, 1'b0, 4'd4, {32'h200}, BURST_SINGLE, 1'b0, 2'd0);
    execute_transactions(1);

  //*****************************************************************************
  // Power-on-Reset Test Case
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Power-on-Reset";
  tb_test_case_num = tb_test_case_num + 1;
  
  // Reset the DUT
  reset_dut();

  // No actual DUT -> Just a place holder currently
  

  //*****************************************************************************
  // Test Case: Isolate write
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Isolate write size 0";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h12345678};
  enqueue_transaction(1'b1, 1'b1, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  enqueue_transaction(1'b1, 1'b1, 8'd1, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  enqueue_transaction(1'b1, 1'b1, 8'd2, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  enqueue_transaction(1'b1, 1'b1, 8'd3, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  #(CLK_PERIOD * 5);


  //*****************************************************************************
  // Test Case: Isolate write
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Isolate write size 1";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h12345678};
  enqueue_transaction(1'b1, 1'b1, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
  execute_transactions(1);
  #(CLK_PERIOD * 5);

  enqueue_transaction(1'b1, 1'b1, 8'd2, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
  execute_transactions(1);
  #(CLK_PERIOD * 5);

  //*****************************************************************************
  // Test Case: Isolate write
  //*****************************************************************************
  // Update Navigation Info
  tb_test_case     = "Isolate write size 2";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h12345678};
  enqueue_transaction(1'b1, 1'b1, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
  execute_transactions(1);
  #(CLK_PERIOD * 5);


  //*****************************************************************************
  // Test Case: Isolate read
  //*****************************************************************************
  //Update Navigation Info
  tb_test_case     = "Isolate read";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h12345678};
  tb_rx_data = '{8'h98};
  enqueue_transaction(1'b1, 1'b0, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);

  #(10*CLK_PERIOD);

  tb_rx_data = '{8'h76};

  enqueue_transaction(1'b1, 1'b0, 8'd1, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);

  #(10*CLK_PERIOD);
  tb_rx_data = '{8'h54};
 

  enqueue_transaction(1'b1, 1'b0, 8'd2, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  #(10*CLK_PERIOD);
  tb_rx_data = '{8'h32};
  


  enqueue_transaction(1'b1, 1'b0, 8'd3, tb_test_data, BURST_SINGLE, 1'b0, 2'd0);
  execute_transactions(1);
  #(10*CLK_PERIOD);

  #(CLK_PERIOD * 2);
  
//   //*****************************************************************************
//   // Test Case: write and read to unallocated addresses
//   //*****************************************************************************
//   tb_test_case     = "Isolate read size 2";
//   tb_test_case_num = tb_test_case_num + 1;
//     $info("case %d: %s", tb_case_num, tb_test_case);
//   reset_dut();

//   fork 
//   begin
//     tb_rx_data = '{8'h98};
//     enqueue_transaction(1'b1, 1'b0, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
//     execute_transactions(1);

//     #(10*CLK_PERIOD);
//   end
//   begin
//     @(posedge tb_get_rx_data);
//     @(posedge tb_clk);
//     tb_rx_data = '{8'h89};
//   end
//   join

//   //*****************************************************************************
//   // Test Case: write and read to unallocated addresses
//   //*****************************************************************************
//   tb_test_case     = "Isolate read size 4";
//   tb_test_case_num = tb_test_case_num + 1;
//     $info("case %d: %s", tb_case_num, tb_test_case);
//   reset_dut();

//   fork 
//   begin
//     tb_rx_data = '{8'h98};
//     enqueue_transaction(1'b1, 1'b0, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
//     execute_transactions(1);

//     #(10*CLK_PERIOD);
//   end
//   begin
//     @(posedge tb_get_rx_data);
//     @(posedge tb_clk);
//     tb_rx_data = '{8'h89};
//     @(posedge tb_clk);   
//     tb_rx_data = '{8'h78};
//     @(posedge tb_clk);   
//     tb_rx_data = '{8'h87};
//   end
//   join

  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  tb_test_case     = "write to read only";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h12345678};
  enqueue_transaction(1'b1, 1'b1, 8'd4, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
  enqueue_transaction(1'b1, 1'b1, 8'd5, tb_test_data, BURST_SINGLE, 1'b1, 2'd1);
  enqueue_transaction(1'b1, 1'b1, 8'd8, tb_test_data, BURST_SINGLE, 1'b1, 2'd2);
  execute_transactions(3);

  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  tb_test_case     = "overlapp write";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h2};
  enqueue_transaction(1'b1, 1'b1, 8'd12, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
  tb_test_data = '{32'h1};
  enqueue_transaction(1'b1, 1'b1, 8'd13, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
  execute_transactions(2);

  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  tb_test_case     = "overlapp read";
  tb_test_case_num = tb_test_case_num + 1;
    $info("case %d: %s", tb_case_num, tb_test_case);
  reset_dut();
  tb_test_data = '{32'h1};
  tb_rx_error = 1;
  tb_buffer_occupancy = 2;
  enqueue_transaction(1'b1, 1'b0, 8'd6, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
  tb_test_data = '{32'h2};
  enqueue_transaction(1'b1, 1'b0, 8'd8, tb_test_data, BURST_SINGLE, 1'b1, 2'd0);
  execute_transactions(2);
  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  /*tb_test_case     = "buffer occupancy";
  tb_test_case_num = tb_test_case_num + 1;
  reset_dut();
  tb_buffer_occupancy = '{6'b110011};
  enqueue_transaction(1'b1, 1'b1, 8'd1, , BURST_SINGLE, 1'b1, 2'd0);
  execute_transactions(1);
  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  tb_test_case     = "d_mode";
  tb_test_case_num = tb_test_case_num + 1;
  reset_dut();
  tb_buffer_occupancy = '{6'b110011};
  enqueue_transaction(1'b1, 1'b1, 8'd1, , BURST_SINGLE, 1'b1, 2'd0);
  execute_transactions(1);*/

$stop();
end

endmodule
