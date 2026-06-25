module tb_alu_3bit_no_carry;

reg [2:0] A;
reg [2:0] B;
reg [2:0] opcode;

wire [2:0] result;
wire zero;

alu_3bit_no_carry uut (
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result),
    .zero(zero)
);

initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, tb_alu_3bit_no_carry);

    A = 3'b101; B = 3'b011; opcode = 3'b000; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b001; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b010; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b011; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b100; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b101; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b110; #10;
    A = 3'b101; B = 3'b011; opcode = 3'b111; #10;

    $finish;
end

endmodule
