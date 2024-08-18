module hazard(
    input wire id_is_eretE,
    input wire divStart, jumpE, PCSrcE,
    input wire [2:0] regfrom, RegFromE, RegFromM,
    input wire [4:0] RsD, RtD, RsE, RtE, RdE, RdM, RdW, WriteRegM, WriteRegW, WriteRegE,
    input wire RegWriteM, RegWriteW, BranchD, RegWriteE,
    input wire bsaveM, bsaveW, jsaveM, jsaveW,
    input wire save_in_rdM, save_in_rdW, PCSrcD, jump_to_rs_valD,
    input wire hiRegWriteE, loRegWriteE,
    input wire exceptionM, id_is_br_sysE, id_is_br_sysD,
    input wire id_is_mfc0E, id_is_mfc0M, id_is_mtc0M,
    input wire exception_flushM, exception_codeM,
    output wire [1:0] ForwardAE, ForwardBE,
    output wire [2:0] ForwardAD, ForwardBD,
    output wire StallF, StallD, StallE, StallM, FlushD, FlushE, FlushM
    );

    //前推到取寄存器值
    assign ForwardAD = (RsD == WriteRegE & id_is_mfc0E) ? 3'b100 :  // 前推mfc0刚在e阶段取到的cp0寄存器值
                       ((RsD == WriteRegM & id_is_mfc0M) ? 3'b011 :  // 前推mfc0刚在m阶段的cp0寄存器值（因为mfc0会阻塞一周期会出现上面的数据退推不出来）
                       ((RsD != 0 & ((bsaveM & RsD == 5'b11111) | (jsaveM & ((RsD == RdM & save_in_rdM) | (RsD == 5'b11111 & ~save_in_rdM))))) ? 3'b010 :
                       ((RsD != 0 & RsD == WriteRegM & RegWriteM) ? 3'b001 : 2'b000)));
    assign ForwardBD = (RtD == WriteRegE & id_is_mfc0E) ? 3'b100 :
                       ((RtD == WriteRegM & id_is_mfc0M) ? 3'b011 :
                       ((RtD != 0 & ((bsaveM & RtD == 5'b11111) | (jsaveM & ((RsD == RdM & save_in_rdM) | (RtD == 5'b11111 & ~save_in_rdM))))) ? 3'b010 :
                       ((RtD != 0 & RtD == WriteRegM & RegWriteM) ? 3'b001 : 3'b000)));

    //alu输入端前推信号：当11时前推刚才的保存的地址（PC+8）
    assign ForwardAE = (RsE != 0 & ((bsaveM & RsE == 5'b11111) | (jsaveM & ((RsE == RdM & save_in_rdM) | (RsE == 5'b11111 & ~save_in_rdM))))) ? 2'b11 :
                       ((RsE != 0 & ((RsE == WriteRegM & RegWriteM) | (hiRegWriteE & (RsE == WriteRegM)))) ? 2'b10 :  //上一条写的寄存器的值需要写入hi寄存器时，前推
                       ((RsE != 0 & ((RsE == WriteRegW & RegWriteW) | (RsE == 5'b11111 & bsaveW) | (((RsE == RdW & save_in_rdW) | (RsE == 5'b11111 & ~save_in_rdW)) & jsaveW))) ? 2'b01 : 2'b00));
    assign ForwardBE = (RtE != 0 & ((bsaveM & RtE == 5'b11111) | (jsaveM & ((RtE == RdM & save_in_rdM) | (RtE == 5'b11111 & ~save_in_rdM))))) ? 2'b11 :
                       ((RtE != 0 & ((RtE == WriteRegM & RegWriteM) | (hiRegWriteE & (RtE == WriteRegM)))) ? 2'b10 :
                       ((RtE != 0 & ((RtE == WriteRegW & RegWriteW) | (RtE == 5'b11111 & bsaveW) | (((RtE == RdW & save_in_rdW) | (RtE == 5'b11111 & ~save_in_rdW)) & jsaveW))) ? 2'b01 : 2'b00));

    wire mfc0stall;
    wire lwstall, branchstall, jrstall, divstall, cp0to_from_stall;  //阻塞信号
    wire MemtoRegE, MemtoRegM;
    assign MemtoRegE = RegFromE[0] | RegFromE[1] | RegFromE[2];
    assign MemtoRegM = RegFromM[0] | RegFromM[1] | RegFromM[2];
    
    assign lwstall = (RtD != 0) & ((RsD == RtE) | (RtD == RtE)) & MemtoRegE;
    assign jrstall = jump_to_rs_valD & (RsD == WriteRegE) & RegWriteE;  //刚写完jr就需要用
    assign branchstall = BranchD & ((RegWriteE  & (WriteRegE == RsD | WriteRegE == RtD)) | (MemtoRegM & (WriteRegM == RsD | WriteRegM == RtD))); //beq前一条为写寄存器指令，且写的寄存器为beq的两个寄存器
    assign divstall = divStart;
    wire div_sys_stall;
    assign div_sys_stall = id_is_br_sysD & divStart;
    assign mfc0stall = id_is_mfc0E & ((RsD == RtE) | (RtD == RtE));  //前一条指令是mfc0指令，且mfc0的寄存器号与当前指令的两个寄存器号相同
    assign cp0to_from_stall = id_is_mfc0E & id_is_mtc0M & RdE == RdM;
    
    // assign StallF = lwstall | (~PCSrcD & BranchD) | divstall;
    // assign StallF = lwstall | branchstall | jrstall | divstall | cp0to_from_stall | mfc0stall;  //延时槽指令需要执行 所以也要jrstall
    // assign StallD = lwstall | branchstall | jrstall | divstall | cp0to_from_stall;
    // assign StallE = id_is_br_sysD;
    // assign FlushD = PCSrcE | jumpE;  //beq, j要发生跳转时，需要冲掉下一条指令

    assign StallF = (lwstall | branchstall | jrstall | divstall | div_sys_stall | cp0to_from_stall) & ~exception_flushM ;  //延时槽指令需要执行 所以也要jrstall
    assign StallD = lwstall | branchstall | jrstall | divstall | div_sys_stall | cp0to_from_stall;
    assign StallE = cp0to_from_stall | div_sys_stall;

    assign FlushD = exceptionM | id_is_br_sysE | id_is_eretE;  // 当M阶段检测到异常时此时flush掉D阶段的指令，id_is_br_sysE是sys或break指令
    assign FlushE = exceptionM | StallD ;  // 当M阶段检测到异常时此时flush掉E阶段的指令
    assign FlushM = exceptionM;
    assign StallM = 1'b0;
endmodule
