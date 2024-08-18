`timescale 1ns / 1ps

module mul_div_alu(
        input wire clk, rst, hiRegWrite, loRegWrite,exception_flushM,
        input wire [4:0] alucontrol,
        input wire [31:0] SrcAE, SrcBE,
        output wire [63:0] divResult, multResult,
        output wire mult_div_start,
        output reg mult_div_alu_hiRegWriteM,mult_div_alu_loRegWriteM,
        output reg mult_divM
    );
    wire divReady, multReady;
    wire mult_div;
    wire mult_div_alu_hiRegWrite,mult_div_alu_loRegWrite;
    wire divStart;
    reg hiHasWrited, loHasWrited;
    reg divRunning, divRunning_neg, signedDiv, signedDiv_neg;
    wire multStart;
    reg multRunning, multRunning_neg, signedMult, signedMult_neg;
    //当控制信号为0100时，并且div准备好时，下一个时钟上沿设置start信号为1，下一个时钟下沿开始除法。
    assign divStart = divRunning;
    wire anotherDiv;
    assign anotherDiv= ~alucontrol[4] & ~alucontrol[3] & alucontrol[2] & ~alucontrol[1];
    //当控制信号为0100时，并且mult准备好时，下一个时钟上沿设置start信号为1，下一个时钟下沿开始乘法。
    assign multStart = multRunning;
    wire anotherMult;
    assign anotherMult= ~alucontrol[4] & alucontrol[3] & alucontrol[2] & alucontrol[1];
    //当hi和lo在除法运算期间都被写过，那么取消除法。当除法运算完成前，又有新的除法，则立即取消除法，准备下个除法。
    wire annul;
    reg annul_neg;
    assign annul = (hiHasWrited & loHasWrited) | anotherDiv | anotherMult | exception_flushM; //当lo hi寄存器已经写过了，就不运算了
    assign mult_div_start = multStart | divStart;
    assign mult_div_alu_hiRegWrite = (divReady | multReady) & ~hiHasWrited;//当hi寄存器已经写过了，就不写了
    assign mult_div_alu_loRegWrite = (divReady | multReady) & ~loHasWrited;//当lo寄存器已经写过了，就不写了
    assign mult_div = divReady & ~multReady;
    div div(
        .clk(~clk),
        .rst(rst),
        .signed_div_i(signedDiv),
        .opdata1_i(SrcAE),
        .opdata2_i(SrcBE),
        .start_i(divStart),
        .annul_i(annul),
        .result_o(divResult),
        .ready_o(divReady)
    );

    mult mult(
        .clk(~clk),
        .rst(rst),
        .signed_mult_i(signedMult),
        .opdata1_i(SrcAE),
        .opdata2_i(SrcBE),
        .start_i(multStart),
        .annul_i(annul),
        .result_o(multResult),
        .ready_o(multReady)
    );

    always@(negedge clk)begin
        signedDiv_neg <= ~alucontrol[0];
        divRunning_neg <= anotherDiv;
        annul_neg <= annul;
        signedMult_neg <= ~alucontrol[0];
        multRunning_neg <= anotherMult;
    end

    always@(posedge clk)begin
        if(rst) begin
            mult_divM <= 1'b0;
            mult_div_alu_hiRegWriteM <= 1'b0;
            mult_div_alu_loRegWriteM <= 1'b0;
            signedMult <= 1'b0;
            multRunning <= 1'b0;
            signedDiv <= 1'b0;
            divRunning<= 1'b0;
            hiHasWrited <= 1'b0;
            loHasWrited <= 1'b0;
        end else begin
            mult_divM <= mult_div;
            mult_div_alu_hiRegWriteM <= mult_div_alu_hiRegWrite;
            mult_div_alu_loRegWriteM <= mult_div_alu_loRegWrite;
            if(divRunning_neg|divReady|annul_neg) begin
                divRunning <= divRunning_neg;
                signedDiv <= signedDiv_neg;
            end
            if(multRunning_neg|multReady|annul_neg) begin //当取消乘法、开始乘法、乘法完成时更新状态
                multRunning <= multRunning_neg;
                signedMult <= signedMult_neg;
            end
            if(annul_neg) begin
                hiHasWrited <= 1'b0;
                loHasWrited <= 1'b0;
            end else begin
                if(hiRegWrite) begin
                    hiHasWrited <= 1'b1;
                end
                if(loRegWrite) begin
                    loHasWrited <= 1'b1;
                end
            end
        end
    end
endmodule

    