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
    output reg PCWrite,
    output reg PCWriteCond,
    output reg [1:0] ExcptCtrl,
    output reg [2:0] IorD,
    output reg [1:0] SSCtrl,
    output reg mult_ctrl,
    output reg DIVASelect,
    output reg DIVBSelect,
    output reg div_ctrl,
    output reg MDSelect,
    output reg MEM_write_or_read,
    output reg HiCtrl,
    output reg LoCtrl,
    output reg MDRCtrl,
    output reg IR_Write,
    output reg [1:0] LSCtrl,
    output reg [1:0] RegDst,
    output reg RegWrite,
    output reg AB_Write,
    output reg [1:0] ALUSrcA,
    output reg [1:0] ALUSrcB,
    output reg [2:0] ALUCtrl,
    output reg ALUOutCtrl,
    output reg EPCCtrl,
    output reg [2:0] PCSource,
    output reg [3:0] DataSrc,
    output reg ShiftSrc,
    output reg ShiftAmt,
    output reg [2:0] ShiftCtrl,
    output reg [1:0] Branch_Ctrl,

    // reset controller
    output reg reset_out
);

    reg [2:0] COUNTER;
    reg [5:0] STATE;

    parameter ST_COMMON = 6'd0;
    parameter ST_ADD = 6'd1;
    parameter ST_ADDI = 6'd2;
    parameter ST_RESET = 6'd3;
    parameter ST_AND = 6'd4;
    parameter ST_SUB = 6'd5;
    parameter ST_MULT = 6'd6;
    parameter ST_DIV = 6'd7;
    parameter ST_DIVM = 6'd8;
    parameter ST_MFHI = 6'd9;
    parameter ST_MFLO = 6'd10;
    parameter ST_JR = 6'd11;
    parameter ST_SRL = 6'd12;
    parameter ST_SLL = 6'd13;
    parameter ST_SRA = 6'd14;
    parameter ST_SLLV = 6'd15;
    parameter ST_SRAV = 6'd16;
    parameter ST_SLT = 6'd17;
    parameter ST_RTE = 6'd18;
    parameter ST_ADDIU = 6'd19;
    parameter ST_BEQ = 6'd20;
    parameter ST_BNE = 6'd21;
    parameter ST_BLE = 6'd22;
    parameter ST_BGT = 6'd23;
    parameter ST_LUI = 6'd24;


    parameter ST_EXCP_OPCODE_INEXISTS = 6'd34;
    parameter ST_EXCP_OVERFLOW = 6'd35;
    parameter ST_EXCP_DIVZERO = 6'd36;

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

    // aux elements
    reg [1:0] exceptionCtrl;
    

    initial begin
        reset_out = 1'b1;
    end

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            if (STATE != ST_RESET) begin
                STATE = ST_RESET;

                PCWrite= 1'b0;
                PCWriteCond= 1'b0;
                ExcptCtrl= 2'b00;
                IorD= 3'b000;
                SSCtrl= 2'b00;
                mult_ctrl= 1'b0;
                DIVASelect= 1'b0;
                DIVBSelect= 1'b0;
                div_ctrl= 1'b0;
                MDSelect= 1'b0;
                MEM_write_or_read= 1'b0;
                HiCtrl= 1'b0;
                LoCtrl= 1'b0;
                MDRCtrl= 1'b0;
                IR_Write= 1'b0;
                LSCtrl= 2'b00;
                RegDst= 2'b00;
                RegWrite= 1'b0;
                AB_Write= 1'b0;
                ALUSrcA= 2'b00;
                ALUSrcB= 2'b00;
                ALUCtrl= 3'b000;
                ALUOutCtrl= 1'b0;
                EPCCtrl= 1'b0;
                PCSource= 3'b000;
                DataSrc= 4'b0000;
                ShiftSrc= 1'b0;
                ShiftAmt= 1'b0;
                ShiftCtrl= 3'b000;
                Branch_Ctrl= 2'b00;

                reset_out = 1'b1;
                COUNTER = 6'b000000;
            end
            else begin
                STATE = ST_COMMON;

                PCWrite= 1'b0;
                PCWriteCond= 1'b0;
                ExcptCtrl= 2'b00;
                IorD= 3'b000;
                SSCtrl= 2'b00;
                mult_ctrl= 1'b0;
                DIVASelect= 1'b0;
                DIVBSelect= 1'b0;
                div_ctrl= 1'b0;
                MDSelect= 1'b0;
                MEM_write_or_read= 1'b0;
                HiCtrl= 1'b0;
                LoCtrl= 1'b0;
                MDRCtrl= 1'b0;
                IR_Write= 1'b0;
                LSCtrl= 2'b00;
                RegDst= 2'b00;
                RegWrite= 1'b0;
                AB_Write= 1'b0;
                ALUSrcA= 2'b00;
                ALUSrcB= 2'b00;
                ALUCtrl= 3'b000;
                ALUOutCtrl= 1'b0;
                EPCCtrl= 1'b0;
                PCSource= 3'b000;
                DataSrc= 4'b0000;
                ShiftSrc= 1'b0;
                ShiftAmt= 1'b0;
                ShiftCtrl= 3'b000;
                Branch_Ctrl= 2'b00;

                reset_out = 1'b0; ///
                COUNTER = 6'b000000;
            end
        end
        else begin
            case (STATE)
                ST_COMMON: begin
                    if (COUNTER == 6'b000000 || COUNTER == 6'b000001 || COUNTER == 6'b000010) begin
                        STATE = ST_COMMON;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00; // PC
                        ALUSrcB= 2'b01; // 4
                        ALUCtrl= 3'b001; // operação de ADD
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 6'b000011) begin
                        STATE = ST_COMMON;

                        PCWrite= 1'b1; // escrever em PC 
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;// ler da memória
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b1; //
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b01; //
                        ALUCtrl= 3'b001; // operação de ADD
                        ALUOutCtrl= 1'b1; // escrever em ALUOut
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 6'b000100) begin
                        STATE = ST_COMMON;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b1; ///
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end

                    else if (COUNTER == 6'b000101) begin
                        case (OPCODE)
                            R_TYPE: begin
                                case(Funct)
                                ADD: begin
                                    STATE = ST_ADD;
                                end
                                AND: begin
                                    STATE = ST_AND;
                                end
                                SUB: begin
                                    STATE = ST_SUB;
                                end
                                MULT: begin
                                    STATE = ST_MULT;
                                end
                                DIV: begin
                                    STATE = ST_DIV;
                                end
                                DIVM: begin
                                    STATE = ST_DIVM;
                                end
                                MFHI: begin
                                    STATE = ST_MFHI;
                                end
                                MFLO: begin
                                    STATE = ST_MFLO;
                                end
                                  
                                endcase
                            end
                            ADDI: begin
                                STATE = ST_ADDI;
                            end
                            RESET: begin
                                STATE = ST_RESET;
                            end
                            default: begin
                                $display("We're going to the opcode inexists");
                                STATE = ST_EXCP_OPCODE_INEXISTS;
                            end
                        endcase
                       
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000000;
                    end
                end
                ST_ADD: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b001; ///
                        ALUOutCtrl= 1'b1; ///
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000001) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b1; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b001; ///
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000; ///
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000010) begin

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b0; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b001; ///
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000; //
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        PCWrite = 1'b0;
                        PCWriteCond = 1'b0;
                        Branch_Ctrl = 2'b00;
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
                        COUNTER = 6'b000000;
                    end
                end
                ST_ADDI: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_ADDI;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00; ///
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b10; ///
                        ALUCtrl= 3'b001; ///
                        ALUOutCtrl= 1'b1; ///
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000001) begin
                        STATE = ST_ADDI;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b10; ///
                        ALUCtrl= 3'b001; ///
                        ALUOutCtrl= 1'b1; ///
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000010) begin
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end
                ST_RESET: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_RESET;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b1;
                        COUNTER = 6'b000000;
                    end
            	end
                ST_AND: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000001) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000010) begin
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end
                ST_SUB: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000001) begin
                        STATE = ST_ADD;

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000010) begin
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;
                 

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end
                ST_MULT:begin
                    if(COUNTER == 6'b000000) begin // reseta os sinais de controle
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b010001) begin //counter == 33 sai da multiplicaçao e escreve em hi e lo
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b1;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b1;
                        LoCtrl= 1'b1;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000000;
                        STATE = ST_COMMON;
                    end
                    else begin //realizando multiplicacao
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b1;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER + 1;
                    end
                end
                ST_DIV: begin
                    if(COUNTER == 6'b000000) begin      //resetando sinais para iniciar a divisão
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    if(COUNTER == 6'b010001) begin     // saindo da divisao
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b1;
                        LoCtrl= 1'b1;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000000;
                        STATE = ST_COMMON;
                    end
                    else begin      //realizando operacao de divisao
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b1;
                        LoCtrl= 1'b1;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                end    
                ST_EXCP_OPCODE_INEXISTS, ST_EXCP_OVERFLOW, ST_EXCP_DIVZERO: begin
                    if (COUNTER == 6'b000) begin
                        case (STATE)
                        ST_EXCP_OPCODE_INEXISTS: exceptionCtrl = 2'b00;
                        ST_EXCP_OVERFLOW: exceptionCtrl = 2'b01;
                        ST_EXCP_DIVZERO: exceptionCtrl = 2'b10;
                        endcase
                        
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= exceptionCtrl; /// which exception address it's gonna be
                        IorD= 3'b011; /// get the exception as an address
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0; /// we're gonna read from the memory
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00; /// PC
                        ALUSrcB= 2'b01; /// 4
                        ALUCtrl= 3'b010; /// SUB
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b1; ///
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;
                    end
                    if (COUNTER == 6'b001 || COUNTER == 6'b001) begin
                        case (STATE)
                        ST_EXCP_OPCODE_INEXISTS: exceptionCtrl = 2'b00;
                        ST_EXCP_OVERFLOW: exceptionCtrl = 2'b01;
                        ST_EXCP_DIVZERO: exceptionCtrl = 2'b10;
                        endcase
                        
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= exceptionCtrl; /// which exception address it's gonna be
                        IorD= 3'b011; /// get the exception as an address
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0; /// we're gonna read from the memory
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00; /// done
                        ALUSrcB= 2'b00; /// done
                        ALUCtrl= 3'b000; /// done
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0; /// done
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;
                    end
                    
                    STATE = ST_COMMON;
                    COUNTER = 6'b000000;
                end
                ST_MFHI: begin
                    STATE = ST_MFHI;
        
                    PCWrite= 1'b0;
                    PCWriteCond= 1'b0;
                    ExcptCtrl= 2'b00;
                    IorD= 3'b000;
                    SSCtrl= 2'b00;
                    mult_ctrl= 1'b0;
                    DIVASelect= 1'b0;
                    DIVBSelect= 1'b0;
                    div_ctrl= 1'b0;
                    MDSelect= 1'b0;
                    MEM_write_or_read= 1'b0;
                    HiCtrl= 1'b0;
                    LoCtrl= 1'b0;
                    MDRCtrl= 1'b0;
                    IR_Write= 1'b0;
                    LSCtrl= 2'b00;
                    RegDst= 2'b01;
                    RegWrite= 1'b1;
                    AB_Write= 1'b0;
                    ALUSrcA= 2'b00;
                    ALUSrcB= 2'b00;
                    ALUCtrl= 3'b000;
                    ALUOutCtrl= 1'b0;
                    EPCCtrl= 1'b0;
                    PCSource= 3'b000;
                    DataSrc= 4'b0010;
                    ShiftSrc= 1'b0;
                    ShiftAmt= 1'b0;
                    ShiftCtrl= 3'b000;
                    Branch_Ctrl= 2'b00;

                    reset_out = 1'b0;
                    STATE = ST_COMMON;
                    COUNTER = 6'b000000;

                end
                ST_MFLO: begin
            
                    PCWrite= 1'b0;
                    PCWriteCond= 1'b0;
                    ExcptCtrl= 2'b00;
                    IorD= 3'b000;
                    SSCtrl= 2'b00;
                    mult_ctrl= 1'b0;
                    DIVASelect= 1'b0;
                    DIVBSelect= 1'b0;
                    div_ctrl= 1'b0;
                    MDSelect= 1'b0;
                    MEM_write_or_read= 1'b0;
                    HiCtrl= 1'b0;
                    LoCtrl= 1'b0;
                    MDRCtrl= 1'b0;
                    IR_Write= 1'b0;
                    LSCtrl= 2'b00;
                    RegDst= 2'b01;
                    RegWrite= 1'b1;
                    AB_Write= 1'b0;
                    ALUSrcA= 2'b00;
                    ALUSrcB= 2'b00;
                    ALUCtrl= 3'b000;
                    ALUOutCtrl= 1'b0;
                    EPCCtrl= 1'b0;
                    PCSource= 3'b000;
                    DataSrc= 4'b0011;
                    ShiftSrc= 1'b0;
                    ShiftAmt= 1'b0;
                    ShiftCtrl= 3'b000;
                    Branch_Ctrl= 2'b00;

                    reset_out = 1'b0;
                    STATE = ST_COMMON;
                    COUNTER = 6'b000000;

                end
                ST_JR : begin
                
                  
                end

                ST_SRL: begin
                    if(COUNTER == 6'b0000) begin
                        STATE = ST_SRL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b001;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000001;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SRL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b011;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000010;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SRL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b011;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end


                ST_SLL: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_SLL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b001;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000001;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SLL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b010;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000010;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SLL;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b010;
                        Branch_Ctrl= 2'b00;


                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end


                ST_SRA: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_SRA;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b001;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000001;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SRA;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'100;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000010;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SRA;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111;
                        ShiftSrc= 1'b1;
                        ShiftAmt= 1'b1;
                        ShiftCtrl= 3'b100;
                        Branch_Ctrl= 2'b00;


                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end


                ST_SLLV: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_SLLV;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b001;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000001;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SLLV;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b010;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000010;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SLLV;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b010;
                        Branch_Ctrl= 2'b00;


                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end
                
	   endcase
        end      
    end
endmodule