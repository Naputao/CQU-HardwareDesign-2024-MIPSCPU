`include "defines.vh"
module jdec(
        input wire [5:0] op,  // 前六位
        input wire [5:0] funct,  // 后六位
        output wire jsave,
        output wire save_in_rd,
        output wire jump_to_rs_val
    );
        assign jsave = op == `EXE_JAL | (op == 6'b000000 & funct == `EXE_JALR);  // jal or jalr
        assign save_in_rd = op == 6'b000000 & funct == `EXE_JALR ? 1'b1 : 1'b0;
        assign jump_to_rs_val = (op == 6'b000000 & funct == `EXE_JR) | (op == 6'b000000 & funct == `EXE_JALR);  // jr or jalr
endmodule
