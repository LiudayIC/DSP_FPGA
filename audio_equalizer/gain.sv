module gain_lp(
    input logic signed [15:0] signal_in,
    input logic  [2:0]         gain_sel,
    output logic signed [15:0]        gained_signal
);

reg signed [47:0] temp_signal;

always_comb begin
    case(gain_sel) 
    3'b000 : temp_signal = signal_in;                         // 0db
    3'b001 : temp_signal = signal_in <<< 1;                   // 3db
    3'b010 : temp_signal = (signal_in <<< 1) + signal_in;                  // 6db
    3'b011 : temp_signal = signal_in <<< 2;                   // -3db
    3'b100 : temp_signal = (signal_in >>> 1);                 // -6db
    3'b101 : temp_signal = (signal_in >>> 2);                 // -9db
    3'b110 : temp_signal = (signal_in >>> 3);                 // -12db
    3'b111 : temp_signal = (signal_in >>> 4);                 // -15db
    endcase
end

assign gained_signal = temp_signal;

endmodule