module StoreSize(
    
    input  wire [1:0]  StoreSize_Ctrl,
    input  wire [31:0] data_in,
    input  wire [31:0] B,
    output reg [31:0] write_data

);

    always @(*) begin
        case(StoreSize_Ctrl)
            2'b00: write_data = data_in; // sw
            2'b01: write_data = {data_in[31:16], B[15:0]}; // sh
            2'b10: write_data = {data_in[31:8], B[7:0]}; // sb
            default: write_data = 32'd0; // Valor padrão para casos não especificados
        endcase
    end

endmodule 