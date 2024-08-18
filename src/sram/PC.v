`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2023 07:17:42 PM
// Design Name: 
// Module Name: PC
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


module PC (
    input wire clk,rst,en,
    input wire [31:0] d,
    output reg [31:0] q
    );
    
    always @(posedge clk, posedge rst) begin //*2
		if(rst) begin
			q <= 32'hbfc00000;
		end else if(en) begin
			q <= d;
		end
	end
	
endmodule
