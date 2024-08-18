module mips(
	input wire clk, rst,
	input wire [5:0] ext_int,
 	output wire[31:0] pc,
	input wire[31:0] instr,
	output wire[31:0] mem_addr, writedata,
	input wire[31:0] readdata,
	output wire[3:0] mem_write,
	output wire mem_en
    );
	
	wire memtoreg, regdst, regwrite, jump, zero, isUnsignExt, hiRegWrite, loRegWrite;
	wire beq_branch, bne_branch, bgtz_branch, blez_branch, compare_branch;
	wire [1:0] alusrc;
	wire [1:0] saveReg;
	wire [5:0] opD, functD;
	wire [4:0] alucontrol;
	wire [2:0] regfrom;
	wire [3:0] memwrite;
	wire id_is_break, id_is_syscall, priorControl, id_is_unfinished;

	controller controller(
		.opD(opD),
		.functD(functD),
		.jump(jump),
		.branch(branch),
		.alusrc(alusrc),
		.memwrite(memwrite),
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
		.memwrite(memwrite),
		.alucontrol(alucontrol),
		.ReadData(readdata),
		.pc(pc),
		.alu_result(mem_addr),
		.WriteData(writedata),
		.MemWrite(mem_write),
		.functD(functD),
		.opD(opD),
		.isUnsignExt(isUnsignExt),
		.hiRegWrite(hiRegWrite),
		.loRegWrite(loRegWrite),
		.saveReg(saveReg),
		.id_is_break(id_is_break), 
		.id_is_syscall(id_is_syscall), 
		.priorControl(priorControl),
		.id_is_unfinished(id_is_unfinished),
		.mem_en(mem_en)
    );
	
endmodule
