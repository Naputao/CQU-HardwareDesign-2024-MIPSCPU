module mux2 #(parameter WIDTH = 32)(
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire s,
    output wire [WIDTH-1:0] y
    );

    assign y = s ? a : b;

endmodule