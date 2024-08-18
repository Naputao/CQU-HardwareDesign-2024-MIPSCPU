`include "defines.vh"
module branchdec(
        input wire [5:0] op,
        input wire [4:0] funct,
        input wire branch,
        input wire [31:0] h1,
        input wire [31:0] h2,
        output wire pcsrc,
        output wire bsave
    );
        wire equal = h1 == h2;
        wire rsltzero = h1[31] == 1;
        wire rseqzero = h1 == 0;
        wire tmp = (op == `EXE_BEQ & equal) |                         // beq
                   (op == `EXE_BNE & ~equal) |                        // bne
                   (op == `EXE_BLEZ & (rsltzero | rseqzero)) |         // blez: rs小于等于0
                   (op == `EXE_BGTZ & ~(rsltzero | rseqzero)) |        // bgtz: rs大于0
                   (op == 6'b000001 & funct == `EXE_BLTZ & rsltzero) |  // bltz: rs小于0
                   (op == 6'b000001 & funct == `EXE_BGEZ & ~rsltzero) | // bgez: rs大于等于0
                   (op == 6'b000001 & funct == `EXE_BLTZAL & rsltzero) |  // bltzal: rs小于0
                   (op == 6'b000001 & funct == `EXE_BGEZAL & ~rsltzero);  // bgezal: rs大于等于0
        assign pcsrc = branch & tmp;
        assign bsave = (op == 6'b000001 & funct == `EXE_BLTZAL) |  // bltzal
                       (op == 6'b000001 & funct == `EXE_BGEZAL);   // bgezal
endmodule
