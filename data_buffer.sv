// $Id: $
// File name:   data_buffer.sv
// Created:     4/5/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .

module data_buffer (
    input logic clk,
    input logic n_rst,
    input logic get_rx_data,
    input logic store_tx_data,
    input logic [7:0] tx_data,
    input logic clear,
    input logic get_tx_packet_data,
    input logic [7:0] rx_packet_data,
    input logic store_rx_packet_data,
    input logic flush,
    output logic [6:0] buffer_occupancy,
    output logic [7:0] rx_data,
    output logic [7:0] tx_packet_data
);
logic [63:0][7:0]fifo_storage;
logic [63:0][7:0] nxt_fifo_storage;
logic [6:0] nxt_occupancy;
logic [5:0] w_addr, r_addr, nxt_w_addr, nxt_r_addr;
always_ff@(posedge clk, negedge n_rst) begin
    if(n_rst == 0) begin
        fifo_storage <= 0;
        buffer_occupancy <= 7'b0;
        w_addr <= 6'b0;
        r_addr <= 6'b0;
    end
    else begin
        fifo_storage <= nxt_fifo_storage;
        buffer_occupancy <= nxt_occupancy;
        w_addr <= nxt_w_addr;
        r_addr <= nxt_r_addr;
    end
end

always_comb begin
    nxt_occupancy = buffer_occupancy;
    if(store_rx_packet_data || store_tx_data)begin
        if(nxt_occupancy != 7'd64) begin
            nxt_occupancy = nxt_occupancy + 7'd1;
        end
        else begin
            nxt_occupancy = buffer_occupancy;
        end
    end
    else if(get_rx_data || get_tx_packet_data) begin
        if(nxt_occupancy != 7'd0) begin
            nxt_occupancy = nxt_occupancy - 7'd1;
        end
        else begin
            nxt_occupancy = buffer_occupancy;
        end
        
    end
    else if(flush || clear) begin
        nxt_occupancy = 7'd0;
    end
end

always_comb begin
    nxt_fifo_storage = fifo_storage;
    rx_data = 8'b0;
    tx_packet_data = 8'b0;
    nxt_w_addr = w_addr;
    nxt_r_addr = r_addr;
    if(store_rx_packet_data)begin
        if(nxt_occupancy != 7'd64) begin
            if(nxt_w_addr != 7'd63)begin
                nxt_fifo_storage[nxt_w_addr][7:0] = rx_packet_data[7:0];
                nxt_w_addr = nxt_w_addr + 7'd1;
                // nxt_occupancy = nxt_occupancy + 7'd1;
            end
            else begin
                nxt_w_addr = 6'd0;
                    nxt_fifo_storage[nxt_w_addr][7:0] = rx_packet_data[7:0];
                    nxt_w_addr = nxt_w_addr + 6'd1;
                    // nxt_occupancy = nxt_occupancy + 7'd1;
            end
        end
    end
    else if(store_tx_data)begin
       if(nxt_occupancy != 7'd64) begin
            if(nxt_w_addr != 7'd63)begin
                nxt_fifo_storage[nxt_w_addr][7:0] = tx_data[7:0];
                nxt_w_addr = nxt_w_addr + 7'd1;
                // nxt_occupancy = nxt_occupancy + 7'd1;
            end
            else begin
                nxt_w_addr = 6'd0;
                if(nxt_r_addr != nxt_w_addr)begin
                    nxt_fifo_storage[0][7:0] = tx_data[7:0];
                    nxt_w_addr = 6'd1;
                    // nxt_occupancy = nxt_occupancy + 7'd1;
                end
            end
        end
        // else if(nxt_r_addr == nxt_w_addr)begin
        //     nxt_occupancy = buffer_occupancy;
        //     nxt_w_addr = w_addr;
        // end
    end
    else if(get_tx_packet_data) begin
        if(nxt_occupancy != 6'd0) begin
            if(nxt_r_addr != 6'd63) begin
                tx_packet_data[7:0] = nxt_fifo_storage[nxt_r_addr][7:0];
                nxt_r_addr = nxt_r_addr + 7'd1;
                // nxt_occupancy = nxt_occupancy - 7'd1;
            end
            else begin
                nxt_r_addr = 6'd0;
                if(nxt_r_addr != nxt_w_addr)begin
                    tx_packet_data[7:0] = nxt_fifo_storage[nxt_r_addr][7:0];
                    nxt_r_addr = nxt_r_addr + 7'd1;
                    // nxt_occupancy = nxt_occupancy - 7'd1;
                end
            end
        end
        // else begin
        //     nxt_occupancy = buffer_occupancy;
        //     nxt_r_addr = r_addr;
        // end
    end
    else if(get_rx_data)begin
        if(nxt_occupancy != 6'd0) begin
            if(nxt_r_addr != nxt_w_addr) begin
                if(nxt_r_addr != 6'd63) begin
                    rx_data[7:0] = nxt_fifo_storage[nxt_r_addr][7:0];
                    nxt_r_addr = nxt_r_addr + 6'd1;
                    // nxt_occupancy = nxt_occupancy - 7'd1;
                end
                else begin
                    nxt_r_addr = 6'd0;
                        rx_data[7:0] = nxt_fifo_storage[nxt_r_addr][7:0];
                        nxt_r_addr = nxt_r_addr + 6'd1;
                        // nxt_occupancy = nxt_occupancy - 7'd1;
                end
            end
        end
        // else begin
        //     nxt_fifo_storage = fifo_storage;
        //     nxt_occupancy = buffer_occupancy;
        //     nxt_r_addr = r_addr;
        // end
    end
    else if(flush || clear) begin
        nxt_fifo_storage[63:0] = 8'b0;
        nxt_r_addr = 6'b0;
        nxt_w_addr = 6'b0;
    end

end
endmodule

