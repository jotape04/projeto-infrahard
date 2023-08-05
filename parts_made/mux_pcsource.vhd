module mux_pcsource(
  input wire [2:0] sel,
  input wire [31:0] RES,
  input wire [31:0] ALUOut,
  input wire [31:0] Seila,
  input wire [31:0] Seila2,
  input wire [31:0] MDR,
  input wire [31:0] EPC,
  output reg [31:0] PC_in
);
  
  always@(*) begin
    case (sel)
      3'b000: PC_in = RES;
      3'b001: PC_in = ALUOut;
      3'b010: PC_in = SeiLa;
      3'b011: PC_in = Seila2;
      3'b100: PC_in = MDR;
      3'b101: PC_in = EPC;
      3'b110: PC_in = 32'b0;
      3'b111: PC_in = 32'b0;
    endcase
  end
endmodule