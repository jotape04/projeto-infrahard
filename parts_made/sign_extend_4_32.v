module sign_extend_4_32 (
  input wire [31:0] Data_in,
  output wire [31:0] Data_out
);

  assign Data_out ={{28{1'b0}}, Data_in[3:0]};

endmodule