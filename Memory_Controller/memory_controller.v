module memory_controller (
	input clk, // Clock signal
	input rst_n, // Active-low reset
	input write_en, // Write enable (1 = Write, 0 = Read)
	input [3:0] addr, // 4-bit Address (can address 16 locations)
	input [7:0] data_in, // 8-bit Input Data
	output reg [7:0] data_out, // 8-bit Output Data
	output reg ready // Ready flag indicating controller status
);
// Internal memory array: 16 rows, 8 bits wide
	reg [7:0] ram_memory [0:15];
	integer i;
	// Synchronous memory operations
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
		data_out <= 8'b0;
		ready <= 1'b0;
		// Clear memory on reset
		for (i = 0; i < 16; i = i + 1) begin
			ram_memory[i] <= 8'b0;
		end
	end else begin
		ready <= 1'b1; // Controller active after reset
		if (write_en) begin
			ram_memory[addr] <= data_in; // Write operation
		end else begin
			data_out <= ram_memory[addr]; // Read operation
		end
	end
end
endmodule
