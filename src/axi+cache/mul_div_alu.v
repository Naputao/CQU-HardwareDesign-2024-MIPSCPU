module mul_div_alu(
        input wire clk, rst, en, hiRegWrite, loRegWrite, exception_flushM,
        input wire [3:0] alucontrol,
        input wire [31:0] SrcAE, SrcBE,
        output wire mult_div_ready,
        output wire [63:0] divResult, multResult,
        output wire mult_div_start,
        output reg mult_div_alu_hiRegWriteM,mult_div_alu_loRegWriteM,
        output reg mult_divM
    );

    wire multReady;
    wire divStart, multStart;
    wire signedDiv, signedMult;
    // assign divStart = ~alucontrol[4] & ~alucontrol[3] & alucontrol[2] & ~alucontrol[1];
    // assign multStart = ~alucontrol[4] & alucontrol[3] & alucontrol[2] & alucontrol[1];
    assign divStart = ~alucontrol[3] & alucontrol[2] & ~alucontrol[1];
    assign multStart = alucontrol[3] & alucontrol[2] & alucontrol[1];
    assign signedDiv = ~alucontrol[0];
    assign signedMult = ~alucontrol[0];
    assign mult_div_start = (divStart | multStart) & ~(multReady | divReady);
    assign mult_div_ready = multReady | divReady;
    always@(posedge clk)begin
        if(rst) begin
            mult_div_alu_hiRegWriteM <= 1'b0;
            mult_div_alu_loRegWriteM <= 1'b0;
            mult_divM <= 1'b0;
        end
        mult_divM <= divReady & ~multReady;
        mult_div_alu_hiRegWriteM <= divReady | multReady;
        mult_div_alu_loRegWriteM <= divReady | multReady;
    end

    div_optimized div(
        .clk(clk),
        .rst(rst),
        .signed_div_i(signedDiv),
        .opdata1_i(SrcAE),
        .opdata2_i(SrcBE),
        .start_i(divStart),
        .result_o(divResult),
        .ready_o(divReady)
    );

    mult mult(
        .clk(clk),
        .rst(rst),
        .signed_mult_i(signedMult),
        .opdata1_i(SrcAE),
        .opdata2_i(SrcBE),
        .start_i(multStart),
        .result_o(multResult),
        .ready_o(multReady)
    );
endmodule

    