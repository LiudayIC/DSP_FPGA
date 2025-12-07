/*
module lowpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:72];
reg signed [16:0] symmetric_result [0:36];
reg signed [28:0] coeff_multiplier [0:36];
reg signed [16:0] mul_scale_down   [0:36];
reg signed [17:0] s1_coeff_add  [0:18];
reg signed [18:0] s2_coeff_add  [0:8];
reg signed [11:0]  coeff_value   [0:36];

reg signed [28:0] filter_sig;
reg signed [28:0] r_filter_sig;

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
for ( i = 0; i <= 36 ; i = i + 1) begin: shift_back
    assign mul_scale_down [i]   = coeff_multiplier [i] >>> 12;
end
endgenerate

generate
for ( i = 0; i <= 17; i = i +1)    begin: sum_16_to_8
    assign s1_coeff_add [i] = mul_scale_down[2*i] + mul_scale_down [2*i+1];
end
endgenerate

    assign s1_coeff_add [18] = mul_scale_down[36];

generate 
for ( i = 0; i <= 8; i = i +1) begin: sum_8_to_4
    assign s2_coeff_add [i] = s1_coeff_add [2*i] + s1_coeff_add[2*i +1];
end
endgenerate

assign filter_sig = s2_coeff_add[0] + s2_coeff_add[1] + 
                    s2_coeff_add[2] + s2_coeff_add[3] +
                    s2_coeff_add[4] + s2_coeff_add[5] + 
                    s2_coeff_add[6] + s2_coeff_add[7] +
                    s2_coeff_add[8] + s1_coeff_add[18];

always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule

module lowpass_fir(
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
#######################################################
module lowpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:146];
reg signed [16:0] symmetric_result [0:73];
reg signed [28:0] coeff_multiplier [0:73];
reg signed [29:0] s1_coeff_add  [0:36];
reg signed [30:0] s2_coeff_add  [0:17];
reg signed [31:0] s3_coeff_add  [0:8];
reg signed [11:0]  coeff_value  [0:73];

reg signed [41:0] filter_sig;
reg signed [29:0] r_filter_sig,scaled_filter_sig;

initial begin
coeff_value[0] = 12'h000;
coeff_value[1] = 12'h000;
coeff_value[2] = 12'h000;
coeff_value[3] = 12'h000;
coeff_value[4] = 12'h000;
coeff_value[5] = 12'h000;
coeff_value[6] = 12'h000;
coeff_value[7] = 12'h000;
coeff_value[8] = 12'h000;
coeff_value[9] = 12'h000;
coeff_value[10] = 12'h000;
coeff_value[11] = 12'hFFF;
coeff_value[12] = 12'hFFF;
coeff_value[13] = 12'hFFF;
coeff_value[14] = 12'hFFF;
coeff_value[15] = 12'hFFF;
coeff_value[16] = 12'hFFF;
coeff_value[17] = 12'hFFF;
coeff_value[18] = 12'hFFF;
coeff_value[19] = 12'hFFF;
coeff_value[20] = 12'hFFF;
coeff_value[21] = 12'hFFF;
coeff_value[22] = 12'hFFF;
coeff_value[23] = 12'hFFF;
coeff_value[24] = 12'hFFF;
coeff_value[25] = 12'hFFF;
coeff_value[26] = 12'hFFF;
coeff_value[27] = 12'hFFF;
coeff_value[28] = 12'h000;
coeff_value[29] = 12'h000;
coeff_value[30] = 12'h000;
coeff_value[31] = 12'h001;
coeff_value[32] = 12'h001;
coeff_value[33] = 12'h002;
coeff_value[34] = 12'h002;
coeff_value[35] = 12'h003;
coeff_value[36] = 12'h004;
coeff_value[37] = 12'h005;
coeff_value[38] = 12'h006;
coeff_value[39] = 12'h007;
coeff_value[40] = 12'h008;
coeff_value[41] = 12'h009;
coeff_value[42] = 12'h00A;
coeff_value[43] = 12'h00B;
coeff_value[44] = 12'h00C;
coeff_value[45] = 12'h00E;
coeff_value[46] = 12'h00F;
coeff_value[47] = 12'h011;
coeff_value[48] = 12'h012;
coeff_value[49] = 12'h014;
coeff_value[50] = 12'h015;
coeff_value[51] = 12'h017;
coeff_value[52] = 12'h018;
coeff_value[53] = 12'h01A;
coeff_value[54] = 12'h01C;
coeff_value[55] = 12'h01D;
coeff_value[56] = 12'h01F;
coeff_value[57] = 12'h020;
coeff_value[58] = 12'h022;
coeff_value[59] = 12'h023;
coeff_value[60] = 12'h024;
coeff_value[61] = 12'h026;
coeff_value[62] = 12'h027;
coeff_value[63] = 12'h028;
coeff_value[64] = 12'h029;
coeff_value[65] = 12'h02A;
coeff_value[66] = 12'h02B;
coeff_value[67] = 12'h02C;
coeff_value[68] = 12'h02D;
coeff_value[69] = 12'h02D;
coeff_value[70] = 12'h02E;
coeff_value[71] = 12'h02E;
coeff_value[72] = 12'h02E;
coeff_value[73] = 12'h02E;
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
for (i = 1 ; i <= 146; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [146];

generate
for ( i = 1; i <= 73  ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [146 - i];
end
endgenerate

generate 
for ( i = 0; i <= 73 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] * symmetric_result[i] ;
end
endgenerate

generate
for ( i = 0; i <= 36; i = i +1)    begin: sum_74_to_37
    assign s1_coeff_add [i] = coeff_multiplier[2*i] + coeff_multiplier [2*i+1];
end
endgenerate


generate 
for ( i = 0; i <= 17; i = i +1) begin: sum_36_to_18
    assign s2_coeff_add [i] = s1_coeff_add [2*i] + s1_coeff_add[2*i +1];
end
endgenerate

generate 
for ( i = 0; i <= 8; i = i +1) begin: sum_18_to_8
    assign s3_coeff_add [i] = s2_coeff_add [2*i] + s2_coeff_add[2*i +1];
end
endgenerate

assign filter_sig = s3_coeff_add[0] + s3_coeff_add[1] + 
                    s3_coeff_add[2] + s3_coeff_add[3] +
                    s3_coeff_add[4] + s3_coeff_add[5] + 
                    s3_coeff_add[6] + s3_coeff_add[7] +
                    s3_coeff_add[8] + s1_coeff_add[36];

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
*/
module lowpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:146];
reg signed [16:0] symmetric_result [0:73];
reg signed [32:0] coeff_multiplier [0:73];
reg signed [33:0] s1_coeff_add  [0:36];
reg signed [34:0] s2_coeff_add  [0:17];
reg signed [35:0] s3_coeff_add  [0:8];
reg signed [15:0]  coeff_value  [0:73];

reg signed [45:0] filter_sig;
reg signed [29:0] r_filter_sig,scaled_filter_sig;

initial begin
coeff_value[0] = 16'h0000;
coeff_value[1] = 16'h0000;
coeff_value[2] = 16'h0000;
coeff_value[3] = 16'hFFFF;
coeff_value[4] = 16'hFFFF;
coeff_value[5] = 16'hFFFE;
coeff_value[6] = 16'hFFFD;
coeff_value[7] = 16'hFFFD;
coeff_value[8] = 16'hFFFB;
coeff_value[9] = 16'hFFFA;
coeff_value[10] = 16'hFFF9;
coeff_value[11] = 16'hFFF7;
coeff_value[12] = 16'hFFF6;
coeff_value[13] = 16'hFFF4;
coeff_value[14] = 16'hFFF2;
coeff_value[15] = 16'hFFF1;
coeff_value[16] = 16'hFFEF;
coeff_value[17] = 16'hFFEE;
coeff_value[18] = 16'hFFED;
coeff_value[19] = 16'hFFEC;
coeff_value[20] = 16'hFFEB;
coeff_value[21] = 16'hFFEB;
coeff_value[22] = 16'hFFEB;
coeff_value[23] = 16'hFFEC;
coeff_value[24] = 16'hFFED;
coeff_value[25] = 16'hFFEF;
coeff_value[26] = 16'hFFF1;
coeff_value[27] = 16'hFFF5;
coeff_value[28] = 16'hFFF9;
coeff_value[29] = 16'hFFFE;
coeff_value[30] = 16'h0004;
coeff_value[31] = 16'h000B;
coeff_value[32] = 16'h0012;
coeff_value[33] = 16'h001B;
coeff_value[34] = 16'h0026;
coeff_value[35] = 16'h0031;
coeff_value[36] = 16'h003D;
coeff_value[37] = 16'h004A;
coeff_value[38] = 16'h0059;
coeff_value[39] = 16'h0069;
coeff_value[40] = 16'h007A;
coeff_value[41] = 16'h008B;
coeff_value[42] = 16'h009E;
coeff_value[43] = 16'h00B2;
coeff_value[44] = 16'h00C7;
coeff_value[45] = 16'h00DD;
coeff_value[46] = 16'h00F3;
coeff_value[47] = 16'h010A;
coeff_value[48] = 16'h0122;
coeff_value[49] = 16'h013B;
coeff_value[50] = 16'h0153;
coeff_value[51] = 16'h016C;
coeff_value[52] = 16'h0186;
coeff_value[53] = 16'h019F;
coeff_value[54] = 16'h01B8;
coeff_value[55] = 16'h01D1;
coeff_value[56] = 16'h01EA;
coeff_value[57] = 16'h0202;
coeff_value[58] = 16'h021A;
coeff_value[59] = 16'h0231;
coeff_value[60] = 16'h0247;
coeff_value[61] = 16'h025C;
coeff_value[62] = 16'h0270;
coeff_value[63] = 16'h0283;
coeff_value[64] = 16'h0294;
coeff_value[65] = 16'h02A4;
coeff_value[66] = 16'h02B3;
coeff_value[67] = 16'h02BF;
coeff_value[68] = 16'h02CB;
coeff_value[69] = 16'h02D4;
coeff_value[70] = 16'h02DC;
coeff_value[71] = 16'h02E1;
coeff_value[72] = 16'h02E5;
coeff_value[73] = 16'h02E7;
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
for (i = 1 ; i <= 146; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [146];

generate
for ( i = 1; i <= 73  ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [146 - i];
end
endgenerate

generate 
for ( i = 0; i <= 73 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] * symmetric_result[i] ;
end
endgenerate

generate
for ( i = 0; i <= 36; i = i +1)    begin: sum_74_to_37
    assign s1_coeff_add [i] = coeff_multiplier[2*i] + coeff_multiplier [2*i+1];
end
endgenerate


generate 
for ( i = 0; i <= 17; i = i +1) begin: sum_36_to_18
    assign s2_coeff_add [i] = s1_coeff_add [2*i] + s1_coeff_add[2*i +1];
end
endgenerate

generate 
for ( i = 0; i <= 8; i = i +1) begin: sum_18_to_8
    assign s3_coeff_add [i] = s2_coeff_add [2*i] + s2_coeff_add[2*i +1];
end
endgenerate

assign filter_sig = s3_coeff_add[0] + s3_coeff_add[1] + 
                    s3_coeff_add[2] + s3_coeff_add[3] +
                    s3_coeff_add[4] + s3_coeff_add[5] + 
                    s3_coeff_add[6] + s3_coeff_add[7] +
                    s3_coeff_add[8] + s1_coeff_add[36];

assign scaled_filter_sig = filter_sig >>> 15;


always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= scaled_filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule


