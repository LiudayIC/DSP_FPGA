module wavegen_codec(
    // audio codec port
    input  logic i_clk,reset,
	 input  logic AUD_ADCDAT,
	 output logic AUD_ADCLRCK,AUD_DACDAT,AUD_BCLK,AUD_DACLRCK,
	 input  logic filter_equalizer,
	 input  logic key,
	 input  logic [2:0] gain_sel_lp,
	 input  logic [2:0] gain_sel_hp,
	 input  logic [2:0] gain_sel_bp,
	 input  logic [1:0] filter_sel,
	 output logic [2:0] counter_o
);

wire [1:0] sample_req;
wire [15:0] wave_out;
wire [15:0] audio_in;
wire [15:0] o_filter_sig_lp;
wire [15:0] o_filter_sig_hp;
wire [15:0] o_filter_sig_bp;
wire [15:0] equalizer_signal;
wire [15:0] filter_signal;
wire [15:0] audio_to_codec;

logic signed [15:0] gained_signal_lp;
logic signed [15:0] gained_signal_hp;
logic signed [15:0] gained_signal_bp;
logic signed [15:0] signal_in;
logic signed [17:0] signal_sum;
logic [2:0] counter;

audio_codec ac (
    .clk (i_clk),
    .reset (reset),
    .sample_end (sample_end),
    .sample_req (sample_req),
    .audio_output (audio_to_codec),
    .audio_input (audio_in),
    .channel_sel (2'b10),

    .AUD_ADCLRCK (AUD_ADCLRCK),
    .AUD_ADCDAT (AUD_ADCDAT),
    .AUD_DACLRCK (AUD_DACLRCK),
    .AUD_DACDAT (AUD_DACDAT),
    .AUD_BCLK 	 (AUD_BCLK)
);

lowpass_fir lpf(
    .clk(i_clk),
    .rst_n(reset),
    .i_sample(audio_in),
    .i_cs(sample_req[1]),
    .o_filterd_sig(o_filter_sig_lp)
);

gain_lp  u_lp_gain(
	.signal_in(o_filter_sig_lp),
	.gain_sel(gain_sel_lp),
	.gained_signal(gained_signal_lp)
);

highpass_fir hpf(
    .clk(i_clk),
    .rst_n(reset),
    .i_sample(audio_in),
    .i_cs(sample_req[1]),
    .o_filterd_sig(o_filter_sig_hp)
);

gain_lp  u_hp_gain(
	.signal_in(o_filter_sig_hp),
	.gain_sel(gain_sel_hp),
	.gained_signal(gained_signal_hp)
);


bandpass_fir bpf(
    .clk(i_clk),
    .rst_n(reset),
    .i_sample(audio_in),
    .i_cs(sample_req[1]),
    .o_filterd_sig(o_filter_sig_bp)
);


gain_lp  u_bp_gain(
	.signal_in(o_filter_sig_bp),
	.gain_sel(gain_sel_bp),
	.gained_signal(gained_signal_bp)
);

sum_signal u_adder(
	.i_1(gained_signal_lp),
	.i_2(gained_signal_bp),
	.i_3(gained_signal_hp),
	.o_signal(equalizer_signal)
);
filter_sel u_filter_sel(
	.no_filter(audio_in),
	.i_1(o_filter_sig_lp),
	.i_2(o_filter_sig_bp),
	.i_3(o_filter_sig_hp),
	.sel(filter_sel),
	.o_signal(filter_signal)
);

assign audio_to_codec = filter_equalizer ? filter_signal : equalizer_signal;
endmodule