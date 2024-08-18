`include "defines.vh"
module branchdec(
        input wire [5:0] op,
        input wire [4:0] funct,   //不是后六位
        input wire branch,
        input wire [31:0] h1,
        input wire [31:0] h2,
        output wire is_branch,   //判断是否跳转
        output wire bsave
    );
        wire op_eq_one = ~|(op ^ 6'b000001);
        wire equal = ~|(h1 ^ h2);
        wire rsltzero = h1[31];
        wire rseqzero = ~|h1;
        wire tmp = (~|(op ^ `EXE_BEQ ) & equal) |                         // beq
                   (~|(op ^ `EXE_BNE ) & ~equal) |                        // bne
                   (~|(op ^ `EXE_BLEZ) & (rsltzero | rseqzero)) |         // blez: rs小于等于0
                   (~|(op ^ `EXE_BGTZ) & ~(rsltzero | rseqzero)) |        // bgtz: rs大于0
                   (op_eq_one & ~|(funct ^ `EXE_BLTZ) & rsltzero) |  // bltz: rs小于0
                   (op_eq_one & ~|(funct ^ `EXE_BGEZ) & ~rsltzero) | // bgez: rs大于等于0
                   (op_eq_one & ~|(funct ^ `EXE_BLTZAL) & rsltzero) |  // bltzal: rs小于0
                   (op_eq_one & ~|(funct ^ `EXE_BGEZAL) & ~rsltzero);  // bgezal: rs大于等于0
        assign is_branch = branch & tmp;
        assign bsave = (op_eq_one & ~|(funct ^ `EXE_BLTZAL)) |  // bltzal
                       (op_eq_one & ~|(funct ^ `EXE_BGEZAL));   // bgezal
endmodule
