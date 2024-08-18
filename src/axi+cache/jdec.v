`include "defines.vh"
module jdec(
        input wire [5:0] op,        // 前六位
        input wire [5:0] funct,     // 后六位
        output wire jsave,
        output wire save_in_rd,
        output wire jump_to_rs_val
    );
        assign jsave = ~|(op ^ `EXE_JAL) | (~|op & ~|(funct ^ `EXE_JALR));  // jal or jalr
        assign save_in_rd = ~|op & ~|(funct ^ `EXE_JALR);
        assign jump_to_rs_val = (~|op & ~|(funct ^ `EXE_JR)) | (~|op & ~|(funct ^ `EXE_JALR));  // jr or jalr
endmodule
