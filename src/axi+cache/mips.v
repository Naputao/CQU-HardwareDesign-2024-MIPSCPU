module mips(
	output wire inst_req,
	output wire data_req,
	output wire	data_wr,
	input wire inst_addr_ok,
	input wire inst_data_ok,
	input wire data_addr_ok,
	input wire data_data_ok,

	input wire clk, rst,
	input wire [5:0] ext_int,
	input wire[31:0] instr,
	input wire[31:0] readdata,
 	output wire[31:0] inst_raddr,
	output wire[31:0] mem_addr, writedata,
	output wire[3:0] mem_we
    );

	wire memtoreg, regdst, regwrite, jump, zero, isUnsignExt, hiRegWrite, loRegWrite;
	wire [1:0] alusrc;
	wire [1:0] saveReg;
	wire [5:0] opD, functD;
	wire [3:0] alucontrol;
	wire [2:0] regfrom;
	wire id_is_break, id_is_syscall, priorControl, id_is_unfinished;  //异常处理指令 prior为是否为特权指令 传入priordec进一步解析

	controller controller(
		.opD(opD),
		.functD(functD),
		.jump(jump),
		.branch(branch),
		.alusrc(alusrc),
		.regfrom(regfrom),
		.regwrite(regwrite),
		.regdst(regdst),
		.aluControl(alucontrol),
		.isUnsignExt(isUnsignExt),
		.hiRegWrite(hiRegWrite),
		.loRegWrite(loRegWrite),
		.saveReg(saveReg),
		.id_is_break(id_is_break), 
		.id_is_syscall(id_is_syscall), 
		.priorControl(priorControl),
		.id_is_unfinished(id_is_unfinished)
    );

	datapath datapath(
		.inst_req(inst_req),
		.inst_addr_ok(inst_addr_ok), //传入hazard让其取消暂停流水线 clkp
		.inst_data_ok(inst_data_ok), //传入hazard让其取消暂停流水线 clkp
		.data_req(data_req),
		.data_wr(data_wr),
		.data_addr_ok(data_addr_ok), //传入hazard让其取消暂停流水线 clkp
		.data_data_ok(data_data_ok),
		
		.clk(clk),
		.rst(rst),
		.ext_int(ext_int),
		.instrF(instr),
		.branch(branch),
		.jump(jump),
		.regfrom(regfrom),
		.regdst(regdst),
		.regwrite(regwrite),
		.alusrc(alusrc),
		.alucontrol(alucontrol),
		.ReadData(readdata),
		.inst_raddr(inst_raddr),
		.mem_read_addr(mem_addr),
		.WriteData(writedata),
		.mem_we(mem_we),
		.functD(functD),
		.opD(opD),
		.isUnsignExt(isUnsignExt),
		.hiRegWrite(hiRegWrite),
		.loRegWrite(loRegWrite),
		.saveReg(saveReg),
		.id_is_break(id_is_break),
		.id_is_syscall(id_is_syscall), 
		.priorControl(priorControl),
		.id_is_unfinished(id_is_unfinished)
    );
	
endmodule
