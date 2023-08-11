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

    // Opcode
    input wire [5:0] OPCODE,
    input wire [5:0] Funct,

    // Controllers
    output reg PC_Write,
    output reg [2:0] IorD,
    output reg MEM_write_or_read,
    output reg IR_Write,
    output reg [1:0] RegDst,
    output reg RegWrite,
    output reg AB_Write,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [2:0] ALUCtrl,
    output reg ALUOutCtrl,
    output reg [2:0] PCSource,
    output reg [3:0] DataSrc,

    // reset controller
    output reg reset_out
);

    reg [2:0] COUNTER;
    reg [1:0] STATE;

    parameter ST_COMMON = 2'b00;
    parameter ST_ADD = 2'b01;
    parameter ST_ADDI = 2'b10;
    parameter ST_RESET = 2'b11;

    // Different opcodes
    // R-type
    parameter R_TYPE = 6'b000000;
    // Reset
    parameter RESET = 6'b111111;
    // I-type
    parameter ADDI = 6'h8;
    parameter ADDIU = 6'h9;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter BLE = 6'h6;
    parameter BGT = 6'h7;
    parameter ADDM = 6'h1; // ? new one
    parameter LB = 6'h20;
    parameter LH = 6'h21;
    parameter LUI = 6'hf;
    parameter LW = 6'h23;
    parameter SB = 6'h28;
    parameter SH = 6'h29;
    parameter SLTI = 6'ha;
    parameter SW = 6'h2b;
    // J-type
    parameter J = 6'h2;
    parameter JAL = 6'h3;

    // Different functs
    parameter ADD = 6'h20;
    parameter AND = 6'h24;
    parameter DIV = 6'h1a;
    parameter MULT = 6'h18;
    parameter JR = 6'h8;
    parameter MFHI = 6'h10;
    parameter MFLO = 6'h12;
    parameter SLL = 6'h0;
    parameter SLLV = 6'h4;
    parameter SLT = 6'h2a;
    parameter SRA = 6'h3;
    parameter SRAV = 6'h7;
    parameter SRL = 6'h2;
    parameter SUB = 6'h22;
    parameter BREAK = 6'hd;
    parameter RTE = 6'h13;
    parameter DIVM = 6'h5; // ? new one
    

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
                ALUOutCtrl = 1'b0;
                RegDst = 2'b00;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                PCSource = 3'b000;
                IorD = 3'b000;
                DataSrc = 4'b0000;

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
                ALUOutCtrl = 1'b0;
                RegDst = 2'b00;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b00;
                PCSource = 3'b000;
                IorD = 3'b000;
                DataSrc = 4'b0000;

                reset_out = 1'b0; ///
                COUNTER = 3'b000;
            end
        end
        else begin
            case (STATE)
                ST_COMMON: begin
                    if (COUNTER == 3'b000 || COUNTER == 3'b001 || COUNTER == 3'b010) begin
                        STATE = ST_COMMON;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; //
                        ALUOutCtrl = 1'b0; // ! pay attention
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b01; //
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b011) begin
                        STATE = ST_COMMON;

                        PC_Write = 1'b1; //
                        MEM_write_or_read = 1'b0; //
                        IR_Write = 1'b1; //
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; //
                        ALUOutCtrl = 1'b1; // ! pay attention
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00; //
                        ALUSrcB = 2'b01; //
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;
                        // AluOutCtrl é pra ser 1

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b100) begin
                        STATE = ST_COMMON;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b1; ///
                        ALUCtrl = 3'b000;
                        ALUOutCtrl = 1'b0; // ! pay attention
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b00;
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 3'b101) begin
                        case (OPCODE)
                            R_TYPE: begin
                                case(Funct)
                                ADD: begin
                                    STATE = ST_ADD;
                                end
                                endcase
                            end
                            ADDI: begin
                                $display("ADDI");
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
                        ALUOutCtrl = 1'b0;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b00;
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = 3'b000;
                    end
                end
                ST_ADD: begin
                    if (COUNTER == 3'b000) begin
                        STATE = ST_ADD;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b1;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b00; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 3'b001) begin
                        STATE = ST_ADD;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b1; ///
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b0;
                        RegDst = 2'b01; ///
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b00; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000; ///

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 3'b010) begin
                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0; ///
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b0;
                        RegDst = 2'b01; ///
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b00; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000; ///

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 3'b000;
                    end
                end
                ST_ADDI: begin
                    if (COUNTER == 3'b000) begin
                        STATE = ST_ADDI;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b1; // ! pay attention
                        RegDst = 2'b00; ///
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b10; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 3'b001) begin
                        STATE = ST_ADDI;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b1;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b1; // ! pay attention
                        RegDst = 2'b00; ///
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b10; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 3'b010) begin
                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b001; ///
                        ALUOutCtrl = 1'b1; // ! pay attention
                        RegDst = 2'b00; ///
                        ALUSrcA = 2'b01; ///
                        ALUSrcB = 2'b10; ///
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 3'b000;
                    end
                end
                ST_RESET: begin
                    if (COUNTER == 3'b000) begin
                        STATE = ST_RESET;

                        PC_Write = 1'b0;
                        MEM_write_or_read = 1'b0;
                        IR_Write = 1'b0;
                        RegWrite = 1'b0;
                        AB_Write = 1'b0;
                        ALUCtrl = 3'b000;
                        ALUOutCtrl = 1'b0;
                        RegDst = 2'b00;
                        ALUSrcA = 2'b00;
                        ALUSrcB = 2'b00;
                        PCSource = 3'b000;
                        IorD = 3'b000;
                        DataSrc = 4'b0000;

                        reset_out = 1'b1;
                        COUNTER = 3'b000;
                    end
            	end
	   endcase
        end      
    end
endmodule