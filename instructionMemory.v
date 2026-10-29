`timescale 1ns / 1ps
// byte-addressable instruction memory (ROM), little-endian.
// holds the Lab 10 FSM program (29 instructions = 116 bytes of the 256 available).
module instructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input      [OPERAND_LENGTH:0] instAddress,   // PC
    output reg [31:0]             instruction
);

    reg [7:0] memory [0:255];

    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;                    // unused space reads as 0
        $readmemh("instructions.mem", memory);   // one byte per line, lowest address first
    end

    // assemble 4 consecutive bytes (little-endian) into one 32-bit instruction.
    // only PC[7:2] is used: instructions are word-aligned and the ROM is 256 bytes.
    wire [7:0] base = {instAddress[7:2], 2'b00};

    always @(*) begin
        instruction = {memory[base + 8'd3],
                       memory[base + 8'd2],
                       memory[base + 8'd1],
                       memory[base]};
    end

endmodule

