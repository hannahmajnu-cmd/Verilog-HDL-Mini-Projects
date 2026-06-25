 module risc_processor (
    input clk,
    input reset,
    output reg [2:0] A_reg,    // Accumulator Register
    output reg [2:0] pc        // Program Counter
);

    wire [5:0] instruction;
    wire [2:0] opcode;
    wire [2:0] operand;
    reg  [2:0] alu_result;

    // Split instruction into Opcode and Operand
    assign opcode  = instruction[5:3];
    assign operand = instruction[2:0];

    // Instruction Memory (Hardcoded Program)
    assign instruction =
        (pc == 3'b000) ? 6'b000_011 : // ADD 3
        (pc == 3'b001) ? 6'b000_010 : // ADD 2
        (pc == 3'b010) ? 6'b001_001 : // SUB 1
        (pc == 3'b011) ? 6'b100_101 : // XOR 5
        (pc == 3'b100) ? 6'b111_000 : // SHR
                         6'b010_000 ; // AND 0

    // ALU
    always @(*) begin
        case (opcode)
            3'b000: alu_result = A_reg + operand; // ADD
            3'b001: alu_result = A_reg - operand; // SUB
            3'b010: alu_result = A_reg & operand; // AND
            3'b011: alu_result = A_reg | operand; // OR
            3'b100: alu_result = A_reg ^ operand; // XOR
            3'b101: alu_result = ~A_reg;          // NOT
            3'b110: alu_result = A_reg << 1;      // SHL
            3'b111: alu_result = A_reg >> 1;      // SHR
            default: alu_result = 3'b000;
        endcase
    end

    // Write Back + PC Update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc    <= 3'b000;
            A_reg <= 3'b000;
        end
        else begin
            pc    <= pc + 1'b1;
            A_reg <= alu_result;
        end
    end

endmodule


