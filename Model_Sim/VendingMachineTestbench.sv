`define TICKS_PER_SECOND   5
`define SECONDS_PER_MINUTE 60
`define MINUTES_PER_HOUR   60
`define HOURS_PER_DAY      24

module VendingMachineTestbench();

  // Module inputs
  logic clk;
  logic reset_n;
  logic refund_n;

  logic nickel;
  logic dime;
  logic quarter;

  logic item_1;
  logic item_2;
  logic item_3;

  // Module outputs
  logic vend;
  logic nickel_out;
  logic dime_out;
  logic quarter_out;

  logic [6:0] Seg0, Seg1, Seg2, Seg3, Seg4, Seg5;
  logic dot;

  // Expected outputs
  logic [2:0] vendExpected;
  logic nickelExpected;
  logic dimeExpected;
  logic quarterExpected;

  // Create System clock
  always begin
      clk = 1'b0;
      #1;
      clk = 1'b1;
      #1;
  end

  // Instantiate the VendingMachine dut
  VendingMachine dut (
    .clk(clk),
    .reset_n(reset_n),
    .refund_n(refund_n),

    .nickel(nickel),
    .dime(dime),
    .quarter(quarter),

    .item_1(item_1),
    .item_2(item_2),
    .item_3(item_3),

    .vend(vend),
    .nickel_out(nickel_out),
    .dime_out(dime_out),
    .quarter_out(quarter_out),

    .Seg0(Seg0),
    .Seg1(Seg1),
    .Seg2(Seg2),
    .Seg3(Seg3),
    .Seg4(Seg4),
    .Seg5(Seg5),
    .dot(dot)
  );

  // Reset the module
  task reset();
      reset_n = 1'b0;
      #10;
      reset_n = 1'b1;
  endtask

  // Inserts n Nickels
  task insertNickels(int n);
    for (int i = 0; i < n; i++) begin
      nickel = 1'b1; dime = 1'b0; quarter = 1'b0;
      #1
    end
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask

  // Inserts n Dimes
  task insertDimes(int n);
    for (int i = 0; i < n; i++) begin
      nickel = 1'b0; dime = 1'b1; quarter = 1'b0;
      #1
    end
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask

  // Inserts n Quarters
  task insertQuarters(int n);
    for (int i = 0; i < n; i++) begin
      nickel = 1'b0; dime = 1'b0; quarter = 1'b1;
      #1
    end
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask

endmodule

