module LoadSize(
    input  wire [1:0] LoadSize_Ctrl,
    input  wire [31:0] data_in,
    output wire [31:0] write_data 
);
	
    wire [31:0] half_quarter; 

    assign half_quarter = (LoadSize_Ctrl[0]) ? {16'd0, data_in[15:0]} : {24'd0, data_in[7:0]}; //escreve metade ou o primeiro quarto e preenche os outros bits com 0
    assign write_data = (LoadSize_Ctrl[1]) ? data_in : half_quarter; //sobrescreve tudo ou nao

endmodule