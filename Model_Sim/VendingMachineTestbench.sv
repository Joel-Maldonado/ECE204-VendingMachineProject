module VendingMachineTestbench();

//-------------------------------------------------------------
// Variable Declarations
//-------------------------------------------------------------

  // Inputs
  logic clk;
  logic reset_n;
  logic refund_n;

  logic nickel;
  logic dime;
  logic quarter;

  logic item_1;
  logic item_2;
  logic item_3;

  // Outputs
  logic vend;
  logic nickel_out;
  logic dime_out;
  logic quarter_out;

  logic [6:0] Seg0, Seg1, Seg2, Seg3, Seg4, Seg5;
  logic dot;

  // Expected outputs
  integer balanceExpected;
  logic vendExpected;
  logic nickelExpected;
  logic dimeExpected;
  logic quarterExpected;

  // Number of comparision errors since start of simulation
  int numErrors;

  // Create System clock
  always begin
      clk = 1'b0;
      #1;
      clk = 1'b1;
      #1;
  end


//-------------------------------------------------------------
// DUT
//-------------------------------------------------------------

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


//-------------------------------------------------------------
// Task Declarations
//-------------------------------------------------------------

  // Reset the module
  task reset();
      reset_n = 1'b0;
      #10;
      reset_n = 1'b1;

      validateState();
  endtask


  // Inserts n Nickels
  task insertNickels(int n);
    // Update balance, add nickel, wait and validate state
    for (int i = 0; i < n; i++) begin
      balanceExpected += 1;
      nickel = 1'b1; dime = 1'b0; quarter = 1'b0;
      #4;
      validateState();
    end

    // Reset inputs
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask


  // Inserts n Dimes
  task insertDimes(int n);
    // Update balance, add dime, wait and validate state
    for (int i = 0; i < n; i++) begin
      balanceExpected += 2;
      nickel = 1'b0; dime = 1'b1; quarter = 1'b0;
      #4;
      validateState();
    end

    // Reset inputs
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask


  // Inserts n Quarters
  task insertQuarters(int n);
    // Update balance, add quarter, wait and validate state
    for (int i = 0; i < n; i++) begin
      balanceExpected += 5;
      nickel = 1'b0; dime = 1'b0; quarter = 1'b1;
      #4;
      validateState();
    end

    // Reset inputs
    nickel = 1'b0; dime = 1'b0; quarter = 1'b0;
  endtask
  
  // Refunds remaining balance
  task refund();

    // Set refund input
    refund_n = 1'b0;
    
    // While balance is above 5, refund quarters
    while (balanceExpected >= 5) begin
      // Set refund expectations and wait
      nickelExpected = 1'b0; dimeExpected = 1'b0; quarterExpected = 1'b1;
      #4;
      // Validate state and wait, dut.balance updates slightly late
      // the validateState here is for repeat refunds
      validateState();
      balanceExpected -= 5;
      refund_n = 1'b1;
    end
    
    // while balance is above 2, refund dimes
    while (balanceExpected >= 2) begin
      // Set refund expectations and wait
      nickelExpected = 1'b0; dimeExpected = 1'b1; quarterExpected = 1'b0;
      #4;
      // Validate state and wait, dut.balance updates slightly late
      // the validateState here is for repeat refunds
      validateState();
      balanceExpected -= 2;
      refund_n = 1'b1;
    end

    // while balance is above 1, refund nickels
    while (balanceExpected >= 1) begin
      // Set refund expectations and wait
      nickelExpected = 1'b1; dimeExpected = 1'b0; quarterExpected = 1'b0;
      #4;
      // Validate state and wait, dut.balance updates slightly late
      // the validateState here is for repeat refunds
      validateState();
      balanceExpected -= 1;
      refund_n = 1'b1;
    end



    // Reset expectations to 0 and wait
    refund_n = 1'b1;
    nickelExpected = 1'b0; dimeExpected = 1'b0; quarterExpected = 1'b0;
    #8;

    // Double check final state after refund
    validateState();
  endtask

  // Subtracts cost and vends
  task vendItem();

    // Check for vending
    vendExpected = 1'b1;
    validateState();
    #4;

    vendExpected = 1'b0;

    // Determine selected item and subtract its cost
    if (item_1) begin
      balanceExpected -= 10; // $0.50
    end else if (item_2) begin
      balanceExpected -= 40; // $2.00
    end else if (item_3) begin
      balanceExpected -= 50; // $2.50
    end else begin
      balanceExpected -= 20; // $1.00
    end
    
    // Wait and check state again
    #4;
    validateState();
    refund();

  endtask

task validateState();
    // Check values off the expected values
    if (dut.balance !== balanceExpected || nickel_out !== nickelExpected ||
            dime_out !== dimeExpected || quarter_out !== quarterExpected)
    begin

        // If error is found, increase errors
        // Halt sim if 3+ are found
        numErrors++;
        if (numErrors > 3) begin
            $display("Too many errors.  Halting simulation.");
            $stop;
        end

        // Print values
     
        $display("%0tps: balance: %2d, nickel_out: %2d, dime_out: %2d, quarter_out: %2d, balanceExpected: %2d, nickelExpected:%2d, dimeExpected:%2d, quarterExpected:%1d",
            $time,
            dut.balance, nickel_out, dime_out, quarter_out,
            balanceExpected, nickelExpected, dimeExpected, quarterExpected,
        );

    end
endtask


  // -------------------------
  // Testing
  // -------------------------
  initial begin

    // Initialize
    reset_n = 1;
    refund_n = 1;

    nickel = 0;
    nickelExpected = 0;

    dime = 0;
    dimeExpected = 0;

    quarter = 0;
    quarterExpected = 0;

    item_1 = 0;
    item_2 = 0;
    item_3 = 0;

    vendExpected = 0;
    balanceExpected = 0;

    // Start by testing the reset
    reset();
    #3;

    // Test refund function
    insertQuarters(1);
    insertDimes(1);
    insertNickels(2);
    refund();

    // Test vending
    insertQuarters(4);
    vendItem();

    // Test other items
    item_1 = 1;
    insertQuarters(2);
    vendItem();
    item_1 = 0;

        // Test other items
    item_2 = 1;
    insertQuarters(8);
    vendItem();
    item_2 = 0;

        // Test other items
    item_3 = 1;
    insertQuarters(10);
    vendItem();
    item_3 = 0;

    // Finish simulation
    #20;
    if (0 == numErrors) begin
        $display("VendingMachine module validated successfully!");
    end
    $stop;
  end


endmodule

