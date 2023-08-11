module shift_left_2_PC (
  input wire [4:0] rs,
  input wire [4:0] rt,
  input wire [15:0] offset, //veio de {Instr25_21, Instr20_16, Instr15_0} do Instr_Reg
  output wire [27:0] data_out //vai para jump_address_31_0 do mux_pcsource
);

  wire [25:0] data_in;

  assign data_in = {rs, rt, offset}

  assign data_out = {data_in, {2{1'b0}}}; //concatena data_in (MSB) com o número 0 extendido para 2 bits (LSB)

endmodule