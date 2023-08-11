module mux_2_to_1(
    input wire sel,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] out
);

  always@(*) begin
    case (sel)
      1'b0: out = a;
      1'b1: out = b;
    endcase
  end
endmodule