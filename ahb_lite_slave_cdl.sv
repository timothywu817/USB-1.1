module ahb_lite_slave_cdl (
    input logic clk,
    input logic n_rst,
    input logic [2:0] rx_packet,
    input logic rx_data_ready,
    input logic rx_transfer_active,
    input logic rx_error,
    input logic [6:0] buffer_occupancy,
    input logic tx_transfer_active,
    input logic tx_error,
    input logic [7:0] rx_data,
    output logic get_rx_data,
    output logic store_tx_data,
    output logic [7:0] tx_data,
    output logic clear,
    output logic [2:0] tx_packet,
    output logic d_mode,
    input logic hsel,
    input logic [7:0] haddr,
    input logic [1:0] hsize,
    input logic [1:0] htrans,
    input logic [2:0] hburst,
    input logic hwrite,
    input logic [31:0] hwdata,
    output logic [31:0] hrdata,
    output logic hresp,
    output logic hready
);  
    logic write;
    logic [3:0]addr;
    logic [1:0]size;
    logic [31:0]db;
    logic [31:0]n_hrdata;
    logic [31:0]n_data_buffer;
    logic [7:0] n_tx_packet;
    logic [31:0]n_db;
    logic [31:0]db1;
    logic [31:0]n_db1;
    logic n_clear;
    logic [1:0]ssize;
    typedef enum logic [3:0] {idle, load1, load2, load3, load4, done,hold, store1, store2, store3, store4} slog;
    slog state;
    slog nstate;
    always_ff @ (posedge clk, negedge n_rst) begin
        if (!n_rst) begin
            hrdata <= 32'd0;
            addr <= 4'd0;
            write <= 0;
            size <= 2'b0;
            db <= 32'b0;
            state <= idle;
            tx_packet <= 0;
            clear <= 0;
            db1 <= 32'b0;
        end
        else begin
            hrdata <= n_hrdata;
            addr <= haddr;
            //size <= ssize;
            size <= (haddr == 0 & htrans == 2) ? hsize: size;
            write <= hwrite;
            db <= n_db;
            state <= nstate;
            tx_packet <= n_tx_packet[2:0];
            clear <= n_clear;
            db1 <= n_db1;
        end
    end
    always_comb begin
        hresp = ((hwrite == 1 && (haddr == 4 || haddr == 5 || haddr == 6 || haddr == 7 || haddr == 8)) || (haddr == 9 || haddr == 10 || haddr == 11 || haddr > 13));
    end
    always_comb begin
        hready = 1;
        ssize = hsize;
        // shwdata = hwdata;
        nstate = state;
        n_db = db;
        tx_data = 0;
        store_tx_data = 0;
        get_rx_data = 0;
        case(state)
        idle:  begin
            if(hwrite == 0 && hsel == 1 && htrans == 2) begin
                if(hsize == 0) begin
                    case(haddr)
                        0: begin nstate = done; n_db [7:0] = rx_data;get_rx_data = 1; hready = 0; end
                        1: begin nstate = done; n_db [15:8] = rx_data;get_rx_data = 1;hready = 0; end
                        2: begin nstate = done; n_db [23:16] = rx_data;get_rx_data = 1;hready = 0;end
                        3: begin nstate = done; n_db [31:24] = rx_data;get_rx_data = 1;hready = 0;end
                    endcase
                end
                if(hsize == 1) begin
                    case(haddr)
                        0, 1: begin nstate = load2; n_db [7:0] = rx_data;get_rx_data = 1;hready = 0;  end
                        2, 3: begin nstate = load4; n_db [23:16] = rx_data;get_rx_data = 1;hready = 0;end
                    endcase
                end
                if(hsize == 2) begin
                    case(haddr)
                        0,1,2,3: begin nstate = load2; n_db [7:0] = rx_data;get_rx_data = 1;hready = 0;end
                    endcase
                end
            end

            if(write == 1 && hsel == 1) begin
                ssize = hsize;
                if (size == 0) begin
                    case(addr) 
                    0: nstate = store1;
                    1: nstate = store2;
                    2: nstate = store3;
                    3: nstate = store4;
                    endcase
                end
                if (size == 1) begin
                    case(addr)
                    0,1: nstate = store1;
                    2,3: nstate = store3;
                    endcase
                end
                if (size == 2) begin
                    case(addr)
                    0,1,2,3: nstate = store1;
                    endcase
                end
            end
        end
        load2: begin
            hready = 0;
            get_rx_data = 1;
            n_db[15:8] = rx_data;
            if (size == 2) begin
                nstate = load3;
            end
            else
                nstate = done;
        end
        load3: begin
            hready = 0;
            get_rx_data = 1;
            n_db[23:16] = rx_data;
            nstate = load4;
        end
        load4: begin
            hready = 0;
            get_rx_data = 1;
            n_db[31:24] = rx_data;
            nstate = done;
        end
        done: begin
            nstate = hold;
            hready = 1;
        end
        hold: begin 
            hready = 1;
            nstate = idle;
        end
        store1: begin
            hready = 0;
            store_tx_data = 1;
            tx_data = db1[7:0];
            if ((size == 1) || (size == 2)) begin
                nstate = store2;
                ssize = size;
            end
            else 
                nstate = idle;
        end
        store2: begin
            hready = 0;
            store_tx_data = 1;
            tx_data = db1[15:8];
            if (size == 2) begin
                nstate = store3;
                ssize = size;
            end
            else
                nstate = idle;
        end
        store3: begin
            hready = 0;
            store_tx_data = 1;
            tx_data = db1[23:16];
            if ((size == 1) || (size == 2)) begin
                nstate = store4;
                ssize = size;
            end
            else 
                nstate = idle;
        end
        store4: begin
            hready = 0;
            store_tx_data = 1;
            tx_data = db1[31:24];
            nstate = idle;
        end
        endcase
    end
    always_comb begin
        n_hrdata = hrdata;
        n_clear = 0;
        n_tx_packet = tx_transfer_active ? 0 : tx_packet;
        n_db1 = db1;
        if(hsel == 1) begin
            if(hwrite == 0) begin
                if (hsize == 0) begin
                            case(haddr)
                            0: n_hrdata[7:0] = db[7:0];
                            1: n_hrdata[15:8] = db[15:8];
                            2: n_hrdata[23:16] = db[23:16];
                            3: n_hrdata[31:24] = db[31:24];
                            4: begin
                                n_hrdata[0] = rx_data_ready;
                                if (rx_packet == 3'b001)
                                    n_hrdata[1] = 1;
                                else if (rx_packet == 3'b010)
                                    n_hrdata[2] = 1;
                                else if (rx_packet == 3'b110)
                                    n_hrdata[3] = 1;
                                else if (rx_packet == 3'b111)
                                    n_hrdata[4] = 1;
                            end
                            5: begin
                                n_hrdata[8] = rx_transfer_active;
                                n_hrdata[9] = tx_transfer_active;
                            end
                            6: n_hrdata[0] = rx_error;
                            7: n_hrdata[8] = tx_error;
                            8: n_hrdata = buffer_occupancy;
                            12: n_hrdata = tx_packet;
                            13: n_hrdata = clear;
                            endcase
                        end
                else if (hsize == 1) begin
                            case(haddr)
                            0,1: n_hrdata[15:0] = db[15:0];
                            2,3: n_hrdata[31:16] = db[31:16];
                            4,5:begin
                                n_hrdata[0] = rx_data_ready;
                                if (rx_packet == 3'b001)
                                    n_hrdata[1] = 1;
                                else if (rx_packet == 3'b010)
                                    n_hrdata[2] = 1;
                                else if (rx_packet == 3'b110)
                                    n_hrdata[3] = 1;
                                else if (rx_packet == 3'b111)
                                    n_hrdata[4] = 1;
                                n_hrdata[8] = rx_transfer_active;
                                n_hrdata[9] = tx_transfer_active;
                            end
                            6, 7: n_hrdata = {23'b0, tx_error, 7'b0, rx_error};
                            8: n_hrdata = buffer_occupancy;
                            12,13: n_hrdata = {23'b0, clear, 5'b0, tx_packet};
                            endcase
                        end
                else if (hsize == 2) begin
                            case(haddr)
                            0,1,2,3: n_hrdata[31:0] = db[31:0];
                            4,5,6,7: begin
                                n_hrdata[15:0] = {6'b0, tx_transfer_active, rx_transfer_active, 3'b0, rx_packet == 3'b111, rx_packet == 3'b110, rx_packet == 3'b010, rx_packet == 3'b001, rx_data_ready};
                                n_hrdata[31:16] = {7'b0, tx_error, 7'b0, rx_error};
                            end
                            8: n_hrdata = buffer_occupancy;
                            12: n_hrdata = {23'b0, clear, 5'b0, tx_packet};
                            13: n_hrdata = {23'b0, clear, 5'b0, tx_packet};
                            endcase
                        end
            end
            if (write == 1) begin
                if (size == 0) begin    
                            case(addr)
                            0: n_db1[7:0] = hwdata[7:0];
                            1: n_db1[15:8] = hwdata[15:8];
                            2: n_db1[23:16] = hwdata[23:16];
                            3: n_db1[31:24] = hwdata[31:24];
                            12: begin
                                if (hwdata <= 4) begin
                                    n_tx_packet = hwdata[7:0];
                                end
                            end
                            13: n_clear = hwdata[0];
                            endcase
                    end
                else if (size == 1) begin
                            case(addr)
                            0: n_db1[15:0] = hwdata[15:0];
                            1: n_db1[15:0] = hwdata[15:0];
                            2: n_db1[31:16] = hwdata[31:16];
                            3: n_db1[31:16] = hwdata[31:16];
                            12: begin
                                if (hwdata <= 4) begin
                                    n_tx_packet = hwdata[7:0];
                                end
                            end
                            13: n_clear = hwdata[0];
                            endcase
                end
                else if (size == 2) begin
                            case(addr)
                            0: n_db1[31:0] = hwdata[31:0];
                            1: n_db1[31:0] = hwdata[31:0];
                            2: n_db1[31:0] = hwdata[31:0];
                            3: n_db1[31:0] = hwdata[31:0];
                            12: begin
                                if (hwdata <= 4) begin
                                    n_tx_packet = hwdata[7:0];
                                end
                            end
                            13: n_clear = hwdata[0];
                            endcase
                end
            end
        end
    end
    always_comb begin
        d_mode = 0;
        if (tx_transfer_active)
            d_mode = 1;
    end
endmodule