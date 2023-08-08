module mux_datasrc(
    input wire [3:0] sel,
    input wire [31:0] ALUOut,
    output reg [31:0] Write_data
);

always@(*) begin
    case (sel)
        4'b0000: Write_data = ALUOut;
        4'b0001: Write_data = 32'b0; // vem de LS
        4'b0010: Write_data = 32'b0; // vem de HI
        4'b0011: Write_data = 32'b0; // vem de LO
        4'b0100: Write_data = 32'b0; // vem de sign extend (1 to 32 bits)
        4'b0101: Write_data = 32'b0; // vem de sign extend (16 to 32 bits)
        4'b0110: Write_data = 32'b0; // vem de shift left 
        4'b0111: Write_data = 32'b0; // vem de reg shift
        4'b1000: Write_data = 32'b0; // binário de 227
        4'b1001: Write_data = 32'b0;
        4'b1010: Write_data = 32'b0;
        4'b1011: Write_data = 32'b0;
        4'b1100: Write_data = 32'b0;
        4'b1101: Write_data = 32'b0;
        4'b1110: Write_data = 32'b0;
        4'b1111: Write_data = 32'b0;
    endcase
  end
endmodule