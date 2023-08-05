module mux_iord(input wire [2:0] sel,
                input wire [31:0] PC,
                input wire [31:0] RES,
                input wire [31:0] ALUOut,
                input wire [31:0] Excpt,
                input wire [31:0] a,
                input wire [31:0] b,
                output reg [31:0] out
                );
  
  always@(*) begin
    case (sel)
      3'b000: out = PC;
      3'b001: out = RES;
      3'b010: out = ALUOut;
      3'b011: out = Excpt;
      3'b100: out = a;
      3'b101: out = b;
      3'b110: out = 32'b0;
      3'b111: out = 32'b0;
    endcase
  end
endmodule