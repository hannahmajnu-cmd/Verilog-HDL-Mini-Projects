module tb_memory_controller;
	// Testbench signals
		reg clk;
		reg rst_n;
		reg write_en;
		reg [3:0] addr;
		reg [7:0] data_in;
		wire [7:0] data_out;
		wire ready;
	// Instantiate the Unit Under Test (UUT)
	memory_controller uut (
		.clk(clk),
		.rst_n(rst_n),
		.write_en(write_en),
		.addr(addr),
		.data_in(data_in),
		.data_out(data_out),
		.ready(ready)
	);
	// Generate 10ns clock cycle (50MHz frequency)
	always #5 clk = ~clk;
	initial begin
		// Initialize inputs
		clk = 0;
		rst_n = 0;
		write_en = 0;
		addr = 0;
		data_in = 0;
		// Print header to EDA Playground console
		$display("Time\t Rst\t WE\t Addr\t Data_In\t Data_Out\t Ready");
		$display("----------------------------------------------------------------");
		$monitor("%0d\t %b\t %b\t %h\t %h\t\t %h\t\t %b", $time, rst_n, write_en, addr, data_in, data_out, ready);
		// 1. Release active-low reset
		#15 rst_n = 1;
		// 2. Write 0xAA to Address 4
		#10;
		write_en = 1;
		addr = 4'h4;
		data_in = 8'hAA;
 	 // 3. Write 0x55 to Address 9
		#10;
		addr = 4'h9;
		data_in = 8'h55;
		// 4. Disable write mode (Switch to Read mode)
		#10;
		write_en = 0;
		// 5. Read back from Address 4 (Expected: AA)
		addr = 4'h4;
		// 6. Read back from Address 9 (Expected: 55)
		#10;
		addr = 4'h9;
		// Finish simulation
		#20;
		$finish;
	end
	// Dump waveform data for EDA Playground visualization
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(0, tb_memory_controller);
	end
endmodule
