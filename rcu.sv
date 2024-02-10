// $Id: $
// File name:   rcu.sv
// Created:     4/6/2023
// Author:      Tingyu Wu
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .
module rcu(
    input logic clk,
    input logic n_rst,
    input logic shift_enable,
    input logic [7:0] rcv_data,
    input logic d_edge,
    input logic eop,
    input logic address_comp,
    input logic byte_received,
    input logic [6:0] buffer_occupancy,
    input logic [15:0] address,
    input logic eop_1_comp,
    input logic eop_comp,
    output logic store_rx_packet_data,
    output logic byte_en,
    output logic flush,
    output logic addr_en,
    output logic rcving,
    output logic r_error,
    output logic [2:0] pid,
    output logic rx_data_ready,
    output logic eop_en
);
logic [2:0] nxt_pid;
typedef enum {idle, token, match, match_err, eop1, eop2,
DATA, IN,OUT,store,eop_error,DATA_wait,sync_wait,token_wait,
ACK, NAK, STALL,error,pack,EOP, EOP_wait} state_type;
state_type nxt_state;
state_type state;
always_ff @ (posedge clk, negedge n_rst) begin
    if(n_rst == 0) begin
        state <= idle;
        pid <= '0;
    end
    else begin
        state <= nxt_state;
        pid <= nxt_pid;
    end
end

always_comb begin
    nxt_state = state;
    store_rx_packet_data = 0;
    r_error = 0;
    rcving = 1;
    flush = 0;
    addr_en = 0;
    byte_en = 0;
    nxt_pid = 0;
    rx_data_ready = 0;
    eop_en = 0;
    case(state)
        idle: begin
            rcving = 0;
            if(d_edge) begin
                nxt_state = sync_wait;
                // nxt_state = match;
            end
            else begin
                nxt_state = idle;
            end
        end
        // match: begin
        //     if (byte_received) begin
        //         if  (rcv_data == 8'b00000001) begin
        //             nxt_state = token_wait;
        //         end else begin
        //             nxt_state = match_err;
        //         end
        //     end
        // end
        sync_wait: begin
            rcving = 1;
            flush = 1;
            nxt_pid = 0;
            if(eop) begin
                nxt_state = error;
            end
            if(byte_received) begin
                nxt_state = match;
            end
        end
        match: begin
            rcving = 1;
            if(rcv_data == 8'b00000001) begin
                nxt_state = token;
            end
            else if(rcv_data != 8'b00000001)begin
                r_error = 1;
                nxt_state = match_err;
            end
        end
        token_wait: begin
            rcving = 1;
            if(eop) begin
                nxt_state = error;
            end
            else begin
                nxt_state = token;
            end
        end
        token: begin
            rcving = 1;
            byte_en = 1;
            if(rcv_data == 8'b00011110) begin
                nxt_state = OUT;
                nxt_pid = 3'b010;
            end
            else if(rcv_data == 8'b10010110) begin
                nxt_state = IN;
                nxt_pid = 3'b001;
            end
            else if(rcv_data == 8'b00111100) begin//DATA0
                nxt_state = DATA;
                nxt_pid = 3'b011;
            end
            else if(rcv_data == 8'b10110100) begin//DATA1
                nxt_state = DATA;
                nxt_pid = 3'b100;
            end
            else if(rcv_data == 8'b00101101) begin
                nxt_state = ACK;
                nxt_pid = 3'b101;
            end
            else if(rcv_data == 8'b10100101) begin
                nxt_state = NAK;
                nxt_pid = 3'b111;
            end
            else if(rcv_data == 8'b11100001) begin
                nxt_state = STALL;
                nxt_pid = 3'b000;
            end
            else if(eop && !byte_received)begin
                r_error = 1;
                nxt_state = error;
            end
            else if(eop)begin
                
                nxt_state = eop1;
            end
        end
        match_err: begin
            rcving = 1;
            r_error = 1;
            if(eop) begin
                nxt_state = eop1;
            end
            else begin
                nxt_state = match_err;
            end
        end
       
        ACK, NAK, STALL: begin
            nxt_state = eop1;
        end
        DATA: begin
            rcving = 1;
            if(eop) begin
                nxt_state = error;
            end
            else if(buffer_occupancy == 7'd64) begin
                nxt_state = error;
            end
            else if(byte_received)begin
                nxt_state = store;
            end
        end
        IN, OUT: begin
            rcving = 1;
            addr_en = 1;
            if(eop) begin
                nxt_state = error;
            end
            if(address_comp) begin
                nxt_state = eop1;
            end
        end
        store: begin
            store_rx_packet_data = 1;
            rcving = 1;
            byte_en = 1;
            if(eop) begin
                nxt_state = eop1;
            end
            else if(buffer_occupancy == 7'd64) begin
                nxt_state = error;
            end
            else begin
                nxt_state = DATA_wait;
            end
        end
        DATA_wait: begin
            rcving = 1;
            if(byte_received) begin
                nxt_state = store;
            end
            else if(eop)begin
                nxt_state = eop1;
            end
        end
        eop1: begin
            eop_en = 1;
            rcving = 1;
            r_error = 0;
            if(eop_1_comp == 1)begin
                if (eop == 1) begin
                    nxt_state = eop2;
                end
                else begin
                    nxt_state = eop_error;
                end
            end
        end
        eop2: begin
            eop_en = 1;
            rcving = 1;
            r_error = 0;
            if(eop_comp == 1) begin
                if(eop) begin
                    nxt_state = pack;
                end
                else if(eop_comp != 1)begin
                    nxt_state = eop_error;
                end
            end
        end
        pack: begin
            rcving = 1;
            rx_data_ready = 1;
            nxt_state = idle;
        end
        eop_error: begin
            r_error = 1;
            rcving = 0;
            if(!d_edge) begin
                nxt_state = eop_error;
            end
            else begin
                nxt_state = match;
            end
        end
        error: begin
            r_error = 1;
            rcving = 0;
            flush = 1;
            if(d_edge) begin
                nxt_state = match;
            end
            else begin
                nxt_state = error;
            end
        end

    endcase
end
endmodule
