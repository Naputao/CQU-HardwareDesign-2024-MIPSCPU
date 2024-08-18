`timescale 1ns / 1ps

module datapath(
    input wire clk, rst,
    input wire [5:0] ext_int,
    input wire hiRegWrite, loRegWrite,
    input wire branch, jump, regdst, regwrite, isUnsignExt,
    input wire id_is_break, id_is_syscall, priorControl, id_is_unfinished,
    input wire [3:0] memwrite,
    input wire [1:0] alusrc,
    input wire [1:0] saveReg,
    input wire [2:0] regfrom,
    input wire [4:0] alucontrol,
    input wire [31:0] instrF,
    input wire [31:0] ReadData,
    output wire [31:0] pc,
    output wire [31:0] alu_result,
    output wire [31:0] WriteData,
    output wire [5:0] functD, opD,
    output wire [3:0] MemWrite,
    output wire mem_en
);

    wire [31:0] hiWriteData, loWriteData;
    wire hiRegWriteE, loRegWriteE;
    wire [31:0] pcD, pcE, pcM, pcW;
    wire [31:0] pc2, pc_4, rd1, rd2, SignImm, signIm, unsignIm, pc_8, pc_branch;
    wire [31:0] imsl2, pc_jump0, pc_jump;
    wire [31:0] instrD, PCPlus4D, PCBranchD, SrcAE, SrcBE, SrcBM, WriteDataE, SrcRs,SrcSa,SignImmE, ALUOutE, pc_8E, pc_8M, pc_8W; //SrcRt,SrcSa
    wire [31:0] ALUOutM, WriteDataM, ResultW, ALUOutW, ReadDataW;
    wire [4:0] RsD, RtD, RdD, RsE, RtE, RdE, RdM, RdW, WriteRegE, WriteRegM, WriteRegW;
    wire RegWriteE, RegDstE;
    wire [3:0] MemWriteE,MemWriteM;
    wire [2:0] RegFromE, RegFromM, RegFromW;
    wire [4:0] SaE, SaD; //用于sa指令
    wire [4:0] ALUControlE;
    wire RegWriteM, RegWriteW;
    wire PCSrcD, PCSrcE, bsave, bsaveE, bsaveM, bsaveW, jsave, jsaveE, jsaveM, jsaveW;
    wire save_in_rd, save_in_rdE, save_in_rdM, save_in_rdW, jump_to_rs_val;
    wire [2:0] ForwardAD, ForwardBD;
    wire [1:0] ForwardAE, ForwardBE, ALUSrcE;
    wire [31:0] Rd1E, Rd2E, h1, h2;
    wire [31:0] data_out_HI, data_out_LO, data_out_HIM, data_out_LOM, data_out_HIW, data_out_LOW;
    wire [1:0]saveRegE,saveRegM;
    wire jumpE;
    wire StallF, StallD, StallE, StallM,FlushD, FlushE,FlushM;
    wire id_is_breakE, id_is_syscallE, id_is_breakM, id_is_syscallM, id_is_unfinishedE, id_is_unfinishedM;
    wire id_is_eret, id_is_eretE, id_is_eretM;
    wire id_is_mfc0, id_is_mfc0E, id_is_mfc0M;
    wire id_is_mtc0, id_is_mtc0E, id_is_mtc0M;
    wire pc_trap;  //m阶段传来的异常信号，要跳转到异常处理程序
    wire [31:0] epc_reg;  //存储异常返回地址
    wire pc_errorD, pc_errorE, pc_errorM;

    mux2 #(32) mux_jump(
        .a(h1),  //寄存器里的值
        .b(pc_jump0),  //一般跳转地址
        .s(jump_to_rs_val),  //是否跳转至寄存器里的值
        .y(pc_jump)
    );

    pc2_ctrl pc2_ctrl(
        .pc_4(pc_4),
        .pc_branchD(PCBranchD),
        .pc_jD(pc_jump),
        .epc(epc_reg),
        .is_pc_branch(PCSrcD),
        .is_pc_jump(jump),
        .is_pc_exception(pc_trap),
        .is_pc_eret(id_is_eret),
        .pc2(pc2)
    );

    PC PC(
        .clk(clk),
        .rst(rst),
        .en(~StallF),
        .d(pc2),
        .q(pc)
    );

    adder adder(
        .a(pc),
        .b(32'd4),
        .y(pc_4)
    );

    wire jump_deley, branch_delay;

    //IF-ID
    flopenrc#(32) r1(clk, rst, ~StallD, FlushD, pc_4, PCPlus4D);
    flopenrc#(32) r2(clk, rst, ~StallD, FlushD, instrF, instrD);
    flopenrc#(32) pc0(clk, rst, ~StallD, FlushD, pc, pcD);
    flopenrc#(1) dl1(clk, rst, ~StallD, FlushD, jump, jump_deley);
    flopenrc#(1) dl2(clk, rst, ~StallD, FlushD, branch, branch_delay);

    wire is_in_delayslot, is_in_delayslotE, is_in_delayslotM;
    assign is_in_delayslot = jump_deley | branch_delay;

    assign pc_jump0 = {PCPlus4D[31:28], instrD[25:0], 2'b00}; //jump一般跳转地址(后面要根据是否跳转至寄存器里的值做进一步判断)
    assign RsD = instrD[25:21];
    assign RtD = instrD[20:16];
    assign RdD = instrD[15:11];
    assign opD = instrD[31:26];
	assign functD = instrD[5:0];
    assign SaD = instrD[10:6];
    wire id_is_br_sysD, id_is_br_sysEn;
    assign id_is_br_sysD = id_is_break | id_is_syscall;

    wire [5:0] opE, opM;
    wire [5:0] functE, functM;

    assign pc_errorD = |(pcD[1:0] ^ 2'b00);  //pc是否字节对齐

    priordec priordec(
        .priorControl(priorControl),
        .instrD(instrD),
        .id_is_eret(id_is_eret),
        .id_is_mfc0(id_is_mfc0),
        .id_is_mtc0(id_is_mtc0)
    );

    adder pc_b(
        .a(PCPlus4D),
        .b(imsl2),
        .y(PCBranchD)  // 分支跳转地址在Ex阶段
    );

    adder pc_add8(
        .a(PCPlus4D),
        .b(32'd4),
        .y(pc_8)  // 分支跳转地址在Ex阶段
    );
    
    signext signext(
        .a(instrD[15:0]),
        .y(signIm)  //16位有符号扩展
    );

    sl2 sl2(
        .a(signIm),
        .y(imsl2)  //扩展后左移两位
    );

    unsignext unsignext(
        .a(instrD[15:0]),
        .y(unsignIm)  //0扩展
    );

    // 有符号扩展or无符号扩展isUnsignExt
    mux2 #(32) mux_writedata(
        .a(unsignIm),
        .b(signIm),
        .s(isUnsignExt),
        .y(SignImm)
    );

    regfile regfile(
        .clk(clk),
        .we3((RegWriteW | bsaveW | jsaveW | id_is_mfc0W) & ~exception_flushW),
        .ra1(RsD),
        .ra2(RtD),
        .wa3(WriteRegW),
        .wd3(ResultW),
        .rd1(rd1),
        .rd2(rd2)
    );

    // 加一个从m阶段pc+8的前推（当为10时，推的是之前跳转指令存的的pc+8）
    // 加一个从E阶段推过来的cp寄存器值
    mux8 #(32) mux_h1(
        .d0(rd1),
        .d1(ALUOutM),
        .d2(pc_8M),
        .d3(cp0_rdataM),
        .d4(cp0_rdataE),
        .s(ForwardAD),
        .y(h1)
    );

    mux8 #(32) mux_h2(
        .d0(rd2),
        .d1(ALUOutM),
        .d2(pc_8M),
        .d3(cp0_rdataM),
        .d4(cp0_rdataE),
        .s(ForwardBD),
        .y(h2)
    );

    branchdec branchdec(
        .op(opD),
        .funct(RtD),
        .branch(branch),
        .h1(h1),
        .h2(h2),
        .pcsrc(PCSrcD),
        .bsave(bsave)
    );

    jdec jdec(
        .op(opD),
        .funct(functD),
        .jsave(jsave),
        .save_in_rd(save_in_rd),
        .jump_to_rs_val(jump_to_rs_val)
    );

    //ID-EX
    wire [31:0] h1E;
    wire [31:0] h2E;
    flopenrc#(1) eretDE(~clk, rst, ~StallE, FlushE, id_is_eret ,id_is_eretE);
    flopenrc#(32) r3(clk, rst, ~StallE, FlushE, h1, h1E);
    flopenrc#(32) r4(clk, rst, ~StallE, FlushE, h2, h2E);
    flopenrc#(5) r5(clk, rst, ~StallE, FlushE, RsD, RsE);
    flopenrc#(5) r6(clk, rst, ~StallE, FlushE, RtD, RtE);
    flopenrc#(5) r7(clk, rst, ~StallE, FlushE, RdD, RdE);
    flopenrc#(32) r8(clk, rst, ~StallE, FlushE, SignImm, SignImmE);
    flopenrc#(5) r9(clk, rst, ~StallE, FlushE, SaD, SaE); //Sa
    flopenrc#(32) pc8(clk, rst, ~StallE, FlushE, pc_8, pc_8E);
    flopenrc#(1) bs1(clk, rst, ~StallE, FlushE, bsave, bsaveE);
    flopenrc#(1) js(clk, rst, ~StallE, FlushE, jsave, jsaveE);
    flopenrc#(1) sid1(clk, rst, ~StallE, FlushE, save_in_rd, save_in_rdE);
    flopenrc#(32) pc1(clk, rst, ~StallE, FlushE, pcD, pcE);
    flopenrc#(1) s1(clk, rst, ~StallE, FlushE, regwrite, RegWriteE);
    flopenrc#(3) s2(clk, rst, ~StallE, FlushE, regfrom, RegFromE);
    flopenrc#(4) s3(clk, rst, ~StallE, FlushE, memwrite, MemWriteE);
    flopenrc#(5) s5(clk, rst, ~StallE, FlushE, alucontrol, ALUControlE);
    flopenrc#(2) s6(clk, rst, ~StallE, FlushE, alusrc, ALUSrcE);
    flopenrc#(1) s7(clk, rst, ~StallE, FlushE, regdst, RegDstE);
    flopenrc#(1) hi(clk, rst, ~StallE, FlushE, hiRegWrite, hiRegWriteE);
    flopenrc#(1) lo(clk, rst, ~StallE, FlushE, loRegWrite, loRegWriteE);
    flopenrc#(2) r24(clk, rst, ~StallE, FlushE, saveReg, saveRegE);
    flopenrc#(1) jump1(~clk, rst, ~StallE, FlushE, jump, jumpEn);
    flopenrc#(1) pcsrc1(~clk, rst, ~StallE, FlushE, PCSrcD, PCSrcEn);
    flopenrc#(1) dl3(clk, rst, ~StallE, FlushE, is_in_delayslot, is_in_delayslotE);
    flopenrc#(1) brsys1(~clk, rst, ~StallE, FlushE, id_is_br_sysD, id_is_br_sysEn);
    flopenrc#(1) pcerror1(clk, rst, ~StallE, FlushE, pc_errorD, pc_errorE);
    flopenrc#(1) id_is_mfc0_1(clk, rst, ~StallE, FlushE, id_is_mfc0, id_is_mfc0E);
    flopenrc#(6) op1(clk, rst, ~StallE, FlushE, opD, opE);
    flopenrc#(6) funct1(clk, rst, ~StallE, FlushE, functD, functE);
    flopenrc#(1) id_is_break1(clk, rst, ~StallE, FlushE, id_is_break, id_is_breakE);
    flopenrc#(1) id_is_syscall1(clk, rst, ~StallE, FlushE, id_is_syscall, id_is_syscallE);
    flopenrc#(1) id_is_unfinished1(clk, rst, ~StallE, FlushE, id_is_unfinished, id_is_unfinishedE);
    flopenrc#(1) id_is_mtc01(clk, rst, ~StallE, FlushE, id_is_mtc0, id_is_mtc0E);

    wire id_is_br_sysE;
    assign id_is_br_sysE = id_is_breakE | id_is_syscallE;

    wire [4:0] writeRdRt;

    //多路选择器选择寄存器堆A3端口(EX阶段)
    mux2 #(5) mux_wa3E(
        .a(RdE),
        .b(RtE),
        .s(RegDstE),  //regdst控制信号
        .y(writeRdRt)  // 写入Rd或Rt的那个寄存器
    );

    mux2 #(5) mux_wa3E2(
        .a(5'b11111),  // 写入31号寄存器
        .b(writeRdRt),  // 写入Rd或Rt的那个寄存器
        .s(bsaveE | (~save_in_rdE & jsaveE)),  //bsave或jsave控制信号（当bsave只能存在31号寄存器，jsave要分情况）
        .y(WriteRegE)
    );
    
    //多路选择器�?�择操作数B
    mux2 #(32) mux_alusrcB(
        .a(SignImmE),
        .b(WriteDataE),
        .s(ALUSrcE[0]),  //alusrc控制信号
        .y(SrcBE)
    );

    assign SrcSa = {27'b0, SaE};
    
    mux2 #(32) mux_alusrcA(
        .a(SrcSa),
        .b(SrcRs),
        .s(ALUSrcE[1]),  //alusrc控制信号
        .y(SrcAE)
    );

    //三选一多路选择器 -> 四选一：新增一个pc+8的选择
    mux4 #(32) mux_AluA(h1E, ResultW, ALUOutM, pc_8M, ForwardAE, SrcRs);
    mux4 #(32) mux_AluB(h2E, ResultW, ALUOutM, pc_8M, ForwardBE, WriteDataE);

    wire overflowE, overflowM;  //add, addi, sub溢出信号

    alu ALU(
        .A(SrcAE),
        .B(SrcBE),
        .control(ALUControlE),
        .out(ALUOutE),
        .overflow(overflowE)
    );
    
    wire mult_divM;
    wire [63:0] multResultM, divResultM,multResult, divResult;
    wire mult_div_alu_hiRegWrite,mult_div_alu_loRegWrite;
    mul_div_alu mul_div_alu(
        .clk(clk),
        .rst(rst),
        .hiRegWrite(hiRegWrite),
        .loRegWrite(loRegWrite),
        .alucontrol(alucontrol),
        .SrcAE(SrcAE),
        .SrcBE(SrcBE),
        .divResult(divResult),
        .multResult(multResult),
        .exception_flushM(exception_flushM),
        .mult_div_start(mult_div_start),
        .mult_div_alu_hiRegWriteM(mult_div_alu_hiRegWriteM),
        .mult_div_alu_loRegWriteM(mult_div_alu_loRegWriteM),
        .mult_divM(mult_divM)
    );
    
    //HILOcontroller
    mux4 #(32) mux_HI(
        .d3(divResultM[63:32]),
        .d2(multResultM[63:32]),
        .d1(SrcAE),
        .d0(SrcAE),
        .s({~hiRegWriteE, mult_divM}),
        .y(hiWriteData)
    );
    
    mux4 #(32) mux_LO(
        .d3(divResultM[31:0]),
        .d2(multResultM[31:0]),
        .d1(SrcAE),
        .d0(SrcAE),
        .s({~loRegWriteE, mult_divM}),
        .y(loWriteData)
    );
    
    // HI Reg
    HI_Register HI_Register(
        .clk(~clk),
        .rst(rst),
        .data_in(hiWriteData),
        .hi_reg_write((hiRegWriteE | mult_div_alu_hiRegWriteM) & ~exception_flushM),
        .data_out_HI(data_out_HI)
    );

    // LO Reg
    HI_Register LO_Register(
        .clk(~clk),
        .rst(rst),
        .data_in(loWriteData),
        .hi_reg_write((loRegWriteE | mult_div_alu_loRegWriteM) & ~exception_flushM),
        .data_out_HI(data_out_LO)
    );

    // TODO: CP0
    wire cp0_en, cp0_we;
    wire [4:0] cp0_waddr, cp0_raddrE;
    wire [31:0] cp0_wdata, cp0_rdataE;
    // 写CP0
    assign cp0_we = id_is_mtc0M;
    assign cp0_waddr = RdM;
    assign cp0_wdata = SrcBM;
    // 读CP0
    assign cp0_raddrE = RdE;
    // 异常检测要用到里面的寄存器的值
    wire [31:0] status_reg, cause_reg;

    wire [31:0] badvaddrM;  //地址异常时的地址从M阶段传来
    wire [4:0] exception_codeM;
    wire exception_flushM, exception_flushW;
    assign cp0_en = exception_flushM;

    CP0 CP0_Register(
        .clk(~clk),
        .rst(rst),
        .en(cp0_en),
        .we(cp0_we),
        .waddr(cp0_waddr),
        .wdata(cp0_wdata),
        .raddr(cp0_raddrE),
        .rdata(cp0_rdataE),  //读出来的数据
        .is_in_delayslot(is_in_delayslotM),
        // .current_inst_addr(|(exception_codeM ^ 5'b0) ? pcM : pcMx),  //如果是中断异常，则使用不阻塞的pcMx（因为exceptionM会使当前阻塞一周期）
        .current_inst_addr(pcMx), //如果是异常，则使用不阻塞的pcMx（因为exceptionM会使当前阻塞一周期）
        .badvaddr_i(badvaddrM),
        .except_type(exception_codeM),
        .status(status_reg),  //M
        .cause(cause_reg),  //M
        .epc(epc_reg),
        .timer_interrupt(timer_interrupt)
    );

    wire [31:0] cp0_rdataM, cp0_rdataW;
    wire [31:0] pcMx;

    //Ex-Mem
    flopenrc#(32) pc21x(clk, rst, ~StallM , 1'b0, pcE, pcMx);  //没有被阻塞的pcM  MAGIC
    flopenrc#(32) pc21(clk, rst, ~StallM , FlushM, pcE, pcM);
    flopenrc#(64) r11(clk, rst, ~StallM , FlushM, divResult, divResultM);
    flopenrc#(64) r21(clk, rst, ~StallM , FlushM, multResult, multResultM);
    flopenrc#(32) r10(clk, rst, ~StallM , FlushM, ALUOutE, ALUOutM);
    flopenrc#(32) r12(clk, rst, ~StallM , FlushM, WriteDataE, WriteDataM);
    flopenrc#(5) r14(clk, rst, ~StallM , FlushM, WriteRegE, WriteRegM);
    flopenrc#(1) bs2(clk, rst, ~StallM , FlushM, bsaveE, bsaveM);
    flopenrc#(1) js2(clk, rst, ~StallM , FlushM, jsaveE, jsaveM);
    flopenrc#(1) sid2(clk, rst, ~StallM , FlushM, save_in_rdE, save_in_rdM);
    flopenrc#(5) s100(clk, rst, ~StallM , FlushM, RdE, RdM);
    flopenrc#(1) s8(clk, rst, ~StallM , FlushM, RegWriteE, RegWriteM);
    flopenrc#(3) s9(clk, rst, ~StallM , FlushM, RegFromE, RegFromM);
    flopenrc#(4) s10(clk, rst, ~StallM , FlushM, MemWriteE, MemWriteM);
    flopenrc#(32) hi2(clk, rst, ~StallM , FlushM, data_out_HI, data_out_HIM);
    flopenrc#(32) lo2(clk, rst, ~StallM , FlushM, data_out_LO, data_out_LOM);
    flopenrc#(32) pc8_2(clk, rst, ~StallM , FlushM, pc_8E, pc_8M);
    flopenrc#(2) r25(clk, rst, ~StallM , FlushM, saveRegE, saveRegM);
    flopenrc#(1) dl4(clk, rst, ~StallM , FlushM, is_in_delayslotE, is_in_delayslotM);
    flopenrc#(32) SrcB_EM(clk, rst, ~StallM , FlushM, SrcBE, SrcBM);
    flopenrc#(1) of(clk, rst, ~StallM , FlushM, overflowE, overflowM);
    flopenrc#(1) pcerror2(clk, rst, ~StallM , FlushM, pc_errorE, pc_errorM);
    flopenrc#(32) cp0data1(clk, rst, ~StallM , FlushM, cp0_rdataE, cp0_rdataM);
    flopenrc#(1) id_is_mfc0_2(clk, rst, ~StallM , FlushM, id_is_mfc0E, id_is_mfc0M);
    flopenrc#(6) op2(clk, rst, ~StallM , FlushM, opE, opM);
    flopenrc#(6) funct2(clk, rst, ~StallM , FlushM, functE, functM);
    flopenrc#(1) id_is_break2(clk, rst, ~StallM , FlushM, id_is_breakE, id_is_breakM);
    flopenrc#(1) id_is_syscall2(clk, rst, ~StallM , FlushM, id_is_syscallE, id_is_syscallM);
    flopenrc#(1) id_is_unfinished2(clk, rst, ~StallM , FlushM, id_is_unfinishedE, id_is_unfinishedM);
    flopenrc#(1) id_is_mtc02(clk, rst, ~StallM , FlushM, id_is_mtc0E, id_is_mtc0M);

    // 判断溢出异常
    wire add_sub_overflowM;
    assign add_sub_overflowM = overflowM & ((opM == 6'b000000 & functM == 6'b100000) | (opM == 6'b001000) | (opM == 6'b000000 & functM == 6'b100010)); 
    // 判断地址异常
    wire addr_error_lwM, addr_error_swM;
    addr_error_detect addr_error_detect(
        .opM(opM),
        .addrM(ALUOutM),
        .addr_error_lw(addr_error_lwM),
        .addr_error_sw(addr_error_swM)
    );

    assign mem_en = ~addr_error_lwM & ~addr_error_swM;
    
    exception exception_module(
        .ext_int(ext_int),
        .ov(add_sub_overflowM),
        .pc_error(pc_errorM),
        .addr_error_lw(addr_error_lwM),
        .addr_error_sw(addr_error_swM),
        .sys(id_is_syscallM),
        .bp(id_is_breakM),
        .ri(id_is_unfinishedM),
        .status(status_reg),
        .cause(cause_reg),
        .pcM(pcM),
        .ALUOutM(ALUOutM),
        .exception_code(exception_codeM),
        .exception_flush(exception_flushM),
        .pc_trap(pc_trap),
        .badvaddrM(badvaddrM)
    );

    // 00:no | 01:w | 10:b | 11:h
    wire [31:0] WriteDataM_sb;
    assign WriteDataM_sb=WriteDataM[7:0] << {ALUOutM[1:0],3'b0};
    wire [31:0] WriteDataM_sh;
    assign WriteDataM_sh = WriteDataM[15:0] << {ALUOutM[1],4'b0};
    mux4 mux_saveReg(
        .d0(32'b0000_0000),
        .d1(WriteDataM),
        .d2(WriteDataM_sb),
        .d3(WriteDataM_sh),
        .s(saveRegM),
        .y(WriteData)
    );
    assign MemWrite = (MemWriteM << ALUOutM[1:0]) & {4{~exception_flushM}};

    //Mem-WB
    flopenr#(32) pc3(clk, rst, 1'b1, pcM, pcW);
    flopenr#(32) r15(clk, rst, 1'b1, ALUOutM, ALUOutW);
    flopenr#(32) r16(clk, rst, 1'b1, ReadData, ReadDataW);
    flopenr#(5) r17(clk, rst, 1'b1, WriteRegM, WriteRegW);
    flopenr#(1) bs3(clk, rst, 1'b1, bsaveM, bsaveW);
    flopenr#(1) js3(clk, rst, 1'b1, jsaveM, jsaveW);
    flopenr#(1) sid3(clk, rst, 1'b1, save_in_rdM, save_in_rdW);
    flopenr#(5) s101(clk, rst, 1'b1, RdM, RdW);
    flopenr#(1) s12(clk, rst, 1'b1, RegWriteM, RegWriteW);
    flopenr#(3) s13(clk, rst, 1'b1, RegFromM, RegFromW);
    flopenr#(32) hi3(clk, rst, 1'b1, data_out_HIM, data_out_HIW);
    flopenr#(32) lo3(clk, rst, 1'b1, data_out_LOM, data_out_LOW);
    flopenr#(32) pc8_3(clk, rst, 1'b1, pc_8M, pc_8W);
    flopenr#(32) cp0data2(clk, rst, 1'b1, cp0_rdataM, cp0_rdataW);
    flopenr#(1) id_is_mfc0_3(clk, rst, 1'b1, id_is_mfc0M, id_is_mfc0W);
    flopenr#(1) id_is_mfc0_XXXXX(clk, rst, 1'b1, exception_flushM, exception_flushW);
    wire [31:0] preResultW, ResultW0;
    //000:aluout|001:lw|011:mflo|010:mfhi|100:lb|101:lbu|110:lh|111:lhu
    //memtoreg
    wire [31:0] ReadDataW_sb; 
    assign ReadDataW_sb = ReadDataW>>{ALUOutW[1:0],3'b0};
    wire [31:0] ReadDataW_sh;
    assign ReadDataW_sh = ReadDataW>>{ALUOutW[1],4'b0};
    mux8 #(32) mux_reg(
        .d0(ALUOutW),
        .d1(ReadDataW),
        .d2(data_out_HIW),
        .d3(data_out_LOW),
        .d4({{24{ReadDataW_sb[7]}}, ReadDataW_sb[7:0]}),
        .d5({24'b0, ReadDataW_sb[7:0]}),
        .d6({{16{ReadDataW_sh[15]}}, ReadDataW_sh[15:0]}),
        .d7({16'b0, ReadDataW_sh[15:0]}),
        .s(RegFromW),  //RegFromW控制信号
        .y(preResultW)
    );

    mux2 #(32) mux_writedataM(
        .a(pc_8W),
        .b(preResultW),
        .s(bsaveW | jsaveW),  // 如果是psave、jsave要用pc+8
        .y(ResultW0)
    );

    mux2 #(32) mux_writedataM2(
        .a(cp0_rdataW),
        .b(ResultW0),
        .s(id_is_mfc0W),  // 如果是mfc0要用cp0读出来的数据
        .y(ResultW)
    );

    hazard hazard(
        .regfrom(regfrom),
        .RegFromE(RegFromE),
        .RegFromM(RegFromM),
        .divStart(mult_div_start),
        .RsD(RsD),
        .RtD(RtD),
        .RsE(RsE),
        .RtE(RtE),
        .RdE(RdE),
        .RdM(RdM),
        .RdW(RdW),
        .WriteRegM(WriteRegM),
        .WriteRegW(WriteRegW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .StallE(StallE),
        .StallM(StallM),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .FlushM(FlushM),
        .ForwardAD(ForwardAD),
        .ForwardBD(ForwardBD),
        .RegWriteE(RegWriteE),
        .WriteRegE(WriteRegE),
        .BranchD(branch),
        .jumpE(jumpEn),
        .bsaveM(bsaveM),
        .bsaveW(bsaveW),
        .jsaveM(jsaveM),
        .jsaveW(jsaveW),
        .save_in_rdM(save_in_rdM),
        .save_in_rdW(save_in_rdW),
        .PCSrcD(PCSrcD),
        .PCSrcE(PCSrcEn),
        .jump_to_rs_valD(jump_to_rs_val),
        .hiRegWriteE(hiRegWriteE),
        .loRegWriteE(loRegWriteE),
        .id_is_br_sysE(id_is_br_sysEn),
        .exceptionM(exception_flushM),
        .id_is_br_sysD(id_is_br_sysD),
        .id_is_mfc0E(id_is_mfc0E),
        .id_is_mtc0M(id_is_mtc0M),
        .exception_flushM(exception_flushM),
        .id_is_eretE(id_is_eretE),
        .exception_codeM(exception_codeM),
        .id_is_mfc0M(id_is_mfc0M)
    );

    assign alu_result = ALUOutM; //接出去给dataram
endmodule