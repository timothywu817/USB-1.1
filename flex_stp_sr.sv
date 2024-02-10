module flex_stp_sr#(parameter NUM_BITS = 4, parameter SHIFT_MSB = 1)
                    (input logic clk,
                    input logic n_rst,
                    input logic shift_enable,
                    input logic serial_in,
                    output logic [NUM_BITS-1:0] parallel_out);
    logic [NUM_BITS-1:0] out;
    
    always_ff @(posedge clk, negedge n_rst) begin
        if(n_rst == 0) begin
            parallel_out <= '1;
        end
        else begin
            parallel_out <= out;
        end
    end 
    always_comb begin
        if(SHIFT_MSB)begin
            if(shift_enable == 1) begin
                out[0] = serial_in;
                out[NUM_BITS-1:1] = parallel_out[NUM_BITS-2:0];
            end
            else begin
                out = parallel_out;
            end
        end
        else begin
            if(shift_enable == 1) begin
                out[NUM_BITS-1] = serial_in;
                out[NUM_BITS-2:0] = parallel_out[NUM_BITS-1:1];
            end
            else begin
                out = parallel_out;
            end
            
        end
            
    end
endmodule
