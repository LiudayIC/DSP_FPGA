module i2c_av_config (
    input clk,
    input reset,

    output i2c_sclk,
    inout  i2c_sdat,

    output [3:0] status
);

reg [23:0] i2c_data;
reg [15:0] lut_data;
reg [3:0]  lut_index = 4'd0;

parameter LAST_INDEX = 4'ha;

reg  i2c_start = 1'b0;
wire i2c_done;
wire i2c_ack;

i2c_controller control (
    .clk (clk),
    .i2c_sclk (i2c_sclk),
    .i2c_sdat (i2c_sdat),
    .i2c_data (i2c_data),
    .start (i2c_start),
    .done (i2c_done),
    .ack (i2c_ack)
);

always @(*) begin
    case (lut_index)
4'h0: lut_data <= 16'b0000_0100_0001_0000;		// power on - 0C output power down = 1, disable anything else
4'h1:	lut_data <= 16'b0000_0101_0111_1001;	    // left-line-in -00
4'h2:	lut_data <= 16'b0000_0111_0111_1001;	  	// right-line-in -02
4'h3:	lut_data <= 16'b0000_0000_0001_0111;	    // left-head-phone out - 04
4'h4:	lut_data <= 16'b0000_0010_0001_0111;		// right-head-phone out - 06
4'h5:	lut_data <= 16'b0000_1000_0001_0101;		// analogue audio path control - 08 - select DAC 
4'h6:	lut_data <= 16'b0000_1010_0000_0110;		// digital path control  - 0a
4'h7:	lut_data <= 16'b0000_1110_0000_0001;		// digital audio interface format : slave - RJST - 24bit 
4'h8:	lut_data <= 16'b0001_0000_0000_0001;		// sampling rate 48khz usb
4'h9:	lut_data <= 16'b0001_0010_0000_0001;		// power on everything
4'hA:	lut_data <= 16'b0000_1100_0000_0010;       //	active
default: lut_data <= 16'h0000;
    endcase
end


reg [1:0] control_state = 2'b00;

assign status = lut_index;

always @(posedge clk) begin
    if (reset) begin
        lut_index <= 4'd0;
        i2c_start <= 1'b0;
        control_state <= 2'b00;
    end else begin
        case (control_state)
            2'b00: begin
                i2c_start <= 1'b1;
                i2c_data <= {8'h34, lut_data};
                control_state <= 2'b01;
            end
            2'b01: begin
                i2c_start <= 1'b0;
                control_state <= 2'b10;
            end
            2'b10: if (i2c_done) begin
                if (i2c_ack) begin
                    if (lut_index == LAST_INDEX)
                        control_state <= 2'b11;
                    else begin
                        lut_index <= lut_index + 1'b1;
                        control_state <= 2'b00;
                    end
                end else
                    control_state <= 2'b00;
            end
        endcase
    end
end

endmodule