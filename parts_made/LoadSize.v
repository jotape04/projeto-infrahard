module LoadSize(
    input  wire [1:0] LoadSize_Ctrl,
    input  wire [31:0] data_in,
    output reg [31:0] write_data // Mudança para 'reg' aqui
);

    always @(*) begin
        case(LoadSize_Ctrl)
            2'b00: write_data = data_in; // lw
            2'b01: write_data = {16'd0, data_in[15:0]}; // lh
            2'b10: write_data = {24'd0, data_in[7:0]}; // lb
            default: write_data = 32'd0; // Valor padrão para casos não especificados
        endcase
    end

endmodule