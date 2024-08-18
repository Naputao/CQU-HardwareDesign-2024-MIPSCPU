module mycpu_top_sramlike(
    input clk,
    input rst,  //low active
    input [5:0] ext_int,
    
    output wire inst_req,
    output wire inst_wr,
    output wire [1:0] inst_size,
    output wire [31:0] inst_wdata,
    input wire [31:0] inst_rdata,
    input wire inst_addr_ok,
    input wire inst_data_ok,

    output wire data_req,           //从mips-datapath中传出
    output wire data_wr,            //从mips-datapath中传出
    output wire [31:0] data_wdata,
    output wire [1:0] data_size,
    input wire [31:0] data_rdata,
    input wire data_addr_ok,
    input wire data_data_ok,
    
    output [31:0] debug_wb_pc,
    output [3:0]  debug_wb_rf_wen,
    output [4:0]  debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata,

    output wire [31:0] inst_vaddr, data_vaddr
);
    assign inst_wr = 1'b0;              //一直0读而1不写
    assign inst_size = 2'b10;           //32比特为10
    assign inst_wdata = 32'hbfc00000;   //wr=0时用不到所以随便都可以
    assign instr = inst_rdata;          //读到的数据为指令
    
    assign data_wdata = writedata;      //writedata为向dataram中写的数据
    assign readdata = data_rdata;       //读到的数据为lw,lh,lb数据，其实和instr一样

    assign data_size = (~|(mem_we ^ 4'b0001) | ~|(mem_we ^ 4'b0010) | ~|(mem_we ^ 4'b0100) | ~|(mem_we ^ 4'b1000)) ? 2'b00:
                       (~|(mem_we ^ 4'b0011) | ~|(mem_we ^ 4'b1100) ) ? 2'b01 : 2'b10;   //一般情况下得是10！
    
	wire [31:0] instr, writedata, readdata;
	wire [3:0] mem_we;

    mips mips(
        //全局时钟信号和mips中时钟信号相反，下列注释clkp全部指代为全局时钟信号上沿，clkn全部指代为全局时钟信号下沿
        .inst_req(inst_req),                //clkn
        .inst_addr_ok(inst_addr_ok),        //传入mips-datapath-hazard让其取消暂停流水线，它应该是clkp
        .inst_data_ok(inst_data_ok),        //传入mips-datapath-hazard让其取消暂停流水线，它应该是clkp
        .data_req(data_req),                //从mips-datapath中传出
        .data_wr(data_wr),                  //从mips-datapath中传出
        .data_addr_ok(data_addr_ok),        //传入mips-datapath-hazard让其取消暂停流水线，它应该是clkp
        .data_data_ok(data_data_ok),

        .clk(~clk),
        .rst(rst),
        .ext_int(ext_int),
        .inst_raddr(inst_vaddr),           //pcF:接到外面去要经过mmu映射 inst_vaddr -> inst_paddr 后访存
        .instr(instr),              //instrF指令内容
        .mem_addr(data_vaddr),      //虚拟地址
        .mem_we(mem_we),
        .writedata(writedata),
        .readdata(readdata)         //从axi总线中读到的数据
    );
    //ascii
    instdec instdec(
        .instr(instr)
    );

    assign debug_wb_pc = mips.datapath.pcW;
    assign debug_wb_rf_wnum = mips.datapath.WriteRegW;
    assign debug_wb_rf_wen = {4{(mips.datapath.RegWriteW | mips.datapath.bsaveW | mips.datapath.jsaveW | mips.datapath.id_is_mfc0W) & ~mips.datapath.exception_flushW & ~mips.datapath.StallW}};
    assign debug_wb_rf_wdata = mips.datapath.ResultW;

endmodule