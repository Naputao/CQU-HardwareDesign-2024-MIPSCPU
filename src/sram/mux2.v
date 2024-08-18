`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2023 09:30:00 PM
// Design Name: 
// Module Name: mux
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


module mux2 #(parameter WIDTH = 32)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire s,
    output wire [WIDTH-1:0] y
    );

    assign y = s ? a : b;

endmodule