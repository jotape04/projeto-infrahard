module ctrl_unit(
    input wire clk,
    input wire reset,

    // Flags
    input wire Gt,
    input wire Eq,
    input wire Lt,
    input wire Ng,
    input wire Zr,
    input wire Ofw,

    input wire [5:0] OPCODE,

    output reg PC_Write,
    output reg MEM_write_or_read,
    output reg IR_Write,
    output reg RegWrite,
    output reg AB_Write,
    output reg ALUCtrl,
    output reg RegDst,
    output reg ALUSrcA,
    output reg ALUSrcB,
    output reg PCSource
    output reg IorD,

    output reg reset_out
);

    reg [2:0] COUNTER;
    reg [1:0] STATE;

    parameter ST_COMMON = 2'b00;
    parameter ST_ADD = 2'b01;
    parameter ST_ADDI = 2'b10;
    parameter ST_RESET = 2'b11;

    parameter ADD = 6'b000000;
    parameter ADDI = 6'b001000;
    parameter RESET = 6'b111111;

    initial begin
        reset_out = 1'b1;
    end

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            if (STATE != ST_RESET) begin
                STATE = ST_RESET;

                PC_Write = 1'b0;
                MEM_write_or_read = 1'b0;
                IR_Write = 1'b0;
                RegWrite = 1'b0;
                AB_Write = 1'b0;
                ALUCtrl = 3'b000;
                RegDst = 2'b00;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                PCSource = 3'b000;
                IorD = 3'b000;

                reset_out = 1'b1;
                COUNTER = 3'b000;
            end
            else begin
                STATE = ST_COMMON;

                PC_Write = 1'b0;
                MEM_write_or_read = 1'b0;
                IR_Write = 1'b0;
                RegWrite = 1'b0;
                AB_Write = 1'b0;
                ALUCtrl = 3'b000;
                RegDst = 2'b00;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                PCSource = 3'b000;
                IorD = 3'b000;

                reset_out = 1'b0;
                COUNTER = 3'b000;
            end
        end
        else begin
            case (STATE)
                ST_COMMON: begin
                    if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b01;
                        PCSource = 3'b000;
                        IorD = 3'b000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b011) begin
                        PC_Write = 1'b1;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b1;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b01;
                        PCSource = 3'b000;
                        IorD = 3'b000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b100) begin
                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b1;
                        ALUCtrl = 3'b000;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b00;
                        PCSource = 3'b000;
                        IorD = 3'b000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b101) begin
                        case (OPCODE)
                            ADD: begin
                                STATE = ST_ADD;
                            end
                            ADDI: begin
                                STATE = ST_ADDI;
                            end
                            RESET: begin
                                STATE = ST_RESET;
                            end
                            default: begin
                                STATE = ST_COMMON;
                            end
                        endcase
                       
                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b000;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b00;
                        PCSource = 3'b000;
                        IorD = 3'b000;

                        reset_out = 1'b0;
                        COUNTER = 3'b000;
                    end
                end
                ST_ADD: begin
                    PC_Write = 1'b0;
                    MEM_write_or_read = 1'b0;
                    IR_Write = 1'b0;
                    RegWrite = 1'b1;
                    AB_Write = 1'b0;
                    ALUCtrl = 3'b001;
                    RegDst = 2'b01;
                    ALUSrcA = 2'b01;
                    ALUSrcB = 2'b00;
                    PCSource = 3'b000;
                    IorD = 3'b000;

                    reset_out = 1'b0;
                    COUNTER = COUNTER + 1;

                    if (COUNTER == 3'b010) begin
                        STATE = ST_COMMON;
                        COUNTER = 3'b000;
                    end
                end
                ST_ADDI: begin
                    PC_Write = 1'b0;
                    MEM_write_or_read = 1'b0;
                    IR_Write = 1'b0;
                    RegWrite = 1'b1;
                    AB_Write = 1'b0;
                    ALUCtrl = 3'b001;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b01;
                    ALUSrcB = 2'b10;
                    PCSource = 3'b000;
                    IorD = 3'b000;

                    reset_out = 1'b0;
                    COUNTER = COUNTER + 1;

                    if (COUNTER == 3'b010) begin
                        STATE = ST_COMMON;
                        COUNTER = 3'b000;
                    end
                end
                ST_RESET: begin
                    PC_Write = 1'b0;
                    MEM_write_or_read = 1'b0;
                    IR_Write = 1'b0;
                    RegWrite = 1'b0;
                    AB_Write = 1'b0;
                    ALUCtrl = 3'b000;
                    RegDst = 2'b00;
                    ALUSrcA = 2'b00;
                    ALUSrcB = 2'b00;
                    PCSource = 3'b000;
                    IorD = 3'b000;

                    reset_out = 1'b1;
                    COUNTER = 3'b000;
            endcase
        end      
    end
endmodule