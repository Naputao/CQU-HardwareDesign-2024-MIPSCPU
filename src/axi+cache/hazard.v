module hazard(
    input wire notIDstall,
    input wire mult_div_start, mult_div_ready,
    input wire [2:0] RegFromE, RegFromM,
    input wire [4:0] RsD, RtD, RsE, RtE, RdM, RdW, WriteRegM, WriteRegW, WriteRegE,
    input wire RegWriteE, RegWriteM, RegWriteW, BranchD,
    input wire bsaveM, bsaveW, jsaveM, jsaveW,
    input wire save_in_rdM, save_in_rdW, jump_to_rs_valD,
    input wire hiRegWriteE, loRegWriteE,
    input wire exceptionM, id_is_br_sysD, id_is_br_sysEn, id_is_eretEn,
    input wire id_is_mfc0E, id_is_mfc0M,
    output wire [1:0] ForwardAE, ForwardBE,
    output wire [2:0] ForwardAD, ForwardBD,
    output wire StallF, StallD, StallE, StallM, StallW, FlushD, FlushE, FlushM
    );

    //前推到取寄存器值
    assign ForwardAD = (|RsD & ~|(RsD ^ WriteRegE) & id_is_mfc0E) ? 3'b100 :  // 前推mfc0刚在e阶段取到的cp0寄存器值
                       ((|RsD & ~|(RsD ^ WriteRegM) & id_is_mfc0M) ? 3'b011 :  // 前推mfc0刚在m阶段的cp0寄存器值（因为mfc0会阻塞一周期会出现上面的数据退推不出来）
                       ((|RsD & ((bsaveM & &RsD) | (jsaveM & ((~|(RsD ^ RdM) & save_in_rdM) | (&RsD & ~save_in_rdM))))) ? 3'b010 :
                       ((|RsD & ~|(RsD ^ WriteRegM) & RegWriteM) ? 3'b001 : 2'b000)));
    assign ForwardBD = (|RtD & ~|(RtD ^ WriteRegE) & id_is_mfc0E) ? 3'b100 :
                       ((|RtD & ~|(RtD ^ WriteRegM) & id_is_mfc0M) ? 3'b011 :
                       ((|RtD & ((bsaveM & &RtD) | (jsaveM & ((~|(RsD ^ RdM) & save_in_rdM) | (&RtD & ~save_in_rdM))))) ? 3'b010 :
                       ((|RtD & ~|(RtD ^ WriteRegM) & RegWriteM) ? 3'b001 : 3'b000)));

    //alu输入端前推信号：当11时前推刚才的保存的地址（PC+8）
    assign ForwardAE = (|RsE & ((bsaveM & &RsE) | (jsaveM & ((~|(RsE ^ RdM) & save_in_rdM) | (&RsE & ~save_in_rdM))))) ? 2'b11 :
                       ((|RsE & ((~|(RsE ^ WriteRegM) & RegWriteM) | (hiRegWriteE & ~|(RsE ^ WriteRegM)))) ? 2'b10 :  //上一条写的寄存器的值需要写入hi寄存器时，前推
                       ((|RsE & ((~|(RsE ^ WriteRegW) & RegWriteW) | (&RsE & bsaveW) | (((~|(RsE ^ RdW) & save_in_rdW) | (&RsE & ~save_in_rdW)) & jsaveW))) ? 2'b01 : 2'b00));
    assign ForwardBE = (|RtE & ((bsaveM & &RtE) | (jsaveM & ((~|(RtE ^ RdM) & save_in_rdM) | (&RtE & ~save_in_rdM))))) ? 2'b11 :
                       ((|RtE & ((~|(RtE ^ WriteRegM) & RegWriteM) | (hiRegWriteE & ~|(RtE ^ WriteRegM)))) ? 2'b10 :
                       ((|RtE & ((~|(RtE ^ WriteRegW) & RegWriteW) | (&RtE & bsaveW) | (((~|(RtE ^ RdW) & save_in_rdW) | (&RtE & ~save_in_rdW)) & jsaveW))) ? 2'b01 : 2'b00));

    wire lwstall, branchstall, jrstall, mult_div_stall, div_sys_stall;  //阻塞信号
    wire MemtoRegE, MemtoRegM;
    assign MemtoRegE = RegFromE[0] | RegFromE[1] | RegFromE[2];
    assign MemtoRegM = RegFromM[0] | RegFromM[1] | RegFromM[2];

    wire longest_stall = ~notIDstall | mult_div_stall | div_sys_stall;
    
    assign lwstall = |RtD & (~|(RsD ^ RtE) | ~|(RtD ^ RtE)) & MemtoRegE;
    assign jrstall = (jump_to_rs_valD & ~|(RsD ^ WriteRegE) & RegWriteE) | (jump_to_rs_valD & ~|(RsD ^ WriteRegM) & RegWriteM);  //刚写完jr就需要用
    assign branchstall = BranchD & ((RegWriteE  & (~|(WriteRegE ^ RsD) | ~|(WriteRegE ^ RtD))) | (MemtoRegM & (~|(WriteRegM ^ RsD) | ~|(WriteRegM ^ RtD)))); //beq前一条为写寄存器指令，且写的寄存器为beq的两个寄存器
    assign mult_div_stall = mult_div_start & ~mult_div_ready;
    assign div_sys_stall = id_is_br_sysD & mult_div_start;
    // assign cp0to_from_stall = id_is_mfc0E & id_is_mtc0M & ~|(RdE ^ RdM);

    //指令没有准备好时暂停，方便起见，当发生异常时同样也暂停流水线让其取出指令，当流水线全部暂停时不影响异常处理
    assign StallF = (longest_stall | lwstall | branchstall | jrstall) & ~exceptionM ;  //延时槽指令需要执行 所以也要jrstall
    assign StallD = longest_stall | lwstall | branchstall | jrstall;
    assign StallE = longest_stall;
    assign StallM = longest_stall;
    assign StallW = longest_stall;

    assign FlushD = exceptionM | (~longest_stall & (id_is_br_sysEn | id_is_eretEn));  // 当M阶段检测到异常时此时flush掉D阶段的指令，id_is_br_sysE是sys或break指令
    assign FlushE = exceptionM | (~longest_stall & (lwstall | branchstall | jrstall));  // 当M阶段检测到异常时此时flush掉E阶段的指令
    assign FlushM = exceptionM;
endmodule
