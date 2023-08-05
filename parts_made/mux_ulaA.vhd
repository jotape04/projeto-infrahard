module mux_ulaA(
    input wire [1:0] sel,
    input wire [31:0] PC,
    input wire [31:0] Reg_A,
    input wire [31:0] MDR,
    output wire [31:0] Scr_A
);

    always@(*) begin
        case (sel)
        2'b00: Scr_A = PC;
        2'b01: Scr_A = Reg_A;
        2'b10: Scr_A = MDR;
        endcase
    end
endmodule