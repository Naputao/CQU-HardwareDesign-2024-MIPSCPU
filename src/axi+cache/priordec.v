module priordec(
    input wire priorControl,
    input wire [31:0] instrD,
    output wire id_is_eret,
    output wire id_is_mtc0,
    output wire id_is_mfc0
);
    wire [4:0] rs;
    assign rs = instrD[25:21];
    assign id_is_eret = ~|(instrD ^ 32'b01000010000000000000000000011000);
    assign id_is_mtc0 = ~|(rs ^ 5'b00100) & priorControl;
    assign id_is_mfc0 = ~|(rs ^ 5'b00000) & priorControl;
endmodule
