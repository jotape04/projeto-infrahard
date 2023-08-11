module mux_datasrc(
    input wire [3:0] sel,
    input wire [31:0] ALUOut,
    input wire [31:0] LS,
    input wire [31:0] Hi,
    input wire [31:0] Lo,
    input wire [31:0] Sign_extend_1_32,
    input wire [31:0] Sign_extend_16_32,
    input wire [31:0] Shift_left,
    input wire [31:0] RegShift_out,
    output reg [31:0] Write_data
);

always@(*) begin
    case (sel)
        4'b0000: Write_data = ALUOut;
        4'b0001: Write_data = LS;
        4'b0010: Write_data = Hi;
        4'b0011: Write_data = Lo;
        4'b0100: Write_data = Sign_extend_1_32;
        4'b0101: Write_data = Sign_extend_16_32;
        4'b0110: Write_data = Shift_left;
        4'b0111: Write_data = Reg_shift;
        4'b1000: Write_data = 32'b11100011; // binário de 227
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