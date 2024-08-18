module addr_error_detect(
    input wire [6:0] ls_segsM,
    input wire [31:0] addrM,
    output wire addr_error_lw, addr_error_sw,

    // output wire [31:0] data_from_mem,
    output wire [4:0] mem_we,
    output wire mem_en
);

    wire lw, sw, lh, sh, lhu;  //这五条要判断地址错误
    wire sb, lbu;
    assign {lbu, sb, lhu, sh, lw, sw, lh} = ls_segsM;

    wire addr_div_4, addr_div_2;
    assign addr_div_4 = ~|addrM[1:0];
    assign addr_div_2 = ~addrM[0];

    assign addr_error_lw = (lw & ~addr_div_4) | (lh & ~addr_div_2) | (lhu & ~addr_div_2);
    assign addr_error_sw = (sw & ~addr_div_4) | (sh & ~addr_div_2);

    //地址的后两位是什么
    wire one_one, one_zero, zero_one, zero_zero;
    assign one_one = &addrM[1:0];
    assign one_zero = ~|(addrM[1:0] ^ 2'b01);
    assign zero_one = ~|(addrM[1:0] ^ 2'b10);
    assign zero_zero = addr_div_4;

    assign mem_we = ({4{(sw & zero_zero)}} & 4'b1111)
                        | ({4{(sh & zero_zero)}} & 4'b0011)
                        | ({4{(sh & zero_one)}} & 4'b1100)
                        | ({4{(sb & zero_zero)}} & 4'b0001)
                        | ({4{(sb & zero_one)}} & 4'b0010)
                        | ({4{(sb & one_zero)}} & 4'b0100)
                        | ({4{(sb & one_one)}} & 4'b1000);
    assign mem_en = ~addr_error_lw & ~addr_error_sw;
endmodule
