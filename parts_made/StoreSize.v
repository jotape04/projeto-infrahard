module StoreSize(
    
    input  wire [1:0]  StoreSize_Ctrl,
    input  wire [31:0] data_in,
    input  wire [31:0] B,
    output wire  [31:0] write_data

);

//	00 = byte 
//  01 = halfword  
//  10 = word
	
    wire [31:0] half_quarter; 

    assign half_quarter = (StoreSize_Ctrl[0]) ? {data_in[31:16], B[15:0]} : {data_in[31:8], B[7:0]}; //sobrescreve apenas o primeiro byte ou os dois primeiros
    assign write_data = (StoreSize_Ctrl[1]) ? B : half_quarter; //sobrescreve tudo ou nao


endmodule 