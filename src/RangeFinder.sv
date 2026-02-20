module RangeFinder
   #(parameter WIDTH=8)
    (input  logic [WIDTH-1:0] data_in,
     input  logic             clock, reset,
     input  logic             go, finish,
     output logic [WIDTH-1:0] range,
     output logic             error);

// Put your code here
  typedef enum logic [1:0] {
    S_IDLE   = 2'b00,   // waiting for a clean go
    S_ACTIVE = 2'b01,   // collecting samples
    S_ERROR= 2'b10      // ignore everything until next clean go
  } state_t;

  state_t state;

  logic [WIDTH-1:0] low_q, high_q;
  logic [WIDTH-1:0] new_min, new_max;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      state       <= S_IDLE;
      low_q       <= '0;
      high_q       <= '0;
      range       <= '0;
      error <= 1'b0;
    end else begin
      unique case (state)
        S_IDLE: begin
          // Error: finish before go OR go&finish same cycle
          if (finish) begin
            state       <= S_ERROR;
            error <= 1'b1;
          end
          // Clean start: go=1, finish=0
          else if (go) begin
            state       <= S_ACTIVE;
            error <= 1'b0;

            // include data_in at the same clock edge as go
            low_q <= data_in;
            high_q <= data_in;
          end
        end

        S_ACTIVE: begin
          if (go) begin// go==1 here implies either go&finish or "second go"
            state       <= S_ERROR;
            error <= 1'b1;
          end
          else begin
            new_min = (data_in < low_q) ? data_in : low_q;
            new_max = (data_in > high_q) ? data_in : high_q;
            low_q <= new_min;
            high_q <= new_max;
            if (finish) begin
              range <= new_max - new_min;  // unsigned subtraction
              state <= S_IDLE;             // ready for next transaction
            end
          end
        end

        S_ERROR: begin
          // stay in error if finish is high, or if go&finish high together
          // recover only on a clean go (go=1, finish=0)
          if (go && !finish) begin
            state       <= S_ACTIVE;
            error <= 1'b0;
            low_q <= data_in;
            high_q <= data_in;
          end
        end

        default: begin
          state       <= S_IDLE;
          error <= 1'b0;
        end
      endcase
    end
  end

endmodule: RangeFinder

