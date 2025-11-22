# sum-unit-with-testbench
This project implements a parameterized Verilog RTL packet-based summation unit together with a structured SystemVerilog testbench.
the Sum module accumulates input words between data_first and data_last, using an FSM to manage initialization, accumulation, busy indication, and completion signaling through done.
The verification environment includes an interface for clean connectivity and a driver class that reads inputs from files, injects cycle-accurate stimulus, and computes a reference sum.
A checker automatically compares the DUT output with the expected value and logs results to a report file.
The design demonstrates professional RTL coding practices and a modular, UVM-style verification flow.
