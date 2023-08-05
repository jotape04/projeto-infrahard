module mux_regdst(
  input wire [1:0] sel,
  input wire [4:0] instruction_20_16,
  input wire [4:0] instruction_15_11,
  output reg [4:0] WriteReg
);
  
  always@(*) begin
    case (sel)
      2'b00: WriteReg = instruction_20_16;
      2'b01: WriteReg = instruction_15_11;
      2'b10: WriteReg = 5'b11101; //reg 29
      2'b11: WriteReg = 5'b11111; //reg 31
    endcase
  end
endmodule