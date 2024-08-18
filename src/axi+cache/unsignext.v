`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2023 08:36:21 PM
// Design Name: 
// Module Name: unsignext
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


module unsignext(
    input wire [15:0] a,
    output wire [31:0] y
    );

    assign y = {16'b0, a};
endmodule
