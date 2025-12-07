module filter_sel(
 input logic [15:0] no_filter,
 input logic [15:0] i_1,
 input logic [15:0] i_2,
 input logic [15:0] i_3,
 input logic [1:0]  sel,
 output logic signed [15:0] o_signal
);

always_comb begin
	case (sel)
	2'b00 : o_signal = no_filter;
	2'b01 : o_signal = i_1;
	2'b10 : o_signal = i_2;
	2'b11 : o_signal = i_3;
	default : o_signal = 16'd0;
	endcase
end
endmodule