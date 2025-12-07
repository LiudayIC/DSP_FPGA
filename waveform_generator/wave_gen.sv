module wave_gen(
 input logic clk,rst_n,
 input logic noise_in,
 input logic sample,
 input logic inc_freq,
 input logic amp,
 input logic duty_cycle,
 input logic [2:0] wave_sel,
 output logic signed [15:0] wave_out
);

// Internal signals
logic [7:0] counter_1;
logic period;
logic [5:0] lut,inv_lut;
logic signed [15:0] noise_value;
logic signed [7:0] tri_mem,sine_mem,sawtooth_mem,ecg_mem;
//logic [8:0] tri_noise,sine_noise,sawtooth_noise,ecg_noise;
logic signed [15:0] tri_noise,sine_noise,sawtooth_noise,ecg_noise,square_noise;
logic signed [7:0]  sine_wave,tri_wave,sawtooth_wave,ecg_wave;
logic 		 [7:0]  square_wave;
logic signed [14:0]  sine_amp, tri_amp, sawtooth_amp, ecg_amp, square_amp;
logic signed [8:0]  sine_out, tri_out, saw_out, ecg_out , sq_out;
reg   signed [15:0] data_out;


//
// Phase increase
always @(posedge clk) begin
    if (rst_n)       counter_1 <= 7'd0;
    else if (sample) counter_1 <= counter_1 + inc_freq + 1'b1;;
    //else  counter_1 <= counter_1 +1'b1;
end

//

assign inv_lut = (counter_1 == 8'h40 | counter_1 == 8'hC0) ? 6'd63: ~counter_1[5:0] + 1'b1;
assign square_wave = counter_1 < 8'd125 ? 8'hFF : 15'd0;
assign ecg_wave = ecg_mem;


always @(posedge clk) begin
    if (rst_n) begin
        tri_amp      <= 0;
        square_amp   <= 0;
        sawtooth_amp <= 0;
        sine_amp     <= 0;
        ecg_amp      <= 0;
    end else begin
        tri_amp      <= amp ? (tri_wave <<< 5)      : tri_wave <<< 4;
        square_amp   <= amp ? (square_wave << 5)   : square_wave << 4;
        sawtooth_amp <= amp ? (sawtooth_wave <<< 5) : sawtooth_wave <<<4;
        sine_amp     <= amp ? (sine_wave <<< 5)     : sine_wave <<< 4;
        ecg_amp      <= amp ? (ecg_wave <<< 5)      : ecg_wave <<< 4;
    end
end

always @(posedge clk) begin
    if (rst_n) begin
        tri_noise      <= 0;
        square_noise   <= 0;
        sawtooth_noise <= 0;
        sine_noise     <= 0;
        ecg_noise      <= 0;
    end else begin
        tri_noise      <= noise_in ? tri_amp      + noise_value >>> 4 : tri_amp;
        square_noise   <= noise_in ? square_amp   + noise_value >>> 4 : square_amp;
        sawtooth_noise <= noise_in ? sawtooth_amp + noise_value >>> 4 : sawtooth_amp;
        sine_noise     <= noise_in ? sine_amp     + noise_value >>> 4 : sine_amp;
        ecg_noise      <= noise_in ? ecg_amp      + noise_value >>> 4 : ecg_amp;
    end
end
	


// Phase Output Settings
always_comb begin
    case(counter_1[7:6])
    2'b00 : begin 
        lut = counter_1[5:0];
        sine_wave = sine_mem; 
        tri_wave = tri_mem;
        sawtooth_wave = sawtooth_mem;
    end
    2'b01 : begin 
        lut = inv_lut;
        sine_wave = sine_mem;
        tri_wave = tri_mem;
        sawtooth_wave = ~sawtooth_mem + 1'b1;
    end
    2'b10 : begin 
        lut = counter_1[5:0];
        sine_wave = ~sine_mem + 1'b1;
        tri_wave = ~tri_mem + 1'b1;
        sawtooth_wave = sawtooth_mem;
    end
    2'b11 : begin 
        lut = inv_lut;
        sine_wave = ~sine_mem + 1'b1;
        tri_wave = ~tri_mem + 1'b1;
        sawtooth_wave = ~sawtooth_mem + 1'b1;
    end
    endcase
end

always@(posedge clk) begin
    case(wave_sel)
       3'b000 : data_out <= sine_noise;
       3'b001 : data_out <= tri_noise;
       3'b010 : data_out <= sawtooth_noise;
       3'b011 : data_out <= square_noise;
       3'b100 : data_out <= ecg_noise; 
		 default : data_out = 15'd0;
    endcase 
end

assign wave_out = data_out;


// LUT 
sine_lut rom_sine(
    .clk(clk),
    .addr(lut),
    .q(sine_mem)
);

triangle_lut rom_triangle(
    .clk(clk),
    .addr(lut),
    .q(tri_mem)
);

sawtooth_lut rom_sawtooth(
    .clk(clk),
    .addr(lut[5:0]),
    .q(sawtooth_mem)
);

ecg_lut rom_ecg(
    .clk(clk),
    .addr(counter_1),
    .q(ecg_mem)
);

lfsr noise_gen(
    .clk(clk),
    .reset(rst_n),
    .noise(noise_value)
);

endmodule