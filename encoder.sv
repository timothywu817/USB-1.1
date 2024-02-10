// $Id: $
// File name:   encoder.sv
// Created:     4/7/2023
// Author:      Michael Suo
// Lab Section: 337-17
// Version:     1.0  Initial Design Entry
// Description: .

module encoder (
    input logic clk,
    input logic n_rst,
    input logic enable,
    input logic shift,
    input logic eop,
    input logic d_orig,
    output logic d_plus,
    output logic d_minus
);

logic next_d_plus;

always_ff @ (posedge clk, negedge n_rst) begin
    if (!n_rst) begin
        d_plus <= 1'b1;
        d_minus <= 1'b0;
    end
    else if (eop) begin
        d_plus <= 1'b0;
        d_minus <= 1'b0;
    end
    else begin
        d_plus <= next_d_plus;
        d_minus <= !next_d_plus;
    end
end

always_comb begin
    if (enable) begin
        next_d_plus = d_plus;
        if (shift) begin
            if (d_orig) begin
                next_d_plus = d_plus;
            end
            else begin
                next_d_plus = !d_plus;
            end
        end
    end
    else begin
        next_d_plus = 1'b1;
    end
end

// logic next_d_plus, next_d_minus;

// always_ff @ (posedge clk, negedge n_rst) begin
//     if (!n_rst) begin
//         d_plus <= 1'b1;
//         d_minus <= 1'b0;
//     end
//     else if (eop) begin
//         d_plus <= 1'b0;
//         d_minus <= 1'b0;
//     end
//     else begin
//         d_plus <= next_d_plus;
//         d_minus <= next_d_minus;
//     end
// end

// always_comb begin
//     if (enable) begin
//         next_d_plus = d_plus;
//         next_d_minus = d_minus;
//         if (shift) begin
//             if (d_orig) begin
//                 next_d_plus = d_plus;
//                 next_d_minus = d_minus;
//             end
//             else begin
//                 next_d_plus = !d_plus;
//                 next_d_minus = !d_minus;
//             end
//         end
//     end
//     else begin
//         next_d_plus = 1'b1;
//         next_d_minus = 1'b0;
//     end
// end

endmodule
