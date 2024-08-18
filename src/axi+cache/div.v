
`define ZeroWord 32'h0000_0000
`define DivResultNotReady 1'b0
`define DivResultReady 1'b1
`define DivFree 2'b00
`define DivByZero 2'b01
`define DivOn 2'b10
`define DivEnd 2'b11
`define DivStart 1'b1
`define DivStop 1'b0
`define RstEnable 1'b1

module div_optimized(
	input wire clk,
	input wire rst,
	
	input wire signed_div_i,
	input wire[31:0] opdata1_i,
	input wire[31:0] opdata2_i,
	input wire start_i,
	
	output reg[63:0] result_o,
	output reg ready_o
);
	wire [64:0] div_temp;
	assign div_temp = dividend[64]? {dividend[63:0],1'b0} + {1'b0,divisor,32'b0}:
									{dividend[63:0],1'b1} - {1'b0,divisor,32'b0};
	reg[5:0] count;
	reg[1:0] state;
	reg[31:0] divided;
	reg[31:0] divisor;
	reg[64:0] dividend;
	reg op1_sign;
	reg op2_sign;
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
			count <= 6'b000000;
			op1_sign <= 1'b0;
			op2_sign <= 1'b0;
		end else begin
		  	case (state)
		  		`DivFree: begin
					if(start_i == `DivStart) begin
						if(opdata2_i == `ZeroWord) begin
							state <= `DivByZero;
						end else begin
							state <= `DivOn;
							count <= 6'b000000;
							if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin
								divided = ~opdata1_i + 1;
							end else begin
								divided = opdata1_i;
							end
							if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin
								divisor = ~opdata2_i + 1;
							end else begin
								divisor = opdata2_i;
							end
							dividend[64:32] <= ~ {1'b0,divisor} + 1 + divided[31];
							dividend[31:1] <= divided[30:0];
							dividend[0] <= 1'b0;
							op1_sign <= opdata1_i[31];
							op2_sign <= opdata2_i[31];
						end
					end else begin
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end
				end
				`DivByZero: begin
					dividend <= {`ZeroWord,`ZeroWord};
					state <= `DivEnd;
				end
				`DivOn: begin
					if(count != 6'b100000)begin
						dividend <= div_temp;
						count <= count + 1;
					end else begin
						if((signed_div_i == 1'b1) && ((op1_sign ^ op2_sign) == 1'b1)) begin
							dividend[31:0] <= (~dividend[31:0] + 1);
						end
						if((signed_div_i == 1'b1) && (op1_sign == 1'b1)) begin
							dividend[64:32] <= ~(dividend[64:32] + divisor) + 1;
						end else begin
							dividend[64:32] <= dividend[64:32] + divisor;
						end
						state <= `DivEnd;
					end
				end
				`DivEnd: begin
					result_o <= {dividend[64:33], dividend[31:0]};
					ready_o <= `DivResultReady;
					if(start_i == `DivStop) begin
						state <= `DivFree;
						ready_o <= `DivResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end
				end
		  	endcase
		end
	end

endmodule