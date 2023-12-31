module mux_ulaB(
    input wire [1:0] sel,
    input wire [31:0] Reg_B,
    input wire [31:0] sign_extend_16_32,
    input wire [31:0] sign_extend_shift_left,
    output reg [31:0] Scr_B
);

    always@(*) begin
        case (sel)
        2'b00: Scr_B = Reg_B;
        2'b01: Scr_B = 32'b100;
        2'b10: Scr_B = sign_extend_16_32;
        2'b11: Scr_B = sign_extend_shift_left;
        endcase
    end
endmodule