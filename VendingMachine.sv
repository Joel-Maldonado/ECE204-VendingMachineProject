module VendingMachine(
    input  logic clk,
    input  logic reset_n,
    input  logic nickel,
    input  logic dime,
    input  logic quarter,
    input  logic refund,
    output logic vend,
    output logic nickel_out,
    output logic dime_out,
    output logic quarter_out
);
// Main clock loop

// Tick counter

	logic [25:0] tick,
	logic clk;
	logic tick_enable_n;

	Counter #(.N(26)) tick_counter (
		.clock(clk),
		.clear_input_n(tick_clear_n),
		.enable_n(1'd0),
		.reset_n(reset_n),
		.addBy(26'd1),
		.count(tick)
	);
	
	logic tick_carry;
	
	assign tick_carry = (tick == 26'd49_999_999);
	
	// Extra debug comparators
	//assign tick_carry = (tick == 26'd4);
	//assign tick_carry = (tick == 26'd50_000);
	
	
	// Use this as the clock signal
	assign clk_Hz = ~tick_carry;









// Module Definitions
module Counter#(
    parameter int N = 4
	)(
    input logic clock,
    input logic clear_input_n,
	 input logic enable_n,
	 input logic reset_n,
    input logic [N-1:0] addBy,
    output logic [N-1:0] count
);

	logic [N-1:0] count_next;
	always_comb begin
		if(!enable_n)
			count_next = count + addBy;
		else
			count_next = count;
		end
	
	RegisterNBit #(.N(N)) dut(
        .clock(clock),
        .clear_n(clear_input_n),
		  .reset_n(reset_n),
		  .d(count_next),
		  .q(count)
    );

endmodule

module RegisterNBit#(
    parameter int N = 4
)(
    input logic clock,
    input logic clear_n,
	 input logic reset_n,
    input logic [N-1:0] d,
    output logic [N-1:0] q
);

	// Update `q` only on the rising edge of `clock` or the falling
	// edge of `clear_n`
	always_ff @(posedge clock or negedge reset_n) begin
			
		if (reset_n == 1'b0) begin
			// Set `q` to 0 when `reset_n` is low (active)
			q <= '0;
			
		end else if (clear_n == 1'b0) begin
			// Set `q` to 0 when `clear_n` is low (active)
			q <= '0;
			
		end else begin
			// Set `q` to `d` on `clock` rising edge
			q <= d;
			
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

