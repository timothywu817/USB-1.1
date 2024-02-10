// $Id: $
// File name:   tb_ahb_lite_slave_cdl.sv
// Created:     10/1/2018
// Author:      Tim Pritchett
// Lab Section: 9999
// Version:     1.0  Initial Design Entry
// Description: Full ABH-Lite slave/bus model test bench

`timescale 1ns / 10ps

module tb_ahb_lite_slave_cdl();

// Timing related constants
localparam CLK_PERIOD = 10;
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

//*****************************************************************************
// Clock Generation Block
//*****************************************************************************
// Clock generation block
always begin
  // Start with clock low to avoid false rising edge events at t=0
  tb_clk = 1'b0;
  // Wait half of the clock period before toggling clock value (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
  tb_clk = 1'b1;
  // Wait half of the clock period before toggling clock value via rerunning the block (maintain 50% duty cycle)
  #(CLK_PERIOD/2.0);
end

//*****************************************************************************
// Bus Model Instance
//*****************************************************************************
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

//*****************************************************************************
// Test Module Instance
//*****************************************************************************
ahb_lite_slave_cdl TM ( .clk(tb_clk), .n_rst(tb_n_rst),
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
                        .tx_packet(tb_tx_packet),
                        .clear(tb_clear),
                        .tx_data(tb_tx_data),
                        .store_tx_data(tb_store_tx_data),
                        .get_rx_data(tb_get_rx_data),
                        .rx_data(tb_rx_data),
                        .tx_error(tb_tx_error),
                        .tx_transfer_active(tb_tx_transfer_active),
                        .buffer_occupancy(tb_buffer_occupancy),
                        .rx_error(tb_rx_error),
                        .rx_transfer_active(tb_rx_transfer_active),
                        .rx_data_ready(tb_rx_data_ready),
                        .rx_packet(tb_rx_packet),
                        .hready(tb_hready));

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
task reset_model;
begin
  tb_model_reset = 1'b1;
  #(0.1);
  tb_model_reset = 1'b0;
end
endtask

// Task to enqueue a new transaction
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


//*****************************************************************************
//*****************************************************************************
// Main TB Process
//*****************************************************************************
//*****************************************************************************
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
  
  //*****************************************************************************
  // Test Case: write and read to unallocated addresses
  //*****************************************************************************
  tb_test_case     = "Isolate read size 2";
  tb_test_case_num = tb_test_case_num + 1;
  reset_dut();

  fork 
  begin
    tb_rx_data = '{8'h98};
    enqueue_transaction(1'b1, 1'b0, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd1);
    execute_transactions(1);

    #(10*CLK_PERIOD);
  end
  begin
    @(posedge tb_get_rx_data);
    @(posedge tb_clk);
    tb_rx_data = '{8'h89};
  end
  join

  //*****************************************************************************
  // Test Case: write and read to unallocated addresses
  //*****************************************************************************
  tb_test_case     = "Isolate read size 4";
  tb_test_case_num = tb_test_case_num + 1;
  reset_dut();

  fork 
  begin
    tb_rx_data = '{8'h98};
    enqueue_transaction(1'b1, 1'b0, 8'd0, tb_test_data, BURST_SINGLE, 1'b0, 2'd2);
    execute_transactions(1);

    #(10*CLK_PERIOD);
  end
  begin
    @(posedge tb_get_rx_data);
    @(posedge tb_clk);
    tb_rx_data = '{8'h89};
    @(posedge tb_clk);   
    tb_rx_data = '{8'h78};
    @(posedge tb_clk);   
    tb_rx_data = '{8'h87};
  end
  join

  //*****************************************************************************
  // Test Case: write to read only
  //*****************************************************************************
  // Update Navigation Info tx same as test
  tb_test_case     = "write to read only";
  tb_test_case_num = tb_test_case_num + 1;
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
