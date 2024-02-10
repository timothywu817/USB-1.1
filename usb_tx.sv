// $Id: $
// File name:   usb_tx.sv
// Created:     4/5/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .


module usb_tx (
    input logic clk,
    input logic n_rst,
    input logic [2:0] tx_packet,
    input logic [7:0] tx_packet_data,
    input logic [6:0] buffer_occupancy,
    output logic tx_transfer_active,
    output logic tx_error,
    output logic get_tx_packet_data,
    output logic dplus_out,
    output logic dminus_out
);

logic load_enable, enable_timer, enable_encoder, shift_encoder, d_orig, eop, next_eop, packet_done, next_load_enable, next_load_enable_reg, get_packet;

logic [2:0] tx_packet_reg, tx_packet_sync;

logic [7:0] parallel_data;

encoder DUT1 (
    .clk(clk), .n_rst(n_rst),
    // .eop(eop),
    .eop(next_eop),
    .enable(enable_encoder),
    .shift(shift_encoder),
    .d_orig(d_orig),
    .d_plus(dplus_out),
    .d_minus(dminus_out)
    );

flex_pts_sr_tx #(.NUM_BITS(8), .SHIFT_MSB(0)) 
    DUT2 (
    .clk(clk), .n_rst(n_rst),
    .load_enable(load_enable || packet_done),
    .shift_enable(shift_strobe),
    .parallel_in(parallel_data),
    .serial_out(d_orig)
    );

timer_tx DUT3 (
    .clk(clk), .n_rst(n_rst),
	.enable_timer(enable_timer),
	.shift_strobe(shift_strobe),
    .packet_done(packet_done)
    );

// SYNC
// ID
// PACKET

typedef enum logic [3:0] {IDLE, SYNC, ID, DATA, CRC1, CRC2, EOP1, EOP2, WAIT, EEOP1, EEOP2, EWAIT, EIDLE} state_type;

state_type state, next_state, packet_data;

always_ff @ (posedge clk, negedge n_rst) begin
    if (!n_rst) begin
	    next_load_enable_reg <= 1'b0;
	    shift_encoder <= 1'b0;
        tx_packet_reg <= 3'b0;
        state <= IDLE;
	    // eop <= 1'b0;
    end
    else begin
	    next_load_enable_reg <= next_load_enable;
	    shift_encoder <= (shift_strobe || load_enable);
        tx_packet_reg <= tx_packet_sync;
        state <= next_state;
	    // eop <= next_eop;

    end
end

assign next_load_enable = tx_packet == 3'd1 || tx_packet == 3'd2 || tx_packet == 3'd3 || tx_packet == 3'd4;
assign load_enable = next_load_enable && ~next_load_enable_reg && ~tx_transfer_active;
assign tx_packet_sync = tx_transfer_active ? (tx_packet_reg) : (tx_packet);
assign get_tx_packet_data = packet_done && get_packet;

always_comb begin : fsm
    next_state = state;
    case(state)
    IDLE: begin
        if (tx_packet != 0) begin
            next_state = SYNC;
        end
    end
    SYNC: begin
        if (packet_done) begin
            next_state = ID;
        end
    end
    ID: begin
	    if (packet_done) begin
            if (tx_packet_sync == 3'd1) begin
                if (buffer_occupancy != 7'b0) begin
                    next_state = DATA;
                end
                else begin
                    next_state = EEOP1;
                end
            end
            else begin
                next_state = EOP1;
            end
        end
    end
    DATA: begin
        if (packet_done && buffer_occupancy == 0) begin
            next_state = CRC1;
        end
    end
    CRC1: begin
        if (packet_done) begin
            next_state = CRC2;
        end
    end
    CRC2: begin
        if (packet_done) begin
            next_state = EOP1;
        end
    end
    EOP1: begin
        if (shift_strobe) begin
            next_state = EOP2;
        end
    end
    EOP2: begin
        if (shift_strobe) begin
            // next_state = WAIT;
            next_state = IDLE;
        end
    end
    // WAIT: begin
    //     next_state = IDLE;
    // end
    EEOP1: begin
        if (shift_strobe) begin
            next_state = EOP2;
        end
    end
    EEOP2: begin
        if (shift_strobe) begin
            // next_state = EWAIT;
            next_state = EIDLE;
        end
    end
    // EWAIT: begin
    //     next_state = EIDLE;
    // end
    EIDLE: begin
        if (tx_packet_sync != 0) begin
            next_state = SYNC;
        end
    end
    endcase
end

always_comb begin : signal_logic
    packet_data = IDLE;
    get_packet = 1'b0;
    tx_transfer_active = 1'b1;
    enable_encoder = 1'b1;
    enable_timer = 1'b1;
    tx_error = 1'b0;
    next_eop = 1'b0;
    
    case(state)
    IDLE: begin
        packet_data = SYNC;
        tx_transfer_active = 1'b0;
        enable_encoder = 1'b0;
        enable_timer = 1'b0;
    end
    SYNC: begin
        packet_data = ID;
    end
    ID: begin
        packet_data = DATA;
        get_packet = tx_packet_sync == 3'd1;
    end
    DATA: begin
        if(buffer_occupancy == 7'd0) begin
            packet_data = CRC1;
            get_packet = 1'b0;
        end
        else begin
            packet_data = DATA;
            get_packet = 1'b1;
        end
    end
    CRC1: begin
        packet_data = CRC2;
    end
    CRC2: begin
    end
    EOP1: begin
        next_eop = 1'b1;
    end
    EOP2: begin
        next_eop = 1'b1;
    end
    // WAIT: begin
    //     enable_encoder = 1'b0;
    //     enable_timer = 1'b0;
    // end
    EEOP1: begin
        tx_error = 1'b1;
        next_eop = 1'b1;
    end
    EEOP2: begin
        tx_error = 1'b1;
        next_eop = 1'b1;
    end
    // EWAIT: begin
    //     enable_encoder = 1'b0;
    //     enable_timer = 1'b0;
    //     tx_error = 1'b1;
    // end
    EIDLE: begin
        packet_data = SYNC;
        tx_transfer_active = 1'b0;
        enable_encoder = 1'b0;
        enable_timer = 1'b0;
        tx_error = 1'b1;
    end
    endcase
end

always_comb begin : parallel_data_logic
    parallel_data = 8'b11111111;
    if (packet_data == SYNC) begin
        parallel_data = 8'b10000000;
    end
    else if (packet_data == ID) begin
        case (tx_packet_sync)
        3'd1: parallel_data = 8'b11000011;
        3'd2: parallel_data = 8'b11010010;
        3'd3: parallel_data = 8'b01011010;
        3'd4: parallel_data = 8'b00011110;
        endcase
    end
    else if (packet_data == DATA) begin
        parallel_data = tx_packet_data;
    end
    else if(packet_data == CRC1) begin
        parallel_data = 8'b10011111;
    end
    else if(packet_data == CRC2) begin
        parallel_data = 8'b00100010;
    end
end

endmodule
