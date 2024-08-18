`timescale 1ns / 1ps
//0000 and andi
//0001 or ori
//0010 add addi addiu addu
//0011 nor
//0100 div
//0101 divu
//0110 sub subi subiu subu
//0111 slt slti
//1000 sll
//1001 srl
//1010 sra
//1011 xor
//1100 lui
//1101 sltu sltui
//1110 
//1111
module alu(
    input wire [31:0]A,
    input wire [31:0]B,
    input wire [4:0]control,
    output wire [31:0]out,
    // output wire zero,
    output wire overflow
    );

    wire [31:0] num_plus, num_diff, tmp;
    wire slt_result, sltu_result, carry_bit;

    // wire [32:0] tmpa, tmpb;
    // assign tmpa = {A[31], A};
    // assign tmpb = {B[31], B};

    wire [32:0] k1, k2;
    assign k1 = {A[31], A} + {B[31], B};
    assign k2 = {A[31], A} - {B[31], B};

    assign carry_bit = control == 5'b00010 ? k1[32] : k2[32];
    assign num_plus = k1[31:0];
    assign num_diff = k2[31:0];

    // assign {carry_bit, num_plus} = tmpa + tmpb;
    // assign {carry_bit, num_diff} = tmpa - tmpb;
    // assign num_diff = A - B;

    assign slt_result = (A[31] & ~B[31]) | (~A[31] & ~B[31] & num_diff[31]) | (A[31] & B[31] & num_diff[31]);
    assign {sltu_result, tmp} = {1'b0, A} - {1'b0, B};
    
    wire [31:0] ans1[1:0], ans2[1:0], out1, out2;
    wire [31:0] sra;
    SRA SRA(B, A[4:0], sra);

    assign ans1[0] = control[2] ? (control[1] ? (control[0] ?           (slt_result) : // 00111
                                                                        (num_diff)) :  // 00110
                                            (control[0] ?               (A & B) :  // 00101
                                                                        (A & B))) :  // 00100
                              (control[1] ? (control[0] ?               (~(A | B)) :  // 00011
                                                                        (num_plus)) :  // 00010
                                            (control[0] ?               (A | B) :  // 00001
                                                                        (A & B))); // 00000

    assign ans1[1] = control[2] ? (control[1] ? (control[0] ?           (A & B) :  // 01111
                                                                        (A & B)) :  // 01110
                                            (control[0] ?               (sltu_result) :  //  01101 sltu
                                                                        (B << 16))) :  // 01100
                              (control[1] ? (control[0] ?               (A ^ B) :  // 01011
                                                                        (sra)) :  // 01010 sra
                                            (control[0] ?               (B >> A[4:0]) :  // 01001
                                                                        (B << A[4:0])));  // 01000

    assign ans2[0] = control[2] ? (control[1] ? (control[0] ?           (A & B) : // 10111
                                                                        (A & B)) :  // 10110
                                            (control[0] ?               (A & B) :  // 10101
                                                                        (A & B))) :  // 10100
                              (control[1] ? (control[0] ?               (A & B) :  // 10011
                                                                        (A & B)) :  // 10010
                                            (control[0] ?               (A & B) :  // 10001
                                                                        (A == B ? 32'b1 : 32'b0))); // 10000

    assign ans2[1] = control[2] ? (control[1] ? (control[0] ?           (A & B) :  // 11111
                                                                        (A & B)) :  // 11110
                                            (control[0] ?               (A & B) :  //  11101
                                                                        (A & B))) :  // 11100
                              (control[1] ? (control[0] ?               (A & B) :  // 11011
                                                                        (A & B)) :  // 11010 sra
                                            (control[0] ?               (A & B) :  // 11001
                                                                        (A & B)));  // 11000

    assign out1 = control[3] ? ans1[1] : ans1[0];
    assign out2 = control[3] ? ans2[1] : ans2[0];
    assign out = control[4] ? out2 : out1;
    // assign zero = (num_diff == 32'b0);
    assign overflow = (~|(control ^ 5'b00010) | ~|(control ^ 5'b00110)) & (carry_bit ^ out[31]) ? 1'b1 : 1'b0;
endmodule

module SRA(
    input wire [31:0] a,
    input wire [4:0] b,
    output wire [31:0] y
);
    reg [31:0] ry;
    always @(*) begin
        ry <= $signed(a) >>> b;
    end
    assign y =  ry;
endmodule