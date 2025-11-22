// Sum module: accumulates packets of data and asserts 'done' when sum is ready.
// One packet = a sequence of data_in values between data_first and data_last.

`timescale 1ns/1ps

module Sum #(
    parameter NOF_BITS = 32
)(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    data_first,
    input  wire                    data_last,
    input  wire [NOF_BITS-1:0]     data_in,
    output reg  [NOF_BITS:0]       data_out,
    output reg                     busy,
    output reg                     done
);

    // --------------------------------------
    // State machine encoding (one-hot)
    // --------------------------------------
    localparam IDLE = 3'b001;
    localparam BUSY = 3'b010;
    localparam DONE = 3'b100;

    reg [2:0] state, next_state;

    // Accumulator registers
    reg [NOF_BITS:0] acc, acc_next;

    // Output next values
    reg busy_next, done_next;

    // --------------------------------------
    // COMBINATIONAL LOGIC
    // --------------------------------------
    always @(*) begin
        // Default assignments (avoid latches)
        next_state = state;
        acc_next   = acc;
        busy_next  = 1'b0;
        done_next  = 1'b0;

        case (state)

            // =======================================================
            // IDLE: wait for the first data of a new packet
            // =======================================================
            IDLE: begin
                if (data_first) begin
                    // Start a new accumulation with first element
                    acc_next  = {1'b0, data_in};
                    busy_next = 1'b1;

                    if (data_last) begin
                        // Single-element packet: go directly to DONE
                        next_state = DONE;
                    end else begin
                        // More data will come
                        next_state = BUSY;
                    end
                end
            end

            // =======================================================
            // BUSY: accumulate all middle elements
            // =======================================================
            BUSY: begin
                busy_next = 1'b1;
                // Add current input on every cycle in BUSY
                acc_next  = acc + data_in;

                if (data_last) begin
                    // Last element of the packet
                    next_state = DONE;
                end else begin
                    // Still in the middle of the packet
                    next_state = BUSY;
                end
            end

            // =======================================================
            // DONE: one-cycle pulse of 'done'
            // =======================================================
            DONE: begin
                // 'done' is high for exactly one cycle
                done_next  = 1'b1;
                busy_next  = 1'b0;
                next_state = IDLE;   // Back to IDLE on next cycle
            end

            default: begin
                next_state = IDLE;
            end

        endcase
    end

    // --------------------------------------
    // SEQUENTIAL LOGIC (registers)
    // --------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous reset
            state    <= IDLE;
            acc      <= {NOF_BITS+1{1'b0}};
            data_out <= {NOF_BITS+1{1'b0}};
            busy     <= 1'b0;
            done     <= 1'b0;
        end else begin
            // State and accumulator update
            state <= next_state;
            acc   <= acc_next;

            // Outputs
            busy <= busy_next;
            done <= done_next;

            // Latch final sum into data_out when entering DONE
            if (next_state == DONE) begin
                data_out <= acc_next;
            end
        end
    end

endmodule
