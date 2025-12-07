/*
module bandpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:154];
reg signed [16:0] symmetric_result [0:77];
reg signed [24:0] coeff_multiplier	 [0:77];
reg signed [16:0] mul_scale_down [0:77];
reg signed [17:0] s1_coeff_add  [0:38];
reg signed [18:0] s2_coeff_add  [0:18];
reg signed [19:0] s3_coeff_add  [0:9];
reg signed [11:0]  coeff_value   [0:77];

reg signed [29:0] filter_sig;
reg signed [29:0] r_filter_sig;

initial begin
coeff_value[0]  = 12'hFFA;
coeff_value[1]  = 12'hFEE;
coeff_value[2]  = 12'hFE5;
coeff_value[3]  = 12'hFE0;
coeff_value[4]  = 12'hFE1;
coeff_value[5]  = 12'hFE7;
coeff_value[6]  = 12'hFF0;
coeff_value[7]  = 12'hFF9;
coeff_value[8]  = 12'hFFF;
coeff_value[9]  = 12'h000;
coeff_value[10] = 12'hFFA;
coeff_value[11] = 12'hFF1;
coeff_value[12] = 12'hFE6;
coeff_value[13] = 12'hFDD;
coeff_value[14] = 12'hFDA;
coeff_value[15] = 12'hFDE;
coeff_value[16] = 12'hFE7;
coeff_value[17] = 12'hFF5;
coeff_value[18] = 12'h003;
coeff_value[19] = 12'h00D;
coeff_value[20] = 12'h010;
coeff_value[21] = 12'h00D;
coeff_value[22] = 12'h004;
coeff_value[23] = 12'hFF9;
coeff_value[24] = 12'hFF1;
coeff_value[25] = 12'hFEE;
coeff_value[26] = 12'hFF4;
coeff_value[27] = 12'h000;
coeff_value[28] = 12'h012;
coeff_value[29] = 12'h023;
coeff_value[30] = 12'h02F;
coeff_value[31] = 12'h034;
coeff_value[32] = 12'h02F;
coeff_value[33] = 12'h023;
coeff_value[34] = 12'h013;
coeff_value[35] = 12'h006;
coeff_value[36] = 12'h000;
coeff_value[37] = 12'h004;
coeff_value[38] = 12'h010;
coeff_value[39] = 12'h022;
coeff_value[40] = 12'h035;
coeff_value[41] = 12'h041;
coeff_value[42] = 12'h042;
coeff_value[43] = 12'h037;
coeff_value[44] = 12'h022;
coeff_value[45] = 12'h009;
coeff_value[46] = 12'hFF1;
coeff_value[47] = 12'hFE3;
coeff_value[48] = 12'hFE2;
coeff_value[49] = 12'hFED;
coeff_value[50] = 12'h001;
coeff_value[51] = 12'h016;
coeff_value[52] = 12'h024;
coeff_value[53] = 12'h023;
coeff_value[54] = 12'h010;
coeff_value[55] = 12'hFEF;
coeff_value[56] = 12'hFC6;
coeff_value[57] = 12'hF9F;
coeff_value[58] = 12'hF86;
coeff_value[59] = 12'hF82;
coeff_value[60] = 12'hF93;
coeff_value[61] = 12'hFB5;
coeff_value[62] = 12'hFDC;
coeff_value[63] = 12'hFF9;
coeff_value[64] = 12'hFFF;
coeff_value[65] = 12'hFE6;
coeff_value[66] = 12'hFAF;
coeff_value[67] = 12'hF65;
coeff_value[68] = 12'hF1A;
coeff_value[69] = 12'hEE4;
coeff_value[70] = 12'hEDA;
coeff_value[71] = 12'hF09;
coeff_value[72] = 12'hF74;
coeff_value[73] = 12'h010;
coeff_value[74] = 12'h0C7;
coeff_value[75] = 12'h178;
coeff_value[76] = 12'h206;
coeff_value[77] = 12'h254;
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
for (i = 1 ; i <= 154; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [154];

generate
for ( i = 1; i <= 77 ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [154 - i];
end
endgenerate

generate 
for ( i = 0; i <= 77 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] * symmetric_result[i] ;
end
endgenerate

generate 
for ( i = 0; i <= 77 ; i = i + 1) begin: shift_back
    assign mul_scale_down [i]   = coeff_multiplier [i] >>> 12;
end
endgenerate

generate
for ( i = 0; i <= 37; i = i +1)    begin: sum_16_to_8
    assign s1_coeff_add [i] = mul_scale_down[2*i] + mul_scale_down [2*i+1];
end
endgenerate

assign s1_coeff_add [38] =  mul_scale_down[76] + mul_scale_down [77];

generate 
for ( i = 0; i <= 18; i = i +1) begin: sum_8_to_4
    assign s2_coeff_add [i] = s1_coeff_add [2*i] + s1_coeff_add[2*i +1];
end
endgenerate

generate 
for ( i = 0; i <= 8; i = i +1) begin: pre_final
    assign s3_coeff_add [i] = s2_coeff_add [2*i] + s2_coeff_add[2*i +1];
end
endgenerate

assign s3_coeff_add [9] = s1_coeff_add [38] + s2_coeff_add [18];

assign filter_sig = s3_coeff_add [9] + s3_coeff_add [8] + s3_coeff_add [7] +s3_coeff_add [6] +s3_coeff_add [5] +s3_coeff_add [4] +s3_coeff_add [3] +s3_coeff_add [2] + s3_coeff_add [1] + s3_coeff_add [0];


always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule

module bandpass_fir(
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
coeff_value[0]  = 12'h03E;
coeff_value[1]  = 12'h03F;
coeff_value[2]  = 12'h035;
coeff_value[3]  = 12'h021;
coeff_value[4]  = 12'h008;
coeff_value[5]  = 12'hFF2;
coeff_value[6]  = 12'hFE4;
coeff_value[7]  = 12'hFE3;
coeff_value[8]  = 12'hFEE;
coeff_value[9]  = 12'h001;
coeff_value[10] = 12'h015;
coeff_value[11] = 12'h022;
coeff_value[12] = 12'h021;
coeff_value[13] = 12'h010;
coeff_value[14] = 12'hFF0;
coeff_value[15] = 12'hFC8;
coeff_value[16] = 12'hFA4;
coeff_value[17] = 12'hF8C;
coeff_value[18] = 12'hF88;
coeff_value[19] = 12'hF98;
coeff_value[20] = 12'hFB9;
coeff_value[21] = 12'hFDD;
coeff_value[22] = 12'hFF9;
coeff_value[23] = 12'hFFF;
coeff_value[24] = 12'hFE7;
coeff_value[25] = 12'hFB3;
coeff_value[26] = 12'hF6C;
coeff_value[27] = 12'hF25;
coeff_value[28] = 12'hEF2;
coeff_value[29] = 12'hEE8;
coeff_value[30] = 12'hF15;
coeff_value[31] = 12'hF7B;
coeff_value[32] = 12'h00F;
coeff_value[33] = 12'h0BD;
coeff_value[34] = 12'h166;
coeff_value[35] = 12'h1EC;
coeff_value[36] = 12'h237;
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
######################################################
module bandpass_fir(
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
reg signed [28:0] scaled_filter_sig,r_filter_sig;

initial begin
coeff_value[0]  = 12'h03E;
coeff_value[1]  = 12'h03F;
coeff_value[2]  = 12'h035;
coeff_value[3]  = 12'h021;
coeff_value[4]  = 12'h008;
coeff_value[5]  = 12'hFF2;
coeff_value[6]  = 12'hFE4;
coeff_value[7]  = 12'hFE3;
coeff_value[8]  = 12'hFEE;
coeff_value[9]  = 12'h001;
coeff_value[10] = 12'h015;
coeff_value[11] = 12'h022;
coeff_value[12] = 12'h021;
coeff_value[13] = 12'h010;
coeff_value[14] = 12'hFF0;
coeff_value[15] = 12'hFC8;
coeff_value[16] = 12'hFA4;
coeff_value[17] = 12'hF8C;
coeff_value[18] = 12'hF88;
coeff_value[19] = 12'hF98;
coeff_value[20] = 12'hFB9;
coeff_value[21] = 12'hFDD;
coeff_value[22] = 12'hFF9;
coeff_value[23] = 12'hFFF;
coeff_value[24] = 12'hFE7;
coeff_value[25] = 12'hFB3;
coeff_value[26] = 12'hF6C;
coeff_value[27] = 12'hF25;
coeff_value[28] = 12'hEF2;
coeff_value[29] = 12'hEE8;
coeff_value[30] = 12'hF15;
coeff_value[31] = 12'hF7B;
coeff_value[32] = 12'h00F;
coeff_value[33] = 12'h0BD;
coeff_value[34] = 12'h166;
coeff_value[35] = 12'h1EC;
coeff_value[36] = 12'h237;
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
*/
module bandpass_fir(
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
coeff_value[3] = 16'h0001;
coeff_value[4] = 16'h0001;
coeff_value[5] = 16'h0001;
coeff_value[6] = 16'h0000;
coeff_value[7] = 16'h0000;
coeff_value[8] = 16'h0000;
coeff_value[9] = 16'h0001;
coeff_value[10] = 16'h0003;
coeff_value[11] = 16'h0006;
coeff_value[12] = 16'h000B;
coeff_value[13] = 16'h0012;
coeff_value[14] = 16'h0019;
coeff_value[15] = 16'h001F;
coeff_value[16] = 16'h0025;
coeff_value[17] = 16'h0028;
coeff_value[18] = 16'h0028;
coeff_value[19] = 16'h0024;
coeff_value[20] = 16'h001C;
coeff_value[21] = 16'h0010;
coeff_value[22] = 16'h0001;
coeff_value[23] = 16'hFFF1;
coeff_value[24] = 16'hFFE3;
coeff_value[25] = 16'hFFD9;
coeff_value[26] = 16'hFFD5;
coeff_value[27] = 16'hFFD9;
coeff_value[28] = 16'hFFE4;
coeff_value[29] = 16'hFFF7;
coeff_value[30] = 16'h000F;
coeff_value[31] = 16'h0028;
coeff_value[32] = 16'h003E;
coeff_value[33] = 16'h004C;
coeff_value[34] = 16'h004F;
coeff_value[35] = 16'h0042;
coeff_value[36] = 16'h0023;
coeff_value[37] = 16'hFFF2;
coeff_value[38] = 16'hFFB3;
coeff_value[39] = 16'hFF6A;
coeff_value[40] = 16'hFF1D;
coeff_value[41] = 16'hFED6;
coeff_value[42] = 16'hFE9C;
coeff_value[43] = 16'hFE77;
coeff_value[44] = 16'hFE6C;
coeff_value[45] = 16'hFE7F;
coeff_value[46] = 16'hFEAD;
coeff_value[47] = 16'hFEF1;
coeff_value[48] = 16'hFF42;
coeff_value[49] = 16'hFF93;
coeff_value[50] = 16'hFFD5;
coeff_value[51] = 16'hFFFC;
coeff_value[52] = 16'hFFF9;
coeff_value[53] = 16'hFFC4;
coeff_value[54] = 16'hFF5B;
coeff_value[55] = 16'hFEBF;
coeff_value[56] = 16'hFDFC;
coeff_value[57] = 16'hFD21;
coeff_value[58] = 16'hFC45;
coeff_value[59] = 16'hFB83;
coeff_value[60] = 16'hFAF4;
coeff_value[61] = 16'hFAB4;
coeff_value[62] = 16'hFAD6;
coeff_value[63] = 16'hFB68;
coeff_value[64] = 16'hFC6E;
coeff_value[65] = 16'hFDE2;
coeff_value[66] = 16'hFFB4;
coeff_value[67] = 16'h01C7;
coeff_value[68] = 16'h03FB;
coeff_value[69] = 16'h0627;
coeff_value[70] = 16'h0822;
coeff_value[71] = 16'h09C6;
coeff_value[72] = 16'h0AF2;
coeff_value[73] = 16'h0B8E;
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


