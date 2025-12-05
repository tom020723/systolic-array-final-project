# Vivado vs ModelSim: 1-Clock Delay Difference Analysis

## Root Cause
- **Mixed use of blocking (`=`) and non-blocking (`<=`) assignments** in design and testbench
- **Updating input signals at the same time as clock edge** causes different execution order in each simulator (race condition)
- Result: ModelSim shows 1-clock delay, but Vivado appears to change signals **simultaneously**

## Solution
### Design Rules
- All register always blocks sensitive to clock must use **non-blocking (`<=`) exclusively**
- Registers in the same clock domain must use **consistent assignment style** (preferably all `<=`)

### Testbench Rules
- **Do NOT change signals with blocking assignment at the same timing as clock edge**
- Prefer **non-blocking assignment (`<=`)** or **change inputs at opposite edge / slightly before/after clock edge** to eliminate race conditions
- Ensure **at least 1-2 ns delay after `@(posedge clk)` before updating inputs** to avoid race conditions

## Example
```verilog
// ❌ WRONG: Race condition
always @(posedge clk) begin
    @(posedge clk); a_in = 8'd5;  // Same edge, blocking - race condition
end

// ✓ CORRECT: Add delay after clock edge
always @(posedge clk) begin
    @(posedge clk); #1; a_in = 8'd5;  // Add 1ns delay
end

// ✓ CORRECT: Use non-blocking in testbench
always @(posedge clk) begin
    @(posedge clk); #1; a_in <= 8'd5;  // Or use non-blocking
end
```

## Benefits
- **Simulator-independent behavior** (consistent across Vivado, ModelSim, VCS, etc.)
- **Predictable timing** in synthesis
- **Reduced debugging effort** from unexpected race conditions
