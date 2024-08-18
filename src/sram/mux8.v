`timescale 1ns / 1ps

module mux8 #(parameter WIDTH = 32)(
	input wire[WIDTH-1:0] d0,d1,d2,d3,d4,d5,d6,d7,
	input wire[2:0] s,
	output wire[WIDTH-1:0] y
    );

	assign y = s[2]?(s[1]?(s[0]?d7:
                                d6):
                          (s[0]?d5:
                                d4)):
                    (s[1]?(s[0]?d3:
                                d2):
                          (s[0]?d1:
                                d0));
endmodule