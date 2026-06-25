module alu_3bit_no_carry (
    input [2:0] A,
    input [2:0] B,
    input [2:0] opcode,
    output reg [2:0] result,
    output zero
);

always @(*) begin
    case(opcode)
        3'b000: result = A + B;
        3'b001: result = A - B;
        3'b010: result = A & B;
        3'b011: result = A | B;
        3'b100: result = A ^ B;
        3'b101: result = ~A;
        3'b110: result = A << 1;
        3'b111: result = A >> 1;
    endcase
end

assign zero = (result == 3'b000);

endmodule
