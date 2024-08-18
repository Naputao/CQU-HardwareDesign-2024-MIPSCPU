module exception(
    input wire [5:0] ext_int,
    input wire addr_error_lw,
    input wire pc_error,
    input wire addr_error_sw,
    input wire sys,
    input wire bp,
    input wire ri,
    input wire ov,

    input wire [31:0] status, cause,
    input wire [31:0] pcM, ALUOutM, //用来输出baddvaddrM

    output wire [4:0] exception_code,
    output wire exception_flush,
    output wire pc_trap,
    output wire [31:0] badvaddrM
);

    wire software_int, hardware_int, global_int_en, int_exception;
    assign global_int_en = status[0] & ~status[1];  //全局中断开启,且没有例外在处理
    assign hardware_int = |(status[15:10] & cause[15:10] & ext_int);  //硬件中断
    assign software_int = |(status[9:8] & cause[9:8]); //软件中断
    assign int_exception = global_int_en & (hardware_int | software_int);  //识别软件中断或者硬件中断
    assign exception_code = (int_exception) ? 5'b00000 :  //按照优先级依次判断
                            (pc_error) ? 5'b00100 :
                            (ri) ? 5'b01010 :
                            (ov) ? 5'b01100 :
                            (bp) ? 5'b01001 :
                            (sys) ? 5'b01000 :
                            (addr_error_lw) ? 5'b00100 :
                            (addr_error_sw) ? 5'b00101 :
                            5'b11111;

    assign exception_flush = ~exception_code[4];  //判断最高位是否为1
    assign pc_trap = ~exception_code[4];
    assign badvaddrM = pc_error ? pcM : ALUOutM;
endmodule
