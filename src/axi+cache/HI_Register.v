module HI_Register (  //LO Register
  input wire clk,
  input wire rst,
  input wire [31:0] data_in,
  input wire hi_reg_write,
  output wire [31:0] data_out_HI
);

  reg [31:0] HI;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      HI <= 32'b0;
    end else begin
      if (hi_reg_write) begin
        HI <= data_in;
      end
    end
  end

  assign data_out_HI = HI;

endmodule
