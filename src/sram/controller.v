`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2023 05:51:45 PM
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller(
    input wire[5:0] opD,functD,
    output reg jump,
    output reg branch,
    output reg [1:0] alusrc,
    output reg [3:0] memwrite,
    output reg [2:0] regfrom, //000:aluout|001:lw|011:mflo|010:mfhi|100:lb|101:lbu|110:lh|111:lhu //00:w|10:b|11:h
    output reg regwrite,
    output reg regdst,
    output reg [4:0] aluControl,
    output reg isUnsignExt,
    output reg hiRegWrite,
    output reg loRegWrite,
    output reg [1:0] saveReg, //00:no|01:w|10:b|11:h
    output reg id_is_break, id_is_syscall, priorControl, id_is_unfinished
    );
    
    always @(*) begin
        case (opD)
            6'b000000: begin
                case (functD)
                    6'b000000: begin  //sll
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b10;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b000010: begin  //srl
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b10;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01001;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b000011: begin  //sra
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b10;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01010;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b000100: begin  //sllv
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b000110: begin  //srlv
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01001;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b000111: begin  //srav
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01010;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100000: begin  //add
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00010;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100001: begin  //addu
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00010;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100010: begin  //sub
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00110;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100011: begin  //subu
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00110;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100100: begin  //and
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100101: begin  //or
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00001;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b101010: begin  //slt
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00111;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b101011: begin  //sltu
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01101;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100110: begin  //xor
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01011;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b100111: begin  //nor
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00011;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b010000: begin      //mfhi
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b010;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b010010: begin      //mflo
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b011;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b010001: begin      //mthi
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b1;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b010011: begin      //mtlo
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b1;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b001000: begin      //jr
                        // sigs <= 16'b0000000001000_0010;
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b1;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b001001: begin      //jalr
                        // sigs <= 16'b0000000001000_0010;
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b1;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b011010: begin      //div
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00100;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b011011: begin      //divu
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00101;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b011000: begin      //mult
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01110;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b011001: begin      //multu
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b01111;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;

                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b001101: begin      //break
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b1;
                        id_is_syscall <= 1'b0;
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    6'b001100: begin      //syscall
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b1;
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                    default: begin
                        //20231227
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b0;
                        regwrite <= 1'b0;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b00000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;

                        id_is_unfinished <= 1'b1;
                        priorControl <= 1'b0;
                    end
                endcase
            end
            6'b010000: begin  // eret, mtc0, mfc0
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                id_is_unfinished <= 1'b0;
                priorControl <= 1'b1;
            end
            6'b100000: begin       //lb
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b100;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b100100: begin       //lbu
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b101;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b100001: begin       //lh
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b110;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b100101: begin       //lhu
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b111;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b100011: begin       //lw
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b001;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b101000: begin      //sb
                //20231227
                saveReg <= 2'b10; //00:no|01:w|10:b|11:h
                regfrom <= 3'b000; 
                memwrite <= 5'b00001;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b101001: begin      //sh
                //20231227
                saveReg <= 2'b11; //00:no|01:w|10:b|11:h
                regfrom <= 3'b000;
                memwrite <= 5'b00011;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b101011: begin      //sw
                //20231227
                saveReg <= 2'b01; //00:no|01:w|10:b|11:h
                regfrom <= 3'b000;
                memwrite <= 5'b01111;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b000100: begin      //beq
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b1;
                jump <= 1'b0;
                aluControl <= 5'b00110;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b000101: begin      //bne
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b1;
                jump <= 1'b0;
                aluControl <= 5'b00110;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b000001: begin      //bgez, bgezal, bltz, bltzal
                // sigs <= 16'b1000000000000_0110;
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b1;
                jump <= 1'b0;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                priorControl <= 1'b0;
            end
            6'b000111: begin      //bgtz
                // sigs <= 16'b1000000000000_0110;
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b1;
                jump <= 1'b0;
                aluControl <= 5'b00110;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                priorControl <= 1'b0;
            end
            6'b000110: begin      //blez
                // sigs <= 16'b1000000000000_0110;
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b1;
                jump <= 1'b0;
                aluControl <= 5'b00110;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001000: begin      //addi
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001001: begin      //addiu
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00010;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001010: begin      //slti
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00111;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001011: begin      //sltiu
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b01101;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b000010: begin      //j
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b1;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b000011: begin      //jal
                // sigs <= 16'b0000000001000_0010;
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b1;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b1;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001100: begin      //andi
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b1;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001101: begin      //ori
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00001;
                isUnsignExt <= 1'b1;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001110: begin      //xori
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b01011;
                isUnsignExt <= 1'b1;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b001111: begin      //lui
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b01;
                regdst <= 1'b0;
                regwrite <= 1'b1;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b01100;
                isUnsignExt <= 1'b1;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                
                id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
            end
            6'b111111: begin      //lui
                case(functD)
                    6'b000000: begin
                        saveReg <= 2'b00;
                        regfrom <= 3'b000;
                        memwrite <= 5'b00000;
                        alusrc <= 2'b00;
                        regdst <= 1'b1;
                        regwrite <= 1'b1;
                        branch <= 1'b0;
                        jump <= 1'b0;
                        aluControl <= 5'b10000;
                        isUnsignExt <= 1'b0;
                        hiRegWrite <= 1'b0;
                        loRegWrite <= 1'b0;
                        id_is_break <= 1'b0;
                        id_is_syscall <= 1'b0;
                        id_is_unfinished <= 1'b0;
                        priorControl <= 1'b0;
                    end
                endcase
            end
            default: begin
                //20231227
                saveReg <= 2'b00;
                regfrom <= 3'b000;
                memwrite <= 5'b00000;
                alusrc <= 2'b00;
                regdst <= 1'b0;
                regwrite <= 1'b0;
                branch <= 1'b0;
                jump <= 1'b0;
                aluControl <= 5'b00000;
                isUnsignExt <= 1'b0;
                hiRegWrite <= 1'b0;
                loRegWrite <= 1'b0;
                id_is_break <= 1'b0;
                id_is_syscall <= 1'b0;
                id_is_unfinished <= 1'b1;
                priorControl <= 1'b0;
            end
        endcase
    end
endmodule
