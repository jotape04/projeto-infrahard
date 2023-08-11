module mux_excpt_ctrl(
    input wire [1:0]sel,
    output reg [31:0] out
);

    always@(*) begin
        case (sel)
            2'b00: out = 32'b11111101; // 253
            2'b01: out = 32'b11111110; //254;
            2'b10: out = 32'b11111111; //255;
            2'b11: out = 32'b0;
        endcase
    end
endmodule