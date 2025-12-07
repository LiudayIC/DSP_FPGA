/*
module highpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:74];
reg signed [16:0] symmetric_result [0:37];
reg signed [28:0] coeff_multiplier [0:37];
reg signed [16:0] mul_scale_down   [0:37];
reg signed [17:0] s1_coeff_add  [0:18];
reg signed [18:0] s2_coeff_add  [0:8];
reg signed [11:0]  coeff_value   [0:37];

reg signed [28:0] filter_sig;
reg signed [28:0] r_filter_sig;

initial begin
coeff_value[0]  = 12'h000;
coeff_value[1]  = 12'hFFF;
coeff_value[2]  = 12'hFFF;
coeff_value[3]  = 12'hFFF;
coeff_value[4]  = 12'h001;
coeff_value[5]  = 12'h001;
coeff_value[6]  = 12'h002;
coeff_value[7]  = 12'h004;
coeff_value[8]  = 12'h004;
coeff_value[9]  = 12'h002;
coeff_value[10] = 12'hFFD;
coeff_value[11] = 12'hFF8;
coeff_value[12] = 12'hFF4;
coeff_value[13] = 12'hFF3;
coeff_value[14] = 12'hFF7;
coeff_value[15] = 12'h001;
coeff_value[16] = 12'h00E;
coeff_value[17] = 12'h01A;
coeff_value[18] = 12'h020;
coeff_value[19] = 12'h01C;
coeff_value[20] = 12'h00B;
coeff_value[21] = 12'hFF1;
coeff_value[22] = 12'hFD5;
coeff_value[23] = 12'hFC1;
coeff_value[24] = 12'hFBE;
coeff_value[25] = 12'hFD4;
coeff_value[26] = 12'h001;
coeff_value[27] = 12'h03C;
coeff_value[28] = 12'h072;
coeff_value[29] = 12'h08F;
coeff_value[30] = 12'h080;
coeff_value[31] = 12'h038;
coeff_value[32] = 12'hFB8;
coeff_value[33] = 12'hF10;
coeff_value[34] = 12'hE59;
coeff_value[35] = 12'hDB4;
coeff_value[36] = 12'hD42;
coeff_value[37] = 12'h7FF;
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
for (i = 1 ; i <= 74; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [74];

generate
for ( i = 1; i <= 37 ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [74 - i];
end
endgenerate

generate 
for ( i = 0; i <= 37 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] + symmetric_result[i] ;
end
endgenerate

generate 
for ( i = 0; i <= 37 ; i = i + 1) begin: shift_back
    assign mul_scale_down [i]   = coeff_multiplier [i] >>> 12;
end
endgenerate

generate
for ( i = 0; i <= 18; i = i +1)    begin: sum_16_to_8
    assign s1_coeff_add [i] = mul_scale_down[2*i] + mul_scale_down [2*i+1];
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



##############################################


###############################################


module highpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:71];
reg signed [16:0] symmetric_result [0:36];
reg signed [33:0] coeff_multiplier [0:36];
reg signed [34:0] s1_coeff_add  [0:18];
reg signed [35:0] s2_coeff_add  [0:8];
reg signed [15:0]  coeff_value   [0:36];

reg signed [45:0] filter_sig;
reg signed [30:0] r_filter_sig,scaled_filter_sig;

initial begin
 coeff_value [0]  = 16'h0000;
 coeff_value [1]  = 16'hFFFF;
 coeff_value [2]  = 16'hFFFF;
 coeff_value [3]  = 16'h0000;
 coeff_value [4]  = 16'h0006;
 coeff_value [5]  = 16'h000F;
 coeff_value [6]  = 16'h0017;
 coeff_value [7]  = 16'h0018;
 coeff_value [8]  = 16'h000B;
 coeff_value [9]  = 16'hFFEE;
 coeff_value [10] = 16'hFFC8;
 coeff_value [11] = 16'hFFA8;
 coeff_value [12] = 16'hFF9F;
 coeff_value [13] = 16'hFFBD;
 coeff_value [14] = 16'h0004;
 coeff_value [15] = 16'h0068;
 coeff_value [16] = 16'h00C6;
 coeff_value [17] = 16'h00F7;
 coeff_value [18] = 16'h00D6;
 coeff_value [19] = 16'h0057;
 coeff_value [20] = 16'hFF8D;
 coeff_value [21] = 16'hFEB0;
 coeff_value [22] = 16'hFE10;
 coeff_value [23] = 16'hFDFD;
 coeff_value [24] = 16'hFEA8;
 coeff_value [25] = 16'h000B;
 coeff_value [26] = 16'h01D8;
 coeff_value [27] = 16'h0389;
 coeff_value [28] = 16'h0472;
 coeff_value [29] = 16'h03F8;
 coeff_value [30] = 16'h01BD;
 coeff_value [31] = 16'hFDC3;
 coeff_value [32] = 16'hF880;
 coeff_value [33] = 16'hF2C7;
 coeff_value [34] = 16'hEDA2;
 coeff_value [35] = 16'hEA0F;
 coeff_value [36] = 16'h68C8;
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
for (i = 1 ; i <= 71; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [71];

generate
for ( i = 1; i <= 35 ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [71 - i];
end
endgenerate

assign symmetric_result [36] = sample_delay[35];

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

assign scaled_filter_sig = filter_sig  >>> 16;



always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= scaled_filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule

############################
module highpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

// Taps = 139
// Symmetric Filter: (139 + 1) / 2 = 70 unique coefficients
// Shift Register depth needed: 139 - 1 = 138

reg signed [15:0] sample_delay [0:137];    // 0 to 137 = 138 delays
reg signed [16:0] symmetric_result [0:69]; // 70 symmetric pairs
reg signed [32:0] coeff_multiplier [0:69]; // 70 multiplication results
reg signed [15:0] coeff_value  [0:69];     // 70 coefficients

// Adder Tree Registers
reg signed [33:0] s1_coeff_add  [0:34]; // Sums 70 items into 35
reg signed [34:0] s2_coeff_add  [0:16]; // Sums 34 items into 17 (1 leftover)
reg signed [35:0] s3_coeff_add  [0:7];  // Sums 16 items into 8 (1 leftover)

reg signed [45:0] filter_sig;
reg signed [29:0] r_filter_sig, scaled_filter_sig;

initial begin
    // NOTE: These are the first 70 coefficients from your original code.
    // For a 139-tap filter to work correctly, you should recalculate these 
    // values in MATLAB/Python.
    coeff_value[0] = 16'h0000;
    coeff_value[1] = 16'h0000;
    coeff_value[2] = 16'h0000;
    coeff_value[3] = 16'h0000;
    coeff_value[4] = 16'h0001;
    coeff_value[5] = 16'h0001;
    coeff_value[6] = 16'h0002;
    coeff_value[7] = 16'h0004;
    coeff_value[8] = 16'h0004;
    coeff_value[9] = 16'h0004;
    coeff_value[10] = 16'h0003;
    coeff_value[11] = 16'h0001;
    coeff_value[12] = 16'hFFFD;
    coeff_value[13] = 16'hFFF8;
    coeff_value[14] = 16'hFFF3;
    coeff_value[15] = 16'hFFEE;
    coeff_value[16] = 16'hFFEB;
    coeff_value[17] = 16'hFFEB;
    coeff_value[18] = 16'hFFEE;
    coeff_value[19] = 16'hFFF5;
    coeff_value[20] = 16'hFFFF;
    coeff_value[21] = 16'h000C;
    coeff_value[22] = 16'h001B;
    coeff_value[23] = 16'h0029;
    coeff_value[24] = 16'h0033;
    coeff_value[25] = 16'h0038;
    coeff_value[26] = 16'h0036;
    coeff_value[27] = 16'h002B;
    coeff_value[28] = 16'h0017;
    coeff_value[29] = 16'hFFFD;
    coeff_value[30] = 16'hFFDE;
    coeff_value[31] = 16'hFFBF;
    coeff_value[32] = 16'hFFA4;
    coeff_value[33] = 16'hFF92;
    coeff_value[34] = 16'hFF8C;
    coeff_value[35] = 16'hFF96;
    coeff_value[36] = 16'hFFB1;
    coeff_value[37] = 16'hFFDA;
    coeff_value[38] = 16'h0010;
    coeff_value[39] = 16'h004B;
    coeff_value[40] = 16'h0084;
    coeff_value[41] = 16'h00B3;
    coeff_value[42] = 16'h00CF;
    coeff_value[43] = 16'h00D3;
    coeff_value[44] = 16'h00BA;
    coeff_value[45] = 16'h0084;
    coeff_value[46] = 16'h0034;
    coeff_value[47] = 16'hFFD1;
    coeff_value[48] = 16'hFF67;
    coeff_value[49] = 16'hFF03;
    coeff_value[50] = 16'hFEB5;
    coeff_value[51] = 16'hFE88;
    coeff_value[52] = 16'hFE8A;
    coeff_value[53] = 16'hFEBF;
    coeff_value[54] = 16'hFF29;
    coeff_value[55] = 16'hFFC0;
    coeff_value[56] = 16'h0079;
    coeff_value[57] = 16'h013F;
    coeff_value[58] = 16'h01F9;
    coeff_value[59] = 16'h028E;
    coeff_value[60] = 16'h02E3;
    coeff_value[61] = 16'h02E0;
    coeff_value[62] = 16'h0274;
    coeff_value[63] = 16'h0196;
    coeff_value[64] = 16'h0048;
    coeff_value[65] = 16'hFE94;
    coeff_value[66] = 16'hFC91;
    coeff_value[67] = 16'hFA5D;
    coeff_value[68] = 16'hF81F;
    coeff_value[69] = 16'hF5FF; // Center Tap (approximate mapping)
end

// Shift Register Control
always @(posedge clk) begin
    if (rst_n) begin
        sample_delay[0] <= 16'd0;
    end else if (i_cs)
        sample_delay[0] <= i_sample;
end

genvar i;
generate
    // Shift register logic for taps 1 to 138 (indices 1 to 137)
    for (i = 1; i <= 137; i = i + 1) begin: Shifting_sample
        always @(posedge clk) begin
            if (rst_n) begin
                sample_delay[i] <= 16'd0;
            end else if (i_cs) begin
                sample_delay[i] <= sample_delay[i - 1];
            end
        end 
    end
endgenerate

// --- Symmetry Addition ---
// i_sample is index -1 relative to sample_delay.
// Total range is effectively x[n] ... x[n-138]
// Center is at index 69 (coeff_value[69]).
// x[n] (i_sample) pairs with x[n-138] (sample_delay[137])

assign symmetric_result[0] = i_sample + sample_delay[137];

generate
    for (i = 1; i <= 68; i = i + 1) begin: Calculating_symmetric
        assign symmetric_result[i] = sample_delay[i-1] + sample_delay[137 - i];
    end
endgenerate

// Center tap (Tap 69) - No pair
assign symmetric_result[69] = sample_delay[68];

// --- Multiplication ---
generate 
    for (i = 0; i <= 69; i = i + 1) begin: coeff_multiply
        assign coeff_multiplier[i] = coeff_value[i] * symmetric_result[i];
    end
endgenerate

// --- Adder Tree ---

// Stage 1: 70 inputs -> 35 outputs
// Indices 0 to 69 are consumed.
generate
    for (i = 0; i <= 34; i = i + 1) begin: sum_stage_1
        assign s1_coeff_add[i] = coeff_multiplier[2*i] + coeff_multiplier[2*i+1];
    end
endgenerate

// Stage 2: 35 inputs -> 17 outputs + 1 carry over
// s1[0]..s1[33] used. s1[34] is leftover.
generate 
    for (i = 0; i <= 16; i = i + 1) begin: sum_stage_2
        assign s2_coeff_add[i] = s1_coeff_add[2*i] + s1_coeff_add[2*i + 1];
    end
endgenerate

// Stage 3: 17 inputs -> 8 outputs + 1 carry over
// s2[0]..s2[15] used. s2[16] is leftover.
generate 
    for (i = 0; i <= 7; i = i + 1) begin: sum_stage_3
        assign s3_coeff_add[i] = s2_coeff_add[2*i] + s2_coeff_add[2*i + 1];
    end
endgenerate

// Final Summation
// Sums s3[0..7] + s2[16] (Stage 2 leftover) + s1[34] (Stage 1 leftover)
assign filter_sig = s3_coeff_add[0] + s3_coeff_add[1] + 
                    s3_coeff_add[2] + s3_coeff_add[3] +
                    s3_coeff_add[4] + s3_coeff_add[5] + 
                    s3_coeff_add[6] + s3_coeff_add[7] +
                    s2_coeff_add[16] + s1_coeff_add[34];

assign scaled_filter_sig = filter_sig >>> 16;

always @(posedge clk) begin    
    if (rst_n) 
        r_filter_sig <= 24'd0;
    else if (i_cs)
        r_filter_sig <= scaled_filter_sig;
    else 
        r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig; // Explicit cast to output width

endmodule

############################
*/

// ######################## 147 taps ##########################
module highpass_fir(
    input logic clk, rst_n,
    input logic i_cs,
    input logic signed [15:0] i_sample,
    output logic signed [15:0] o_filterd_sig 
);

reg signed [15:0] sample_delay [0:145];
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
coeff_value[3] = 16'h0000;
coeff_value[4] = 16'h0001;
coeff_value[5] = 16'h0001;
coeff_value[6] = 16'h0002;
coeff_value[7] = 16'h0004;
coeff_value[8] = 16'h0004;
coeff_value[9] = 16'h0004;
coeff_value[10] = 16'h0003;
coeff_value[11] = 16'h0001;
coeff_value[12] = 16'hFFFD;
coeff_value[13] = 16'hFFF8;
coeff_value[14] = 16'hFFF3;
coeff_value[15] = 16'hFFEE;
coeff_value[16] = 16'hFFEB;
coeff_value[17] = 16'hFFEB;
coeff_value[18] = 16'hFFEE;
coeff_value[19] = 16'hFFF5;
coeff_value[20] = 16'hFFFF;
coeff_value[21] = 16'h000C;
coeff_value[22] = 16'h001B;
coeff_value[23] = 16'h0029;
coeff_value[24] = 16'h0033;
coeff_value[25] = 16'h0038;
coeff_value[26] = 16'h0036;
coeff_value[27] = 16'h002B;
coeff_value[28] = 16'h0017;
coeff_value[29] = 16'hFFFD;
coeff_value[30] = 16'hFFDE;
coeff_value[31] = 16'hFFBF;
coeff_value[32] = 16'hFFA4;
coeff_value[33] = 16'hFF92;
coeff_value[34] = 16'hFF8C;
coeff_value[35] = 16'hFF96;
coeff_value[36] = 16'hFFB1;
coeff_value[37] = 16'hFFDA;
coeff_value[38] = 16'h0010;
coeff_value[39] = 16'h004B;
coeff_value[40] = 16'h0084;
coeff_value[41] = 16'h00B3;
coeff_value[42] = 16'h00CF;
coeff_value[43] = 16'h00D3;
coeff_value[44] = 16'h00BA;
coeff_value[45] = 16'h0084;
coeff_value[46] = 16'h0034;
coeff_value[47] = 16'hFFD1;
coeff_value[48] = 16'hFF67;
coeff_value[49] = 16'hFF03;
coeff_value[50] = 16'hFEB5;
coeff_value[51] = 16'hFE88;
coeff_value[52] = 16'hFE8A;
coeff_value[53] = 16'hFEBF;
coeff_value[54] = 16'hFF29;
coeff_value[55] = 16'hFFC0;
coeff_value[56] = 16'h0079;
coeff_value[57] = 16'h013F;
coeff_value[58] = 16'h01F9;
coeff_value[59] = 16'h028E;
coeff_value[60] = 16'h02E3;
coeff_value[61] = 16'h02E0;
coeff_value[62] = 16'h0274;
coeff_value[63] = 16'h0196;
coeff_value[64] = 16'h0048;
coeff_value[65] = 16'hFE94;
coeff_value[66] = 16'hFC91;
coeff_value[67] = 16'hFA5D;
coeff_value[68] = 16'hF81F;
coeff_value[69] = 16'hF5FF;
coeff_value[70] = 16'hF425;
coeff_value[71] = 16'hF2B5;
coeff_value[72] = 16'hF1CD;
coeff_value[73] = 16'h717D;
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
for (i = 1 ; i <= 145; i = i +1) begin:Shifting_sample
   always @(posedge clk) begin
        if (rst_n) begin
            sample_delay [i] <= 16'd0;
        end else if (i_cs) begin
            sample_delay [i] <= sample_delay[i - 1];
        end
    end 
end
endgenerate


assign symmetric_result [0] = i_sample + sample_delay [145];

generate
for ( i = 1; i <= 72 ; i = i + 1) begin: Calculating_symmetric
    assign symmetric_result [i] = sample_delay [i-1] + sample_delay [145 - i];
end
endgenerate

assign symmetric_result [73] = sample_delay[72];

generate 
for ( i = 0; i <= 73 ; i = i + 1) begin: coeff_multiply
    assign coeff_multiplier [i] = coeff_value [i] * symmetric_result[i] ;
end
endgenerate

generate
for ( i = 0; i <= 36; i = i +1)    begin: sum_16_to_8
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

assign scaled_filter_sig = filter_sig  >>> 16;



always @(posedge clk) begin	
	if (rst_n) 
	r_filter_sig <= 24'd0;
	else if (i_cs)
	r_filter_sig <= scaled_filter_sig;
	else r_filter_sig <= r_filter_sig;
end

assign o_filterd_sig = r_filter_sig;
endmodule