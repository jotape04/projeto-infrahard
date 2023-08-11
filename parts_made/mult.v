module mult(
    input wire clk,
    input wire mult_ctrl,
    input wire reset,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] Hi,
    output reg [31:0] Lo,
    output reg mult_end

);

    integer count_cycles = -1;
    reg [64:0] add;
    reg [64:0] sub;
    reg [64:0] produto;
    reg [31:0] complemento2;

    always @(posedge clk) begin
        if(reset == 1'b1) begin
            Hi = 32'b0;
            Lo = 32'b0;
            mult_end = 1'b0;
            add = 65'b0;
            sub = 65'b0;
            produto = 65'b0;
            complemento2 = 32'b0;
            count_cycles = -1;
        end
        if(mult_ctrl == 1'b1) begin
            add = {a, 33'b0};
            complemento2 = (~a + 1'b1);
            sub = {complemento2, 33'b0}; 
            produto = {32'b0, b, 1'b0};
            count_cycles = 32;
            mult_end = 1'b0;
        end

        case (produto[1:0])
            2'b01: produto = produto + add;
            2'b10: produto = produto + sub;
        endcase

        produto = produto >>> 1;
        
        if(count_cycles > 0) begin
            count_cycles = (count_cycles - 1);
        end

        if(count_cycles == 0) begin
            Hi = produto[64:33];
            Lo = produto[32:1];
            mult_end = 1'b1;

            // reseting
            add = 65'b0;
            sub = 65'b0;
            produto = 65'b0;
            count_cycles = -1;
        end
    end
    
endmodule
