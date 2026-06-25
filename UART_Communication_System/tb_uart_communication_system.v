`timescale 1ns/1ps

module uart_tb;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire tx_busy;
wire [7:0] rx_data;
wire rx_done;

//--------------------------------------
// UART TRANSMITTER
//--------------------------------------
uart_tx transmitter (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

//--------------------------------------
// UART RECEIVER
//--------------------------------------
uart_rx receiver (
    .clk(clk),
    .rst(rst),
    .rx(tx),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

//--------------------------------------
// CLOCK GENERATION (10 ns)
//--------------------------------------
always #5 clk = ~clk;

//--------------------------------------
// VCD FILE
//--------------------------------------
initial begin
    $dumpfile("uart.vcd");
    $dumpvars(0, uart_tb);
end

//--------------------------------------
// MONITOR SIGNALS
//--------------------------------------
initial begin
    $monitor(
        "Time=%0t | TX=%b | RX_Data=%h | RX_Done=%b | TX_Busy=%b",
        $time, tx, rx_data, rx_done, tx_busy
    );
end

//--------------------------------------
// TEST SEQUENCE
//--------------------------------------
initial begin

    clk      = 1'b0;
    rst      = 1'b1;
    tx_start = 1'b0;
    tx_data  = 8'h00;

    // Reset period
    #40;
    rst = 1'b0;

    // Allow stabilization
    #30;

    // Test data
    tx_data = 8'hA5;

    $display("UART Transmission Started");

    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;

    // Wait for reception
    wait(rx_done);

    $display("UART Reception Complete");
    $display("Received Data = %h", rx_data);

    #200;
    $finish;

end

endmodule
