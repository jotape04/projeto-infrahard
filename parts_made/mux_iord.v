module mux_iord(
  input wire [2:0] sel,
  input wire [31:0] PC,
  input wire [31:0] RES,
  input wire [31:0] ALUOut,
  input wire [31:0] Excpt,
  input wire [31:0] Reg_A,
  input wire [31:0] Reg_B,
  output reg [31:0] addr
);
  
  always@(*) begin
    case (sel)
      3'b000: addr = PC;
      3'b001: addr = RES;
      3'b010: addr = ALUOut;
      3'b011: addr = Excpt;
      3'b100: addr = Reg_A;
      3'b101: addr = Reg_B;
      3'b110: addr = 32'b0;
      3'b111: addr = 32'b0;
    endcase
  end
endmodule