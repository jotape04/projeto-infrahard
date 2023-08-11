module shift_left_2_PC (
  input wire [31:0] pc, 
  input wire [4:0] rs,
  input wire [4:0] rt,
  input wire [15:0] offset, //veio de {Instr25_21, Instr20_16, Instr15_0} do Instr_Reg
  output wire [31:0] data_out //vai para jump_address_31_0 do mux_pcsource
);

  wire [3:0] pc_4most;

  assign pc_4most = pc[31:28];

  wire [25:0] data_in;

  assign data_in = {rs, rt, offset};

  assign data_out = {pc_4most, data_in, {2{1'b0}}}; //concatena data_in (MSB) com o número 0 extendido para 2 bits (LSB)

endmodule