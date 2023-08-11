module sign_extend_1_32 (
    input wire [31:0] Data_in,
    output wire [31:0] Data_out
);
    input wire Entrada = [3:0] Data_in;

    assign Data_out = {28'b0, Entrada};

endmodule