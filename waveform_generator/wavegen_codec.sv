module wavegen_codec(
    // audio codec port
    input  logic i_clk,reset,
	 input  logic AUD_ADCDAT,
	 output logic AUD_ADCLRCK,AUD_DACDAT,AUD_BCLK,AUD_DACLRCK,
	 output logic [23:0] wave_value,
	 input  logic inc_freq,
	 input  logic amp,
	 input  logic filter,
	 input logic duty_cycle,
    input logic noise_in,
    input logic [2:0] wave_sel
);

wire [1:0] sample_req,sample_end;
wire signed [15:0] wave_out;
wire [15:0] audio_in;
wire signed [15:0] o_filter_sig;
wire [15:0] signal_in;


audio_codec ac (
    .clk (i_clk),
    .reset (reset),
    .sample_end (sample_end),
    .sample_req (sample_req),
    .audio_output (signal_in),
    .audio_input (audio_in),
    .channel_sel (2'b10),

    .AUD_ADCLRCK (AUD_ADCLRCK),
    .AUD_ADCDAT (AUD_ADCDAT),
    .AUD_DACLRCK (AUD_DACLRCK),
    .AUD_DACDAT (AUD_DACDAT),
    .AUD_BCLK 	 (AUD_BCLK)
);
/*
wave_gen wg(
    .clk(i_clk),
    .rst_n(reset),
	 .amp(amp),
    .sample(sample_req[1]),
    .wave_out(wave_out),
	 .wave_sel(wave_sel),
	 .inc_freq(inc_freq),
	 .noise_in(noise_in)
);
*/

wave_gen_16b wg(
    .clk(i_clk),
    .rst_n(reset),
	 .amp(amp),
    .sample(sample_req[1]),
    .wave_out(wave_out),
	 .wave_sel(wave_sel),
	 .inc_freq(inc_freq),
	 .duty_cycle(duty_cycle),
	 .noise_in(noise_in)
);

filter u_filter(
    .clk(i_clk),
    .rst_n(reset),
    .i_sample(wave_out),
    .i_cs(sample_req[1]),
    .o_filterd_sig(o_filter_sig)
);

assign signal_in = filter ? o_filter_sig :wave_out ;

endmodule