module addr_error_detect(
    input wire [5:0] opM,
    input wire [31:0] addrM,
    output wire addr_error_lw, addr_error_sw
);

    wire lw, sw, lh, sh, lhu;
    assign lh = ~|(opM ^ 6'b100001);
    assign lhu = ~|(opM ^ 6'b100101);
    assign lw = ~|(opM ^ 6'b100011);
    assign sh = ~|(opM ^ 6'b101001);
    assign sw = ~|(opM ^ 6'b101011);

    wire addr_div_4, addr_div_2;
    assign addr_div_4 = ~|(addrM[1:0] ^ 2'b00);
    assign addr_div_2 = ~|(addrM[0] ^ 1'b0);

    assign addr_error_lw = (lw & ~addr_div_4) | (lh & ~addr_div_2) | (lhu & ~addr_div_2);
    assign addr_error_sw = (sw & ~addr_div_4) | (sh & ~addr_div_2);

endmodule
