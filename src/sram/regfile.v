`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2023 09:36:04 PM
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire clk,
    input wire we3,
    input wire [4:0] ra1, ra2, wa3,
    input wire [31:0] wd3,
    output wire [31:0] rd1, rd2
    );

    reg [31:0] rf[31:0];

    initial begin
        rf[0] = 0;
    end

    always @(negedge clk) begin
        if(we3) begin
            rf[wa3] = wd3;
        end
    end

    assign rd1 = (ra1[4] | ra1[3] | ra1[2] | ra1[1] | ra1[0]) ? rf[ra1] : 0;
    assign rd2 = (ra2[4] | ra2[3] | ra2[2] | ra2[1] | ra2[0]) ? rf[ra2] : 0;

endmodule
