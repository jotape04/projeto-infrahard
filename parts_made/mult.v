module mult(
    input wire clk,
    input wire mult_ctrl,
    input wire reset,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] Hi,
    output reg [31:0] Lo

);

    reg [31:0] M; 
    reg [31:0] Q;   
    reg Q1;
    reg [31:0] A;
    reg [5:0] counter;

    reg aux = 1;
    
    always @ (posedge clk)begin

        if(mult_ctrl == 1'b0)begin
            counter = 6'b000000;
            Q = 32'b00000000000000000000000000000000;
            M = 32'b00000000000000000000000000000000;
            Q1 = 1'b0;
            A = 32'b00000000000000000000000000000000;

        end
        else begin
            if(counter == 6'b000000) begin
                Q = a;
                M = b;
                counter = counter + 1;
            end
            else begin 
                if(Q[0] == 1'b1 && Q1 == 1'b0) begin

                    A = A - M;

                end 

                else if(Q[0] == 1'b0 && Q1 == 1'b1) begin

                    A = A + M;

                end 

                {A, Q, Q1} = {A, Q, Q1} >> 1'b1;

                if(A[30] == 1'b1)begin

                    A[31] = 1'b1; 

                end

                counter = counter + 1'b1;
            end

            if(counter == 6'b100001) begin
                Hi = A;
                Lo = Q;
            end
        end
    end
endmodule