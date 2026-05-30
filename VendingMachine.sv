module VendingMachine(
    input  logic clk,
    input  logic reset,
    input  logic nickel,
    input  logic dime,
    input  logic quarter,
    input  logic refund,
    output logic vend,
    output logic nickel_out,
    output logic dime_out,
    output logic quarter_out
);

module counter #(
    parameter N = 4
)(
    input  logic clk,
    input  logic reset_n, 
    input  logic clear_n, 
    input  logic enable_n,
    input  logic [N-1:0] addBy,
    output logic [N-1:0] count
);
    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n == 1'b0) begin
            count <= 0; 
        end else if (clear_n == 1'b0) begin
            count <= 0; 
        end else if (enable_n == 1'b0) begin
            count <= count + addBy;
        end
    end
endmodule

module SevenSegmentDecode(
    input logic [3:0] digit,
	 output logic [6:0] segments
);

always_comb begin
    case (digit)
        //                   gfe_dcba
        4'h0: segments = 7'b100_0000;
        /* [2] TODO */
        4'h1: segments = 7'b111_1001;
        4'h2: segments = 7'b010_0100;
        4'h3: segments = 7'b011_0000;
        4'h4: segments = 7'b001_1001;
        4'h5: segments = 7'b001_0010;
        4'h6: segments = 7'b000_0010;
        4'h7: segments = 7'b111_1000;
        4'h8: segments = 7'b000_0000;
        4'h9: segments = 7'b001_0000;
        4'hA: segments = 7'b000_1000;
        4'hB: segments = 7'b000_0011; // lowercase b
        4'hC: segments = 7'b100_0110; // capital C
        4'hD: segments = 7'b010_0001; // lowercase d
        4'hE: segments = 7'b000_0110;
        4'hF: segments = 7'b000_1110;
        default: segments = 7'bxxx_xxxx;
    endcase
end

endmodule

