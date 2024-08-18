`define ZeroWord 32'h0000_0000
`define MultResultNotReady 1'b0
`define MultResultReady 1'b1
`define MultFree 2'b00
`define MultOn 2'b10
`define MultEnd 2'b11
`define MultStart 1'b1
`define MultStop 1'b0
`define RstEnable 1'b1
module mult(
	input wire clk,
	input wire rst,
	
	input wire signed_mult_i,
	input wire[31:0] opdata1_i,
	input wire[31:0] opdata2_i,
	input wire start_i,
	
	output reg[63:0] result_o,
	output reg ready_o
);
	reg[5:0] cnt;
	reg[64:0] multend;
	reg[1:0] state;
	reg[31:0] temp_op1;
	reg[31:0] temp_op2;
	reg[31:0] reserve_op1;
	reg[31:0] reserve_op2;
	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `MultFree;
			ready_o <= `MultResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		  	case (state)
		  		`MultFree: begin
					if(start_i == `MultStart) begin
						reserve_op1 <= opdata1_i;
						reserve_op2 <= opdata2_i;
                        temp_op1 <= opdata1_i;
                        temp_op2 <= opdata2_i;
						state <= `DivOn;
						cnt <= 6'b000000;
					end else begin
						ready_o <= `MultResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end          	
				end
				`MultOn: begin
                	case(cnt)
                	    6'b000000: begin
                	        if(signed_mult_i) begin
                	            multend <= $signed(temp_op1) * $signed(temp_op2);
                	        end else begin
                	            multend <= {32'b0,temp_op1} * {32'b0,temp_op2};
                	        end
                	        cnt <= cnt + 1;
                	    end
                	    6'b000010: begin
                	        state <= `MultEnd;
						    cnt <= 6'b000000;
                	    end
                	    default: begin
                	        cnt <= cnt + 1;
                	    end
                	endcase
				end
				`MultEnd: begin
					result_o <= multend[63:0];
					ready_o <= `MultResultReady;
					if(start_i == `MultStop) begin
						state <= `MultFree;
						ready_o <= `MultResultNotReady;
						result_o <= {`ZeroWord,`ZeroWord};
					end 
				end
		  	endcase
		end
	end

endmodule