module div(
    input wire clk,
    input wire reset,
    input wire div_ctrl, // 1 para fazer a divisao
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] resto,
    output reg [31:0] quociente,
    
    output reg DIVQ //excecao divisao por 0

);

    reg [31:0] aux_a;
    reg [31:0] aux_b;
    reg [31:0] comp_b;
    reg sinal_a;
    reg sinal_b;
    reg div_start;
    reg div_end;
    reg [31:0] aux_quociente;
    reg [31:0] aux_resto;
    reg [32:0] aux_diff;
    integer counter_div;


    always @(posedge clk)begin

        if(div_ctrl == 1'b0)begin

            sinal_a = 1'b0; //indica o sinal de a -> 0 para pos e 1 para neg
            sinal_b = 1'b0; // \\ \\ \\  \\ \\  b  \\ \\ \\  \\  \\  \\  \\    
            div_start = 1'b0;
            DIVQ = 1'b0;
            div_end = 1'b0;
            aux_quociente = 32'b0;
            aux_resto = 32'b0;
            aux_diff = 33'b0;
            counter_div = 31;
            quociente = 32'b0;
            resto = 32'b0;

        end
        if (div_ctrl == 1'b1)
            begin
                if (reset)
                begin
                    quociente = 32'b0;
                    resto = 32'b0;
                    DIVQ = 1'b0;
                    div_start = 1'b0;
                    div_end = 1'b1;
                    sinal_a = 1'b0;
                    sinal_b = 1'b0;
                    aux_quociente = 32'b0;
                    aux_resto = 32'b0;
                    aux_diff = 32'b0;
                    counter_div = 0;
                end

                if (!div_end)
                begin
                    if (!div_start)
                    begin
                        
                        if (b == 32'b0)
                        begin
                            DIVQ = 1'b1;
                            div_end = 1'b1;
                        end

                        
                        else
                        begin 
                            
                            // tornando numerador positivo
                            if (a[31])
                            begin
                                aux_a = (~a + 1'b1);
                                sinal_a = 1'b1;
                            end
                            else
                            begin
                                aux_a = a; 
                            end

                            // tornando o divisor positivo
                            if (b[31])
                            begin
                                aux_b = (~b + 1'b1);
                                sinal_b = 1'b1;
                            end
                            else
                            begin
                                aux_b = b; 
                            end
                        end
                        div_start = 1'b1;
                    end

                    if (div_start)
                    begin
                        aux_resto = aux_resto << 1; 
                        aux_resto[0] = aux_a[counter_div];

                        comp_b = (~aux_b + 1'b1);
                        aux_diff = aux_resto + comp_b; 

                        if (aux_diff[32]) 
                        begin
                            aux_resto = aux_diff[31:0];
                        end

                        aux_quociente[counter_div] = aux_diff[32]; 

                        counter_div = counter_div - 1;

                        // gravando quociente 
                        if (counter_div == -1)
                        begin
                            if (sinal_a ^ sinal_b) // se a e b têm sinais diferentes
                            begin
                                quociente = (~aux_quociente + 1'b1);
                            end
                            else
                            begin
                                quociente = aux_quociente;
                            end

                            if (sinal_a)
                            begin
                                resto = (~aux_resto + 1'b1);
                            end
                            else
                            begin
                                resto = aux_resto;
                            end

                            div_end = 1'b1;
                        end
                    end
                end
            end
        end

endmodule