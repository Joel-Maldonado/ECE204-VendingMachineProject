module VendingMachine(
	// 50MHZ clock
	input logic clk,
	
	// Button inputs for reset and refund
	input logic reset_n,
	input logic refund_n,
	
	// Switch inputs for coins
	input logic nickel,
	input logic dime,
	input logic quarter,

	// Switch inputs for different items
	// $1.00 is the default
	input logic item_1, //$0.50
	input logic item_2, //$2.00
	input logic item_3, //$2.50
	
	// LED outputs for vending, and coin returns
	output logic vend,
	output logic nickel_out,
	output logic dime_out,
	output logic quarter_out,
	
	// Display outputs
	output logic [6:0] Seg0,
	output logic [6:0] Seg1,
	output logic [6:0] Seg2,
	output logic [6:0] Seg3,
	output logic [6:0] Seg4,
	output logic [6:0] Seg5,
	output logic dot

);
//-------------------------------------------------------------
// Clock Divider
//-------------------------------------------------------------

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
	 assign clk_1Hz = ~tick_carry; // now in 1 hz

	 
//-------------------------------------------------------------
// Balance Counter
//-------------------------------------------------------------
 
	// The balance is stored in nickels, so 20 means $1.00
	logic signed [7:0] balance;
	logic signed [7:0] balance_addby;
	logic [7:0] cost;
	
	logic balance_clear_n = 1'b1;

	Counter #(.N(8)) balance_counter (
		  .clock(clk_1Hz),
		  .clear_input_n(balance_clear_n),
		  .enable_n(1'b0),
		  .reset_n(reset_n),
		  .addBy(balance_addby),
		  .count(balance)
	 );
	 

//-------------------------------------------------------------
// State Transistions
//-------------------------------------------------------------
	  
	// State enum
	typedef enum logic [1:0] {
		INPUT,
		VEND,
		REFUND
	} state_t;
	
	// 
	state_t current_state, next_state;

	// On clock edge or reset press, change states
	always_ff @(posedge clk_1Hz or negedge reset_n) begin
		if (!reset_n)
			current_state <= INPUT;
		else
			current_state <= next_state;
		end

	// Next-state logic
	always_comb begin
		// If nothing, set next state to current state
		next_state = current_state;
		
		// Case statement
		unique case (current_state)
			
			// If in INPUT state and balance reaches cost, then switch to VEND state
			// Otherwise check if refund button is hit, and switch to REFUND state
			INPUT: begin
				if (balance >= cost)
					next_state = VEND;
				else if (!refund_n)
					next_state = REFUND;
			end

			// Set state to refund
			VEND: begin
				next_state = REFUND;
			end
			
			// When balance reaches 0, switch to INPUT state
			REFUND: begin
				if (balance == 0)
					next_state = INPUT;
			end
		endcase
	end

	
//-------------------------------------------------------------
// State Logic
//-------------------------------------------------------------

	// Set balance_addby based state
	always_comb begin
	
		// Defualt values
		balance_addby = 0; 
		nickel_out = 1'b0;
		dime_out = 1'b0;
		quarter_out = 1'b0;
		
		unique case (current_state)
			
			// If in INPUT state, then set add_by based on coin inputs
			INPUT: begin
				if (quarter)
					balance_addby = 8'd5;
				else if (dime)
					balance_addby = 8'd2;
				else if (nickel)
					balance_addby = 8'd1;
				end
			
			// If in VEND state, then set add_by based on cost of item
			VEND: begin
				balance_addby = -cost;
			end
			
			// If in REFUND state, then set add_by based on remaining change
			REFUND: begin
				// If able to refund quarter, subtract and return quarter
				if (balance >= 5) begin
					balance_addby = -8'd5;
					quarter_out = 1'b1;
				end
				
				// If able to refund dime, subtract and return dime
				else if (balance >= 2) begin
					balance_addby = -8'd2;
					dime_out = 1'b1;
				end
				
				// If able to refund nickle, subtract and return nickle
				else if (balance >= 1) begin
					balance_addby = -8'sd1;
					nickel_out = 1'b1;
				end
				
				// If balance equals 0, set add_by to 0
				else
					balance_addby = 0;
			end

		endcase
	end


//-------------------------------------------------------------
// Cost Logic
//-------------------------------------------------------------

	always_comb begin
		// Set cost to $1 if no switch is on
		cost = 8'd20; //$1.00

		// Select cost based on switches
		if (item_1)
			cost = 8'd10;     // $0.50
		else if (item_2)
			cost = 8'd40;     // $2.00
		else if (item_3)
			cost = 8'd50;    // $2.50
	end

	
//-------------------------------------------------------------
// Display Logic
//-------------------------------------------------------------

	// If in VEND state, set vend LED to on
	assign vend = (current_state == VEND);
	
	// Display inputs
	logic [4:0] digit0, digit1, digit2, digit3, digit4, digit5;

	// Set all displays to 0 as default
	always_comb begin
	digit0 = 5'd10;
	digit1 = 5'd10;
	digit2 = 5'd10;
	digit3 = 5'd10;
	digit4 = 5'd10;
	digit5 = 5'd10;
	dot = 1'd0;

	case (current_state)
		
		// When in INPUT state, diplay: "BAL<balance>"
		INPUT: begin
			digit0 = 5'd12; // B
			digit1 = 5'd11; // A
			digit2 = 5'd13; // L
			digit3 = (balance * 5) / 100;
			digit4 = ((balance * 5) / 10) % 10;
			digit5 = (balance * 5) % 10;
			dot = 1'd1;
		end

		// When in INPUT state, diplay: "REF<balance>"
		REFUND: begin
			digit0 = 5'd14; // R
			digit1 = 5'd15; // E
			digit2 = 5'd16; // F
			digit3 = (balance * 5) / 100;
			digit4 = ((balance * 5) / 10) % 10;
			digit5 = (balance * 5) % 10;
			dot = 1'd1;
		end

		// When in VEND state, diplay: "ENJOY!"
		VEND: begin
			digit0 = 5'd15; // E
			digit1 = 5'd17; // N
			digit2 = 5'd18; // J
			digit3 = 5'd0;  // O
			digit4 = 5'd19; // Y
			digit5 = 5'd20; // blank
			dot = 1'd0;
		end

		endcase
	end

	
	// Display modules
	SevenSegmentDecode seg0(.digit(digit0), .segments(Seg5));
	SevenSegmentDecode seg1(.digit(digit1), .segments(Seg4));
	SevenSegmentDecode seg2(.digit(digit2), .segments(Seg3));
	SevenSegmentDecode seg3(.digit(digit3), .segments(Seg2));
	SevenSegmentDecode seg4(.digit(digit4), .segments(Seg1));
	SevenSegmentDecode seg5(.digit(digit5), .segments(Seg0));

endmodule


//-------------------------------------------------------------
// Counter module
//-------------------------------------------------------------

module Counter #(
	 parameter int N = 4
)(
	 input logic clock,
	 input logic clear_input_n,
	 input logic enable_n,
	 input logic reset_n,
	 input logic signed [N-1:0] addBy,
	 output logic signed [N-1:0] count
);

	 logic signed [N-1:0] count_next;

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


//-------------------------------------------------------------
// Register Module
//-------------------------------------------------------------

module RegisterNBit #(
	 parameter int N = 4
)(
	 input logic clock,
	 input logic clear_n,
	 input logic reset_n,
	 input logic [N-1:0] d,
	 output logic signed [N-1:0] q
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


//-------------------------------------------------------------
// Display Decoder Module
//-------------------------------------------------------------

module SevenSegmentDecode(
	 input logic [4:0] digit,
	 output logic [6:0] segments
);

	 always_comb begin
		  case (digit)
				//                  gfe_dcba
				5'd0: segments = 7'b100_0000;
				5'd1: segments = 7'b111_1001;
				5'd2: segments = 7'b010_0100;
				5'd3: segments = 7'b011_0000; 
				5'd4: segments = 7'b001_1001;
				5'd5: segments = 7'b001_0010;
				5'd6: segments = 7'b000_0010;
				5'd7: segments = 7'b111_1000;
				5'd8: segments = 7'b000_0000;
				5'd9: segments = 7'b001_0000;
				
				5'd10: segments = 7'b111_1111; // Blank
				5'd11: segments = 7'b000_1000; // A
				5'd12: segments = 7'b000_0011; // B
				5'd13: segments = 7'b100_0111; // L
				5'd14: segments = 7'b010_1111; // R
				5'd15: segments = 7'b000_0110; // E
				5'd16: segments = 7'b000_1110; // F
				5'd17: segments = 7'b100_1000; // N
				5'd18: segments = 7'b110_0001; // J
				5'd19: segments = 7'b001_0001; // Y
				5'd20: segments = 7'b111_1001; // ! (maybe?)				
				
				default: segments = 7'b111_1111;
		  endcase
	 end

endmodule