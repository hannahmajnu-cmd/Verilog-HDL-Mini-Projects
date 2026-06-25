module uart_tx (
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx,
    output logic       tx_busy
);

    parameter CLKS_PER_BIT = 5208;

    typedef enum logic [1:0] {
        S_IDLE,
        S_START,
        S_DATA,
        S_STOP
    } state_t;

    state_t state;

    logic [7:0] tx_shift_reg;
    logic [2:0] bit_index;
    logic [12:0] baud_count;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= S_IDLE;
            tx           <= 1'b1;
            tx_busy      <= 1'b0;
            bit_index    <= 3'd0;
            baud_count   <= 13'd0;
            tx_shift_reg <= 8'd0;
        end
        else begin

            case (state)

                //--------------------------------------
                // IDLE STATE
                //--------------------------------------
                S_IDLE: begin
                    tx         <= 1'b1;
                    tx_busy    <= 1'b0;
                    baud_count <= 13'd0;

                    if (tx_start) begin
                        tx_shift_reg <= tx_data;
                        tx_busy      <= 1'b1;
                        state        <= S_START;
                    end
                end

                //--------------------------------------
                // START BIT
                //--------------------------------------
                S_START: begin
                    tx <= 1'b0;

                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 13'd0;
                        bit_index  <= 3'd0;
                        state      <= S_DATA;
                    end
                    else begin
                        baud_count <= baud_count + 13'd1;
                    end
                end

                //--------------------------------------
                // DATA BITS
                //--------------------------------------
                S_DATA: begin
                    tx <= tx_shift_reg[bit_index];

                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 13'd0;

                        if (bit_index == 3'd7)
                            state <= S_STOP;
                        else
                            bit_index <= bit_index + 3'd1;
                    end
                    else begin
                        baud_count <= baud_count + 13'd1;
                    end
                end

                //--------------------------------------
                // STOP BIT
                //--------------------------------------
                S_STOP: begin
                    tx <= 1'b1;

                    if (baud_count == CLKS_PER_BIT - 1) begin
                        baud_count <= 13'd0;
                        tx_busy    <= 1'b0;
                        state      <= S_IDLE;
                    end
                    else begin
                        baud_count <= baud_count + 13'd1;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule
module uart_rx (
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    parameter CLKS_PER_BIT = 5208;

    typedef enum logic [2:0] {
        RX_IDLE,
        RX_START,
        RX_DATA,
        RX_STOP,
        RX_DONE
    } state_t;

    state_t state;

    logic [12:0] baud_count;
    logic [2:0]  bit_index;
    logic [7:0]  rx_shift_reg;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            state        <= RX_IDLE;
            baud_count   <= 13'd0;
            bit_index    <= 3'd0;
            rx_shift_reg <= 8'd0;
            rx_data      <= 8'd0;
            rx_done      <= 1'b0;
        end
        else begin

            rx_done <= 1'b0;

            case(state)

            //--------------------------------------
            // IDLE STATE
            //--------------------------------------
            RX_IDLE: begin
                baud_count <= 13'd0;
                bit_index  <= 3'd0;

                if (rx == 1'b0) begin
                    rx_shift_reg <= 8'd0;
                    state <= RX_START;
                end
            end

            //--------------------------------------
            // START BIT
            //--------------------------------------
            RX_START: begin

                if (baud_count == (CLKS_PER_BIT/2)-1) begin

                    if (rx == 1'b0) begin
                        baud_count <= 13'd0;
                        state <= RX_DATA;
                    end
                    else begin
                        baud_count <= 13'd0;
                        state <= RX_IDLE;
                    end

                end
                else begin
                    baud_count <= baud_count + 13'd1;
                end
            end

            //--------------------------------------
            // RECEIVE DATA
            //--------------------------------------
            RX_DATA: begin

                if (baud_count == CLKS_PER_BIT-1) begin

                    baud_count <= 13'd0;

                    rx_shift_reg[bit_index] <= rx;

                    if (bit_index == 3'd7) begin
                        bit_index <= 3'd0;
                        state <= RX_STOP;
                    end
                    else begin
                        bit_index <= bit_index + 3'd1;
                    end

                end
                else begin
                    baud_count <= baud_count + 13'd1;
                end
            end

            //--------------------------------------
            // STOP BIT
            //--------------------------------------
            RX_STOP: begin

                if (baud_count == CLKS_PER_BIT-1) begin

                    baud_count <= 13'd0;

                    if (rx == 1'b1)
                        state <= RX_DONE;
                    else
                        state <= RX_IDLE;

                end
                else begin
                    baud_count <= baud_count + 13'd1;
                end
            end

            //--------------------------------------
            // DATA READY
            //--------------------------------------
            RX_DONE: begin

                rx_data <= rx_shift_reg;
                rx_done <= 1'b1;

                baud_count <= 13'd0;
                bit_index  <= 3'd0;

                state <= RX_IDLE;
            end

            default: begin
                state <= RX_IDLE;
            end

            endcase
        end
    end

endmodule
module uart_top (
    input  clk,
    input  rst,
    input  tx_start,
    input  [7:0] tx_data,
    output [7:0] rx_data,
    output rx_done,
    output tx_busy
);

wire serial_line;

uart_tx transmitter (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(serial_line),
    .tx_busy(tx_busy)
);

uart_rx receiver (
    .clk(clk),
    .rst(rst),
    .rx(serial_line),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

endmodule
