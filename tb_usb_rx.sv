// $Id: $
// File name:   tb_usb_rx.sv
// Created:     4/23/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
`timescale 1ns / 10ps

module tb_usb_rx();

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

usb_rx DUT1 (
    .dplus_in(tb_dplus_in),
    .dminus_in(tb_dminus_in),
    .clk(tb_clk),
    .n_rst(tb_n_rst),
    .rx_packet_data(tb_rx_packet_data),
    .store_rx_packet_data(tb_store_rx_packet_data),
    .rx_transfer_active(tb_rx_transfer_active),
    .rx_error(tb_rx_error),
    .rx_packet(tb_rx_packet),
    .rx_data_ready(tb_rx_data_ready),
    .flush(tb_flush),
    .buffer_occupancy(tb_buffer_occupancy)
);
data_buffer DUT2(
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
    #(clk_period/2.0);
    tb_clk = 1'b1;
    #(clk_period/2.0);
end

task check_output;
    input integer tb_case_num;
    input string test_case;

begin
    $info("Test case %d: %s",tb_case_num, test_case);    

end
endtask
task reset_dut;
begin
    tb_n_rst = 1'b0;
    @(posedge tb_clk);
    @(posedge tb_clk);

    @(negedge tb_clk);
    tb_n_rst = 1'b1;

    @(negedge tb_clk);
    @(negedge tb_clk);
end
endtask

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

task send_packet_incorrect_eop;
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
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #data_period;
end
endtask

initial begin
    tb_test_case = "power on reset";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    tb_store_tx_data = 1'b0;
    tb_get_rx_data = 1'b0;
    tb_get_tx_packet_data = 1'b0;
    tb_clear = 1'b0;
    tb_tx_data = 8'b0;

    reset_dut();

    //send valid packet_with pid DATA_0
    @(negedge tb_clk);
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_test_case = "PID of DATA0 following synckey";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_send_data     = '{0,1,0,1,0,1,0,0, 1,0,0,0,0,0,1,0,  1,1,0,0,1,0,0,1};
    send_packet(tb_send_data, (8*clk_period));


    //send valid packet_with pid DATA_1
    tb_test_case = "DATA1 with one packet";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data     = '{0,1,0,1,0,1,0,0, 0,1,1,1,0,0,1,0, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1};
    send_packet(tb_send_data, (8*clk_period));

    //send muti valid 'datapack' without reset in the middle
    tb_test_case        = "DATA1 with two different rx_data packets";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data     = '{0,1,0,1,0,1,0,0,   1,0,0,0,0,0,1,0, 1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1};
    send_packet(tb_send_data, (8*clk_period));

    tb_send_data     = '{0,1,0,1,0,1,0,0,   1,0,0,0,0,0,1,0,  0,1,0,1,0,1,0,1, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1};
    send_packet(tb_send_data, (8*clk_period));

    tb_test_case = "ACK";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    //ACK
    tb_send_data = '{0,1,0,1,0,1,0,0,  1,0,0,1,1,1,0,0};
    send_packet(tb_send_data, (8*clk_period));
    
    //NAK
    tb_test_case = "NAK";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data = '{0,1,0,1,0,1,0,0,   0,1,1,0,1,1,0,0};
    send_packet(tb_send_data, (8*clk_period));
    tb_test_case = "STALL";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    //STALL
    tb_send_data = '{0,1,0,1,0,1,0,0,   0,0,0,1,0,1,0,0};
    send_packet(tb_send_data, (8*clk_period));

    // set the PID to IN or OUT and correct address
    tb_test_case = "corect PID OUt with valid address";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data     = '{0,1,0,1,0,1,0,0,    1,0,1,1,1,1,1,0,   0,0,0,1,1,1,1,0,1,1,0,1,0,0,0,0};
    send_packet(tb_send_data, (8*clk_period));
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #(8*clk_period);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_test_case = "corect PID IN  with valid address";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data = '{0,1,0,1,0,1,0,0,   0,1,0,0,1,1,1,0,   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    send_packet(tb_send_data, (8*clk_period));
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #(8*clk_period);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

// Incorrect cases
    tb_test_case = "invalid synckey";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();

    tb_send_data = '{1,1,0,1,0,1,0,0, 0,1,1};
    send_packet(tb_send_data, (8*clk_period));


    tb_test_case = "invalid pid";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    tb_send_data = '{0,1,0,1,0,1,0,0, 1,1,1,1,1,1,1,  0,0,0,1,0,0,0};
    send_packet(tb_send_data, (8*clk_period));


    tb_test_case = "incorrect endpoint"; 
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    tb_send_data = '{0,1,0,1,0,1,0,0,    1,1,1,1,1,0,1,0,  0,0,0,0,1,1,1,1,1,1,1,1, 1,0,0,0};
    send_packet(tb_send_data, (8*clk_period));
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #(8*clk_period);


    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    //pid is OUT and address is valid.
    tb_test_case = "invalid  address following the OUT";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);
    tb_send_data     = '{0,1,0,1,0,1,0,0, 1,1,1,0,0,1,0,0, 0,1,0,1,1,1,1,0,1,0,0,0,0,0,0};
    send_packet(tb_send_data, (8*clk_period));
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #(8*clk_period);

    tb_test_case = "invalid eop";
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    tb_send_data = '{0,1,0,1,0,1,0,0, 1,0,0,0,0,0,1,0, 1,0,0,0,1};
    send_packet_incorrect_eop(tb_send_data, (8*clk_period));
    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    #(8*clk_period);

    //Correct sync, DATA, but continue write to overflow.
    tb_test_case = "write 64 bytes into buffer"; 
    tb_case_num = tb_case_num + 1;
    check_output(tb_case_num, tb_test_case);                                               

    tb_dplus_in = 1'b1;
    tb_dminus_in = 1'b0;
    reset_dut();
    tb_send_data = '{0,1,0,1,0,1,0,0, 1,0,0,0,0,0,1,0, 1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1, 
    1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1, 1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1, 0,1,0,0,1,1,0,1, 1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1,  
    0,1,0,0,1,1,0,1, 1,0,0,0,1,0,0,0, 1,1,0,0,1,0,0,1,  0,1,0,0,1,1,0,1, 0,1,0,0,1,1,0,1};
    send_packet(tb_send_data, (8*clk_period));
    #(clk_period * 8);
    reset_dut();
    $stop();
end
endmodule

    



