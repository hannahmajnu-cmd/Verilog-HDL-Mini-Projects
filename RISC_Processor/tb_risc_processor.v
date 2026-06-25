module tb_risc_processor;

    reg clk;
    reg reset;
    wire [2:0] A_reg;
    wire [2:0] pc;

    // Instantiate Processor
    risc_processor uut (
        .clk(clk),
        .reset(reset),
        .A_reg(A_reg),
        .pc(pc)
    );

    // Clock Generation (10 ns Period)
    always #5 clk = ~clk;

    initial begin

        // Generate VCD Dump File
        $dumpfile("risc_processor.vcd");
        $dumpvars(0, tb_risc_processor);

        // Initialize Signals
        clk = 0;
        reset = 1;

        #12;
        reset = 0;

        $display("Time | PC  | Instruction(Op_Imm) | A_reg");
        $display("-----------------------------------------");

        $monitor("%4t | %b | %b_%b | %b",
                 $time,
                 pc,
                 uut.opcode,
                 uut.operand,
                 A_reg);

        // Run for 6 clock cycles
        #60;

        $finish;
    end

endmodule
