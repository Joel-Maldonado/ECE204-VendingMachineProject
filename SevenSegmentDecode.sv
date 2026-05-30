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

