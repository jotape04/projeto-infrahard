module mux_shift_amount(
    input wire ShiftAmt,
    input wire [31:0]Reg_B,
    input wire [4:0]instruction_10_6

    output reg [4:0]out
);

always@(*) begin
    case (ShiftAmt)
        
        1'b0: out = Reg_B[4:0];
        1'b1: out = instruction_10_6;

    endcase

  end

endmodule