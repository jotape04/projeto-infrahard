module div(
    input wire clk,
    input wire reset,
    input wire div_ctrl, // 1 para fazer a divisao
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] Hi,
    output reg [31:0] Lo,
    output reg div_end,
    output reg div_zero //excecao divisao por 0

);

    integer count_cycles = -1;
    reg flag;
    reg flagdiv;
    reg [31:0] temp_a;
    reg [31:0] temp_b;
    reg [31:0] remainder;
    reg [63:0] divisor;
    reg [63:0] dividendo;
    reg [63:0] diff;
    reg [31:0] quociente;

    always @(posedge clk) begin
		div_zero = 1'b0;
        if(reset == 1'b1) begin
            flag = 1'b0;
            flagdiv = 1'b0;
            temp_a = 32'b0;
            temp_b = 32'b0;
            remainder = 32'b0;
            divisor = 32'b0;
            dividendo = 32'b0;
            diff = 32'b0;
            quociente = 32'b0;
            Hi = 32'b0;
            Lo = 32'b0;
            div_end = 1'b0;
            div_zero = 1'b0;
        end

		if (div_ctrl == 1'b1) begin    
            if ((a[31] && b[31]) || (~a[31] && ~b[31]))
                flag = 1'b0;
            else
                flag = 1'b1;

            if (!a[31])
                flagdiv = 1'b0;
            else
                flagdiv = 1'b1;

            if (a[31]) 
                temp_a = (~a + 1'b1);
            else 
                temp_a = a;
            if (b[31])
                temp_b = (~b + 1'b1);
            else
                temp_b = b;
			
			div_end = 1'b0;
            quociente = 32'b0;
            dividendo = {32'b0, temp_a};
            divisor = {1'b0, temp_b, 31'b0};
            
            if (b == 32'b0)
				div_zero = 1'b1;
			else
				count_cycles = 32;
        end
        else begin
            diff = dividendo - divisor;

            quociente = quociente << 1;

            if (!diff[63]) begin
                dividendo = diff;
                quociente[0] = 1'b1;
            end

            divisor = divisor >> 1;
            count_cycles = count_cycles - 1;

            if (count_cycles == 0) begin
                if (flag)
                    Lo = (~quociente + 1'b1);
                else
                    Lo = quociente;
                
                if (flagdiv)
                    Hi = (~dividendo[31:0] + 1'b1);
                else
                    Hi = dividendo[31:0];
                
                div_end = 1'b1;

                remainder = 31'b0;
                divisor = 64'b0;
                dividendo = 64'b0;
                quociente = 32'b0;
                diff = 64'b0;
                flag = 1'b0;
                count_cycles = -1;
            end
        end

    end

endmodule