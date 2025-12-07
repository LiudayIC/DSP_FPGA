/*
module lfsr (
    input wire clk,
    input wire reset,
	 input wire enable,
    output reg [5:0] lfsr_out
);
    // Polynomial: x^16 + x^15 + x^13 + x^4 + 1
    // Maximal length: 2^16 - 1 = 65535 states
  
    wire feedback;
    assign feedback = lfsr_out[15] ^ lfsr_out[14] ^ lfsr_out[12] ^ lfsr_out[3];
    
    always @(posedge clk) begin
        if (reset)  lfsr_out <= 16'hACE1; // Non-zero seed
		  else lfsr_out <= {lfsr_out[14:0], feedback};
    end
endmodule


wire feedback;
    assign feedback = lfsr_out[5] ^ lfsr_out[4] ^ lfsr_out[2] ^ lfsr_out[1];
    
    always @(posedge clk) begin
        if (reset)  lfsr_out <= 16'h7FFF; // Non-zero seed
		  else  lfsr_out <= {lfsr_out[4:0], feedback};
    end
endmodule
*/
module lfsr #(
    parameter [31:0] SEED = 32'hACE1_2345 // Giá trị khởi tạo (KHÔNG ĐƯỢC bằng 0)
)(
    input  wire        clk,
    input  wire        reset,    // Reset tích cực mức thấp
    input  wire        enable,   // Tín hiệu cho phép chạy
    output wire [31:0] lfsr_out  // Ngõ ra dữ liệu ngẫu nhiên 32-bit
);

    reg [31:0] r_lfsr;

    // Đa thức tối ưu cho 32-bit (Maximal Length Polynomial)
    // Taps: 32, 22, 2, 1 -> Tạo ra chu kỳ lặp ~4.29 tỷ mẫu.
    // Mask này tương ứng với các vị trí bit cần XOR khi dịch phải.
    localparam [31:0] POLY_MASK = 32'hB4000000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Quan trọng: Load giá trị SEED khi reset
            r_lfsr <= SEED;
        end else if (enable) begin
            if (r_lfsr[0] == 1'b1) begin
                r_lfsr <= (r_lfsr >> 1) ^ POLY_MASK;
            end else begin
                r_lfsr <= (r_lfsr >> 1);
            end
        end
    end

    assign lfsr_out = r_lfsr;

endmodule