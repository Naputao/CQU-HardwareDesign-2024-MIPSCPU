module pc2_ctrl(
    input wire [31:0] pc_4,  //pc+4
    input wire [31:0] pc_branchD,  //pc分支跳转的地址
    input wire [31:0] pc_jD,  //pc跳转的地址
    input wire [31:0] epc,  //异常处理的返回地址

    //控制信号
    input wire is_pc_branch, is_pc_jump, is_pc_exception, is_pc_eret,

    output wire [31:0] pc2
);

    wire [31:0] exception;
    assign exception = 32'hbfc00380;  //异常处理的入口地址

    wire [31:0] pc_tmp1, pc_tmp2, pc_tmp3;

    mux2 #(32) mux_branch(
        .a(pc_branchD),  //pc分支跳转的地址
        .b(pc_4),  //pc+4
        .s(is_pc_branch),  //pcsrc控制信号
        .y(pc_tmp1)
    );

    mux2 #(32) mux_jump(
        .a(pc_jD),  //jump跳转地址
        .b(pc_tmp1),
        .s(is_pc_jump),  //jump控制信号
        .y(pc_tmp2)
    );

    mux2 #(32) mux_eret(
        .a(epc),  //异常返回地址
        .b(pc_tmp2),
        .s(is_pc_eret),  //异常返回控制信号
        .y(pc_tmp3)
    );

    mux2 #(32) mux_exception(
        .a(exception),  //异常处理的入口地址
        .b(pc_tmp3),
        .s(is_pc_exception),  //异常处理控制信号
        .y(pc2)
    );
endmodule
