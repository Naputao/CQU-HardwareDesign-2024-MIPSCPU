module mycpu_top(
    input clk,
    input resetn,  //low active
    input [5:0] ext_int,

    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,

    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    output [31:0] debug_wb_pc,
    output [3:0]  debug_wb_rf_wen,
    output [4:0]  debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

    assign debug_wb_pc = mips.datapath.pcW;
    assign debug_wb_rf_wnum = mips.datapath.WriteRegW;
    assign debug_wb_rf_wen = {4{(mips.datapath.RegWriteW | mips.datapath.bsaveW | mips.datapath.jsaveW | mips.datapath.id_is_mfc0W) & ~mips.datapath.exception_flushW}} ;
    assign debug_wb_rf_wdata = mips.datapath.ResultW;
    
	wire [31:0] pc;
	wire [31:0] instr, inst_vaddr, data_vaddr, inst_paddr, data_paddr;
	wire [3:0] memwrite;
	wire [31:0] writedata, readdata;

    mips mips(
        .clk(~clk),
        .rst(~resetn),
        .ext_int(ext_int),
        .pc(inst_vaddr),          //pcF
        .instr(instr),            //instrF指令内容
        .mem_write(memwrite),
        .mem_addr(data_vaddr),
        .mem_en(mem_en),
        .writedata(writedata),
        .readdata(readdata)
    );

    mmu mmu(
        .inst_vaddr(inst_vaddr),
        .inst_paddr(inst_paddr),
        .data_vaddr(data_vaddr),
        .data_paddr(data_paddr)
    );

    // assign inst_sram_en = ~mips.datapath.pc_trap;     //如果有inst_en，就用inst_en
    assign inst_sram_en = 1'b1;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = inst_paddr;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = mem_en;     //如果有data_en，就用data_en
    assign data_sram_wen = memwrite;
    assign data_sram_addr = data_paddr;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule