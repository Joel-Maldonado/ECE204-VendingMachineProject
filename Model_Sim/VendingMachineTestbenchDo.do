# Start sim
vsim -gui work.VendingMachineTestbench

# Group: Clock + Reset
add wave -group {Clock/Reset} sim:/VendingMachineTestbench/clk
add wave -group {Clock/Reset} sim:/VendingMachineTestbench/dut/tick
add wave -group {Clock/Reset} sim:/VendingMachineTestbench/dut/clk_1Hz
add wave -group {Clock/Reset} sim:/VendingMachineTestbench/reset_n
add wave -group {Clock/Reset} sim:/VendingMachineTestbench/refund_n

# Group: Item Select
add wave -group {Item Select} sim:/VendingMachineTestbench/item_1
add wave -group {Item Select} sim:/VendingMachineTestbench/item_2
add wave -group {Item Select} sim:/VendingMachineTestbench/item_3

# Group: Coin Inputs
add wave -group {Coin Inputs} sim:/VendingMachineTestbench/nickel
add wave -group {Coin Inputs} sim:/VendingMachineTestbench/dime
add wave -group {Coin Inputs} sim:/VendingMachineTestbench/quarter

# Group: Balance
add wave -group {Balance} sim:/VendingMachineTestbench/dut/balance
add wave -group {Balance} sim:/VendingMachineTestbench/balanceExpected

# Group: Outputs
add wave -group {Outputs} sim:/VendingMachineTestbench/vend
add wave -group {Outputs} sim:/VendingMachineTestbench/vendExpected

add wave -group {Outputs} sim:/VendingMachineTestbench/nickel_out
add wave -group {Outputs} sim:/VendingMachineTestbench/nickelExpected

add wave -group {Outputs} sim:/VendingMachineTestbench/dime_out
add wave -group {Outputs} sim:/VendingMachineTestbench/dimeExpected

add wave -group {Outputs} sim:/VendingMachineTestbench/quarter_out
add wave -group {Outputs} sim:/VendingMachineTestbench/quarterExpected


# Group: 7-Segment
add wave -group {7-Segment} sim:/VendingMachineTestbench/dut/Seg*

run -all
wave zoom full
