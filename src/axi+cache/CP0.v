// `define CP0_REG_BADVADDR    5'b01000       //只读
// `define CP0_REG_COUNT    5'b01001        //可读写
// `define CP0_REG_COMPARE    5'b01011      //可读写
// `define CP0_REG_STATUS    5'b01100       //可读写
// `define CP0_REG_CAUSE    5'b01101        //只读
// `define CP0_REG_EPC    5'b01110          //可读写
// `define CP0_REG_PRID    5'b01111         //只读
// `define CP0_REG_CONFIG    5'b10000       //只读

// `define EXC_CODE_INT        5'b00000  //中断
// `define EXC_CODE_ADEL       5'b00100  //地址错例外（读数据或取指令）
// `define EXC_CODE_ADES       5'b00101  //地址错例外（写数据）
// `define EXC_CODE_SYS        5'b01000  //系统调用例外
// `define EXC_CODE_BP         5'b01001  //断点例外
// `define EXC_CODE_RI         5'b01010  //保留指令例外
// `define EXC_CODE_OV         5'b01100  //算术溢出例外

`include "defines.vh"
module CP0(
    input clk, rst,
    input wire en,  //cp0使能
    input wire we,  //cp0写使能
    input wire [4:0] waddr,  //cp0写地址
    input wire [31:0] wdata,  //cp0写数据
    input wire [4:0] raddr,  //cp0读地址
    output wire [31:0] rdata,  //cp0读数据

    input wire StallW,
    input wire id_is_eretM,  //是否是eret指令
    input wire [5:0] ext_int,
    input wire is_in_delayslot,  //该例外发生指令是否在jump和branch指令的延迟槽中
    input wire [31:0] current_inst_addr,  //当前指令地址
    input wire [31:0] badvaddr_i,  //地址异常时的地址
    input wire [4:0] except_type,  //异常类型

    output reg [31:0] badvaddr,
    output reg [31:0] count,
    output reg [31:0] status,
    output reg [31:0] cause,
    output reg [31:0] epc
);
    reg timer_interrupt;  //发生时钟中断
    reg [31:0] compare;
    reg [32:0] count_ext;
    wire EXL;
    assign EXL = status[1];

    always @(posedge clk) begin
        if (rst) begin
            badvaddr <= `ZeroWord;
            count_ext <= 33'b0;;
            status <= 32'h00400000;
            cause <= `ZeroWord;
            epc <= `ZeroWord;
            timer_interrupt <= 1'b0;
        end
        else if (id_is_eretM) begin
            status[1] <= 1'b0;
        end
        else begin
            count_ext <= count_ext + 1'b1;
            count <= count_ext[32:1];
            if (compare != 32'b0 && count_ext[32:1] == compare) begin
                timer_interrupt <= 1'b1;
                cause[30] <= 1'b1;
            end else begin
                timer_interrupt <= 1'b0;
                cause[30] <= 1'b0;
            end
            if (en) begin
                case (except_type)
                    `EXC_CODE_INT: begin  //中断
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                            status[1] <= 1'b1;
                        end
                        cause[6:2] <= ~StallW ? ext_int[4:0] : 5'b0;
                        cause[7] <=  ~StallW ? cause[30] : cause[7];
                    end
                    `EXC_CODE_ADEL: begin  //地址错例外（读数据或取指令）
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                            status[1] <= 1'b1;
                        end
                        cause[6:2] <= `EXC_CODE_ADEL;
                        badvaddr <= badvaddr_i;
                    end
                    `EXC_CODE_ADES: begin  //地址错例外（写数据）
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                            status[1] <= 1'b1;
                        end
                        cause[6:2] <= `EXC_CODE_ADES;
                        badvaddr <= badvaddr_i;
                    end
                    `EXC_CODE_OV: begin  //算术溢出例外
                        if(is_in_delayslot == 1'b1) begin
                            epc <= current_inst_addr - 4;
                            cause[31] <= 1'b1;
                        end else begin 
                            epc <= current_inst_addr;
                            cause[31] <= 1'b0;
                        end
                        status[1] <= 1'b1;
                        cause[6:2] <= `EXC_CODE_OV;
                    end
                    `EXC_CODE_SYS: begin  //系统调用例外
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                        end
                        status[1] <= 1'b1;
                        cause[6:2] <= `EXC_CODE_SYS;
                    end
                    `EXC_CODE_BP: begin  //断点例外
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                            status[1] <= 1'b1;
                        end
                        cause[6:2] <= `EXC_CODE_BP;
                    end
                    `EXC_CODE_RI: begin  //保留指令例外
                        if (EXL == 1'b0) begin
                            if(is_in_delayslot == 1'b1) begin
                                epc <= current_inst_addr - 4;
                                cause[31] <= 1'b1;
                            end else begin 
                                epc <= current_inst_addr;
                                cause[31] <= 1'b0;
                            end
                            status[1] <= 1'b1;
                        end
                        cause[6:2] <= `EXC_CODE_RI;
                    end
                    default: begin  //无例外
                        if (status[1] == 1'b1) begin
                            status[1] <= 1'b0;
                        end else begin
                            status[1] <= status[1];
                        end
                    end
                endcase
            end
            // mtc0: 写不了badvaddr
            if (we) begin
                case (waddr)
                    `CP0_REG_COUNT: begin
                        count <= wdata;
                    end
                    `CP0_REG_COMPARE: begin
                        compare <= wdata;
                        timer_interrupt <= 1'b0;
                    end
                    `CP0_REG_STATUS: begin
                        status[0] <= wdata[0];
                        status[1] <= wdata[1];
                        status[15:8] <= wdata[15:8];
                    end
                    `CP0_REG_CAUSE: begin
                        cause[9:8] <= wdata[9:8];
                    end
                    `CP0_REG_EPC: begin
                        epc <= wdata;
                    end
                    default: begin
                        // do nothing
                    end
                endcase
            end
        end
    end

    wire [31:0] rbadvaddr, rcount, rstatus, rcause, repc, rcompare;
    assign rbadvaddr = (raddr == `CP0_REG_BADVADDR && ~rst) ? badvaddr : `ZeroWord;
    assign rcount = (raddr == `CP0_REG_COUNT && ~rst) ? count : `ZeroWord;
    assign rstatus = (raddr == `CP0_REG_STATUS && ~rst) ? status : `ZeroWord;
    assign rcause = (raddr == `CP0_REG_CAUSE && ~rst) ? cause : `ZeroWord;
    assign repc = (raddr == `CP0_REG_EPC && ~rst) ? epc : `ZeroWord;
    assign rcompare = (raddr == `CP0_REG_COMPARE && ~rst) ? compare : `ZeroWord;

    assign rdata = rbadvaddr | rcount | rstatus | rcause | repc | rcompare;

endmodule
