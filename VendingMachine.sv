	module VendingMachine(
		 input logic clk,
		 input logic reset_n,
		 input logic nickel,
		 input logic dime,
		 input logic quarter,
		 input logic refund,
		 output logic vend,
		 output logic nickel_out,
		 output logic dime_out,
		 output logic quarter_out
	);

		 // These are used to slow down the board clock to 1 Hz
		 logic [25:0] tick;
		 logic tick_clear_n;
		 logic tick_carry;
		 logic clk_1Hz;

		 Counter #(.N(26)) tick_counter (
			  .clock(clk),
			  .clear_input_n(tick_clear_n),
			  .enable_n(1'b0),
			  .reset_n(reset_n),
			  .addBy(26'd1),
			  .count(tick)
		 );
		 assign tick_carry = (tick == 26'd49_999_999);
		 assign tick_clear_n = ~tick_carry;
		 assign clk_1Hz = ~tick_carry; // 1 hz

		 
		 
		 

		 // The balance is stored in nickels, so 20 means $1.00
		 logic [7:0] balance;
		 logic balance_clear_n;
		 logic [7:0] balance_addby;

		 Counter #(.N(8)) balance_counter (
			  .clock(clk_1Hz),
			  .clear_input_n(balance_clear_n),
			  .enable_n(1'b0),
			  .reset_n(reset_n),
			  .addBy(balance_addby),
			  .count(balance)
		 );

		 
		 
		 // THIS IS THE STATE
		 // 0 means ACCEPTING coins, 1 means RETURNING change
		 logic returning_change;
		 
		 always_ff @(posedge clk_1Hz or negedge reset_n) begin
			  if (!reset_n)
					returning_change <= 1'b0; // 0: Start in ACCEPTING mode
			  else
					//todo: switch modes when refunding or returning change
		 end

		 
		 
		 
		 
		 
		 // accept coins ONLY when we are not returning change
		 always_comb begin
			  balance_addby = 8'd0;

			  if (!returning_change) begin
					if (quarter)
						 balance_addby = 8'd5;
					else if (dime)
						 balance_addby = 8'd2;
					else if (nickel)
						 balance_addby = 8'd1;
			  end
		 end

		 

		 
		 
		 
		 //todo: Add logic to control returning_change

	endmodule


	module Counter #(
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
			  if (!enable_n)
					count_next = count + addBy;
			  else
					count_next = count;
		 end

		 RegisterNBit #(.N(N)) count_register (
			  .clock(clock),
			  .clear_n(clear_input_n),
			  .reset_n(reset_n),
			  .d(count_next),
			  .q(count)
		 );

	endmodule







	module RegisterNBit #(
		 parameter int N = 4
	)(
		 input logic clock,
		 input logic clear_n,
		 input logic reset_n,
		 input logic [N-1:0] d,
		 output logic [N-1:0] q
	);

		 // Update the value on the rising clock edge
		 always_ff @(posedge clock or negedge reset_n) begin
			  if (!reset_n) begin
					q <= '0;
			  end else if (!clear_n) begin
					q <= '0;
			  end else begin
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
					4'h1: segments = 7'b111_1001;
					4'h2: segments = 7'b010_0100;
					4'h3: segments = 7'b011_0000;
					//todo
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