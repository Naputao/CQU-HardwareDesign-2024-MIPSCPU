`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2023 11:37:20 PM
// Design Name: 
// Module Name: flopenr
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

module flopenr #(parameter WIDTH = 8)(
	input wire clk,rst,en,
	input wire[WIDTH-1:0] d,
	output reg[WIDTH-1:0] q
    );
	always @(posedge clk) begin
		if(rst) begin
			q <= 0;
		end else if(en) begin
			q <= d;
		end
	end
endmodule
