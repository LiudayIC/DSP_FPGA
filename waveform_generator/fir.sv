module filter(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:72];
reg signed [16:0] symmetric_result [0:36];
reg signed [28:0] coeff_multiplier [0:36];
reg signed [29:0] s1_coeff_add  [0:18];
reg signed [30:0] s2_coeff_add  [0:8];
reg signed [11:0]  coeff_value   [0:36];

reg signed [40:0] filter_sig;
reg signed [28:0] r_filter_sig,scaled_filter_sig;

initial begin
coeff_value[0]  = 12'hFE4;
coeff_value[1]  = 12'hFE6;
coeff_value[2]  = 12'hFE7;
coeff_value[3]  = 12'hFEA;
coeff_value[4]  = 12'hFEC;
coeff_value[5]  = 12'hFF0;
coeff_value[6]  = 12'hFF3;
coeff_value[7]  = 12'hFF7;
coeff_value[8]  = 12'hFFC;
coeff_value[9]  = 12'h000;
coeff_value[10] = 12'h005;
coeff_value[11] = 12'h00B;
coeff_value[12] = 12'h011;
coeff_value[13] = 12'h017;
coeff_value[14] = 12'h01D;
coeff_value[15] = 12'h023;
coeff_value[16] = 12'h02A;
coeff_value[17] = 12'h031;
coeff_value[18] = 12'h037;
coeff_value[19] = 12'h03E;
coeff_value[20] = 12'h045;
coeff_value[21] = 12'h04C;
coeff_value[22] = 12'h052;
coeff_value[23] = 12'h058;
coeff_value[24] = 12'h05F;
coeff_value[25] = 12'h064;
coeff_value[26] = 12'h06A;
coeff_value[27] = 12'h06F;
coeff_value[28] = 12'h074;
coeff_value[29] = 12'h078;
coeff_value[30] = 12'h07C;
coeff_value[31] = 12'h07F;
coeff_value[32] = 12'h082;
coeff_value[33] = 12'h085;
coeff_value[34] = 12'h086;
coeff_value[35] = 12'h087;
coeff_value[36] = 12'h088;
end


always @(posedge clk) begin
    if (rst_n) begin
        sample_delay [0] <= 16'd0;
    end else if (i_cs)
        sample_delay [0] <= i_sample;
end

// sample_delay0 = x(n-1) ; sample_delay1  = x(n-2) ; x(n) = i_sample ; sample_delay31 = x(n-32)

genvar i;
generate
for (i = 1 ; i <= 72; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [72];

generate
for ( i = 1; i <= 36 ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [72 - i];
end
endgenerate

generate 
for ( i = 0; i <= 36 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] * symmetric_result[i] ;
end
endgenerate

generate
for ( i = 0; i <= 17; i = i +1)    begin: sum_16_to_8
    assign s1_coeff_add [i] = coeff_multiplier[2*i] + coeff_multiplier [2*i+1];
end
endgenerate


generate 
for ( i = 0; i <= 8; i = i +1) begin: sum_8_to_4
    assign s2_coeff_add [i] = s1_coeff_add [2*i] + s1_coeff_add[2*i +1];
end
endgenerate

assign filter_sig = s2_coeff_add[0] + s2_coeff_add[1] + 
                    s2_coeff_add[2] + s2_coeff_add[3] +
                    s2_coeff_add[4] + s2_coeff_add[5] + 
                    s2_coeff_add[6] + s2_coeff_add[7] +
                    s2_coeff_add[8] + coeff_multiplier[36];

assign scaled_filter_sig = filter_sig >>> 12;


always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= scaled_filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule

