module reg_shift(
    input wire [2:0] sel,
    input wire [31:0] src,
    input wire [4:0] amt,
    output reg [31:0] out
);

    always @(*) begin
        case (sel)
            3'b011: out <= src >> amt;
            3'b010: out <= src << amt;
            3'b100: out <= src >>> amt;
        endcase
    end

endmodule