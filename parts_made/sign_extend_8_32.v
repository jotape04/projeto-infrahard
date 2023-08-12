module sign_extend_8_32 (
  input wire [31:0] Data_in,
  output wire [31:0] Data_out
);

  assign Data_out ={{24{1'b0}}, Data_in[7:0]}; // estende oo byte menos ignificativo

endmodule