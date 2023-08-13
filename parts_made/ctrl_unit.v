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
    input reg DIVQ, // divisao por 0

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
    output reg DivQuotCtrl,
    output reg DivRemCtrl,
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

    reg [5:0] COUNTER;
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

    parameter ST_ADDM = 6'd25;
    parameter ST_SLTI = 6'd26;
    parameter ST_J = 6'd27;
    parameter ST_JAL = 6'd28;
    parameter ST_BREAK = 6'd29;

    parameter ST_LW = 6'd30;
    parameter ST_LH = 6'd31;
    parameter ST_LB = 6'd32;
    parameter ST_SW = 6'd33;
    parameter ST_SH = 6'd34;
    parameter ST_SB = 6'd35;

    parameter ST_EXCP_OPCODE_INEXISTS = 6'd36;
    parameter ST_EXCP_OVERFLOW = 6'd37;
    parameter ST_EXCP_DIVZERO = 6'd38;

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
    reg [1:0] branchCtrl;
    reg [1:0] lsCtrl;
    reg [1:0] ssCtrl;
    

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
                DivQuotCtrl= 1'b0;
                DivRemCtrl= 1'b0;
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
                DivQuotCtrl= 1'b0;
                DivRemCtrl= 1'b0;
                MDRCtrl= 1'b0;
                IR_Write= 1'b0;
                LSCtrl= 2'b00;
                RegDst= 2'b10;  // o registrador é o 29
                RegWrite= 1'b1; // escrevendo no registrador
                AB_Write= 1'b0;
                ALUSrcA= 2'b00;
                ALUSrcB= 2'b00;
                ALUCtrl= 3'b000;
                ALUOutCtrl= 1'b0;
                EPCCtrl= 1'b0;
                PCSource= 3'b000;
                DataSrc= 4'b1000; //selecionando o 227
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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

                                SRL: begin
                                    STATE = ST_SRL;
                                end

                                SLL: begin
                                    STATE = ST_SLL;
                                end

                                SRA: begin
                                    STATE = ST_SRA;
                                end

                                SLLV: begin
                                    STATE = ST_SLLV;
                                end

                                SRAV: begin
                                    STATE = ST_SRAV;
                                end

                                SLT: begin
                                    STATE = ST_SLT;
                                end

                                JR: begin
                                    STATE = ST_JR;
                                end

                                RTE: begin
                                    STATE = ST_RTE;
                                end
                                
                            endcase

                            end
                            ADDI: begin
                                STATE = ST_ADDI;
                            end

                            ADDIU: begin
                                STATE = ST_ADDIU;
                            end

                            BEQ: begin
                                STATE = ST_BEQ;
                            end

                            BNE: begin
                                STATE = ST_BNE;
                            end

                            BLE: begin
                                STATE = ST_BLE;
                            end

                            BGT: begin
                                STATE = ST_BGT;
                            end

                            ADDM: begin
                                STATE = ST_ADDM;
                            end

                            LB: begin
                                STATE = ST_LB;
                            end

                            LH: begin
                                STATE = ST_LH;
                            end

                            LW: begin
                                STATE = ST_LW;
                            end

                            LUI: begin
                                STATE = ST_LUI;
                            end

                            SB: begin
                                STATE = ST_SB;
                            end

                            SH: begin
                                STATE = ST_SH;
                            end

                            SW: begin
                                STATE = ST_SW;
                            end

                            SLTI: begin
                                STATE = ST_SLTI;
                            end

                            J: begin
                                STATE = ST_J;
                            end

                            JAL: begin
                                STATE = ST_JAL;
                            end

                            default: begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        if (Ofw == 1'b1) 
                        begin
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///
                            ALUOutCtrl= 1'b0; ///
                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        if (Ofw == 1'b1) 
                        begin
                            RegDst= 2'b00; ///
                            RegWrite= 1'b0; ///
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///

                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        if (Ofw == 1'b1) 
                        begin
                            RegDst= 2'b00; ///
                            RegWrite= 1'b0; ///
                            ALUSrcA= 2'b00; ///
                            ALUSrcB= 2'b00;
                            ALUCtrl= 3'b000; ///
                            ALUOutCtrl= 1'b0;

                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        if (Ofw == 1'b1) 
                        begin
                            RegDst= 2'b00; ///
                            RegWrite= 1'b0; ///
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///
                            ALUSrcB= 2'b00;
                            ALUOutCtrl= 1'b0;

                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                ST_ADDIU: begin
                    if (COUNTER == 6'b000000) begin
                        STATE = ST_ADDIU;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        STATE = ST_ADDIU;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        STATE = ST_AND;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b011;
                        ALUOutCtrl= 1'b1;
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
                        STATE = ST_AND;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b1; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b011; ///
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b011;
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
                        STATE = ST_SUB;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b010; ///
                        ALUOutCtrl= 1'b1;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                        if (Ofw == 1'b1) 
                        begin
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///
                            ALUOutCtrl= 1'b0; ///
                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
                    end
                    else if (COUNTER == 6'b000001) begin
                        STATE = ST_SUB;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b1; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b010; ///
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
                        if (Ofw == 1'b1) 
                        begin
                            RegDst= 2'b00; ///
                            RegWrite= 1'b0; ///
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///

                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b010;
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
                    if(COUNTER == 6'b100001) begin //counter == 33 sai da multiplicacao e escreve em hi e lo      
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b1;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b1;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b1;
                        LoCtrl= 1'b1;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                    else if(COUNTER < 6'b100001) begin //realizando multiplicacao
                        STATE = ST_MULT;
                        
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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

                //div está guardando o quociente e resto em hi e lo
                // *fazer registradores dedicados* !!!
                ST_DIV: begin
                    if(COUNTER == 6'b100001) begin     // saindo da divisao
                        STATE = ST_COMMON;
                        
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b1;   // ativado
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0; //nao armazena em hi
                        LoCtrl= 1'b0; //nao armazena em lo
                        DivQuotCtrl= 1'b1;
                        DivRemCtrl= 1'b1;
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
                        STATE = ST_DIV;
                        
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b000;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b1; // ativado
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0; //nao armazena
                        LoCtrl= 1'b0; //nao armazena
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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

                        if(DIVQ)begin
                            div_ctrl= 1'b0;
                            RegDst= 2'b00; ///
                            RegWrite= 1'b0; ///
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///
                            ALUSrcB= 2'b00;
                            ALUOutCtrl= 1'b0;

                            STATE = ST_EXCP_DIVZERO;
                            COUNTER = 6'b000000; 
                        end
                    end
                end    
                ST_EXCP_OPCODE_INEXISTS, ST_EXCP_OVERFLOW, ST_EXCP_DIVZERO: begin
                    if (COUNTER == 6'b000000) begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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

                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'b000001 || COUNTER == 6'b000010) begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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

                        COUNTER = COUNTER + 1;
                    end
                    else if (COUNTER == 6'd3) begin
                        PCWrite= 1'b1; /// write what's in MDR in PC
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 1'b0; /// done
                        IorD= 3'b000; /// done
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0; /// done
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0; // done
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
                        PCSource= 3'b011; /// write what's in MDR in PC
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        COUNTER = COUNTER + 1;
                    end
                    
                    else if (COUNTER == 6'd4) begin
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end
                end
                ST_MFHI: begin

                    if(COUNTER == 6'b000000) begin
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
                        HiCtrl= 1'b1;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        COUNTER = COUNTER + 1;
                        
                    end
                    else if(COUNTER == 6'b000001)begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
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
                end
                ST_MFLO: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_MFLO;
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
                        LoCtrl= 1'b1;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        COUNTER = COUNTER + 1;
                        
                    end
                    else if(COUNTER == 6'b000001)begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b0;
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
                end
                ST_BEQ, ST_BNE, ST_BLE, ST_BGT: begin
                    if (COUNTER == 6'd0) begin

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00; /// PC
                        ALUSrcB= 2'b11; /// sign_extend_shift_left
                        ALUCtrl= 3'b001; /// sum
                        ALUOutCtrl= 1'b1; /// write in ALUOut
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd1) begin
                        case (STATE)
                        ST_BEQ: branchCtrl = 2'b00;
                        ST_BNE: branchCtrl = 2'b01;
                        ST_BLE: branchCtrl = 2'b10;
                        ST_BGT: branchCtrl = 2'b11;
                        endcase

                        PCWrite= 1'b0;
                        PCWriteCond= 1'b1; /// we're gonna write based on the conditional
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; /// reg A
                        ALUSrcB= 2'b00; /// reg B
                        ALUCtrl= 3'b111; /// comparison
                        ALUOutCtrl= 1'b0; /// done
                        EPCCtrl= 1'b0;
                        PCSource= 3'b001; /// ALUOut = the address we just calculated
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= branchCtrl;

                        reset_out = 1'b0;

                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
                    end
                end
                ST_JR: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_JR;
                        PCWrite= 1'b1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
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
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_JR;
                        PCWrite= 1'b1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
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
                ST_J: begin
                    if (COUNTER == 6'd0) begin
                        PCWrite= 1'b1; /// write in PC
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        PCSource= 3'b010; /// get pc || (address << 2)
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
                    end
                end
                ST_SRL: begin
                    if(COUNTER == 6'b000000) begin
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b001; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0; // 
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; // 
                        ShiftCtrl= 3'b011; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111; //
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b011; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b001; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b010;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; //
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111; //
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b001; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b100; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111; //
                        ShiftSrc= 1'b1; //
                        ShiftAmt= 1'b1; //
                        ShiftCtrl= 3'b100; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b001; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b010; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111; //
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b010; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'd0;
                        STATE = ST_COMMON;

                    end
                    
                end
                ST_SRAV: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_SRAV;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
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
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b001; // 
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SRAV;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0; //
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000; //
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b100; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SRAV;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; //
                        RegWrite= 1'b1; //
                        AB_Write= 1'b0; //
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0111; //
                        ShiftSrc= 1'b0; //
                        ShiftAmt= 1'b0; //
                        ShiftCtrl= 3'b100; //
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
                    end
                end
                ST_SLT: begin
                    if(COUNTER == 6'b000000)begin
                        STATE = ST_SLT;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SLT;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SLT;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end     
                end
                ST_SLTI: begin
                    if(COUNTER == 6'b000000)begin
                        STATE = ST_SLTI;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_SLTI;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = COUNTER + 1;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_SLTI;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b1;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b111;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0100;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                    end  
                end
                ST_RTE: begin
                    STATE = ST_RTE;
                    PCWrite= 1'b1;
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
                    DivQuotCtrl= 1'b0;
                    DivRemCtrl= 1'b0;
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
                    PCSource= 3'b101;
                    DataSrc= 4'b0000;
                    ShiftSrc= 1'b0;
                    ShiftAmt= 1'b0;
                    ShiftCtrl= 3'b000;
                    Branch_Ctrl= 2'b00;

                    reset_out = 1'b0;
                    STATE = ST_COMMON;
                    COUNTER = 6'b000000;
                end 
                ST_LUI: begin
                   if(COUNTER == 6'b000000) begin
                        STATE = ST_LUI;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0101;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER + 1; 
                    
                   end
                   else if(COUNTER == 6'b000001) begin
                        STATE = ST_LUI;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0101;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        STATE = ST_COMMON;
                        COUNTER = 6'b000000;
                   end  
                end
                ST_ADDM: begin
                    if(COUNTER == 6'b000000) begin
                        STATE = ST_ADDM;
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b001;
                        ALUOutCtrl= 1'b1;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000001;
                    end
                    else if(COUNTER == 6'b000001) begin
                        STATE = ST_ADDM;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b010;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b1;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b001;
                        ALUOutCtrl= 1'b1;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000010;
                    end
                    else if(COUNTER == 6'b000010) begin
                        STATE = ST_ADDM;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b010;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b1;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01;
                        ALUSrcB= 2'b10;
                        ALUCtrl= 3'b001;
                        ALUOutCtrl= 1'b1;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000011;
                    end
                    else if(COUNTER == 6'b000011) begin
                        STATE = ST_ADDM;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b010;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b1;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b10;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b001;
                        ALUOutCtrl= 1'b1;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;
                        COUNTER = 6'b000100;
                    end
                    else if(COUNTER == 6'b000100) begin
                        STATE = ST_ADDM;
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b010;
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b1;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b1;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b10;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b001;
                        ALUOutCtrl= 1'b1;
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
                ST_JAL: begin
                    if (COUNTER == 6'd0) begin
                        STATE = ST_JAL;

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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00; // PC
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000; // load
                        ALUOutCtrl= 1'b1; // load in ALUOUT
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd1) begin
                        PCWrite= 1'b1; // write in PC
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
                        DivQuotCtrl= 1'b0;
                        DivRemCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b11; // reg 31
                        RegWrite= 1'b1; // escrever o valor de PC em reg 31
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b00;
                        ALUSrcB= 2'b00;
                        ALUCtrl= 3'b000;
                        ALUOutCtrl= 1'b0; // done
                        EPCCtrl= 1'b0;
                        PCSource= 3'b010; // get pc || (address << 2)
                        DataSrc= 4'b0000; // ALUOUT
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = 6'd0;
                        STATE = ST_COMMON;
                    end
                end

                // ST_DIVM:begin
                //     if(COUNTER == 6'd0 || COUNTER == 6'd1)begin
                //         STATE = ST_DIVM;

                //         PCWrite= 1'b0;
                //         PCWriteCond= 1'b0;
                //         ExcptCtrl= 2'b00;
                //         IorD= 3'b100;
                //         SSCtrl= 2'b00;
                //         mult_ctrl= 1'b0;
                //         DIVASelect= 1'b0;
                //         DIVBSelect= 1'b0;
                //         div_ctrl= 1'b0;
                //         MDSelect= 1'b0;
                //         MEM_write_or_read= 1'b0;
                //         HiCtrl= 1'b0;
                //         LoCtrl= 1'b0;
                //         DivQuotCtrl= 1'b0;
                //         DivRemCtrl= 1'b0;
                //         MDRCtrl= 1'b;
                //         IR_Write= 1'b0;
                //         LSCtrl= 2'b00;
                //         RegDst= 2'b00;
                //         RegWrite= 1'b0;
                //         AB_Write= 1'b0;
                //         ALUSrcA= 2'b00;
                //         ALUSrcB= 2'b00;
                //         ALUCtrl= 3'b000;
                //         ALUOutCtrl= 1'b0;
                //         EPCCtrl= 1'b0;
                //         PCSource= 3'b000;
                //         DataSrc= 4'b0000;
                //         ShiftSrc= 1'b0;
                //         ShiftAmt= 1'b0;
                //         ShiftCtrl= 3'b000;
                //         Branch_Ctrl= 2'b00;

                //         reset_out = 1'b0;
                //         COUNTER = COUNTER + 1;
                //     end
                //     else if(COUNTER == 6'd2 || COUNTER == 6'd3)begin
                //         STATE = ST_DIVM;
                        
                //         PCWrite= 1'b0;
                //         PCWriteCond= 1'b0;
                //         ExcptCtrl= 2'b00;
                //         IorD= 3'b101;
                //         SSCtrl= 2'b00;
                //         mult_ctrl= 1'b0;
                //         DIVASelect= 1'b1;
                //         DIVBSelect= 1'b1;
                //         div_ctrl= 1'b0;
                //         MDSelect= 1'b0;
                //         MEM_write_or_read= 1'b0;
                //         HiCtrl= 1'b0;
                //         LoCtrl= 1'b0;
                //         DivQuotCtrl= 1'b0;
                //         DivRemCtrl= 1'b0;
                //         MDRCtrl= 1'b0;
                //         IR_Write= 1'b0;
                //         LSCtrl= 2'b00;
                //         RegDst= 2'b00;
                //         RegWrite= 1'b0;
                //         AB_Write= 1'b0;
                //         ALUSrcA= 2'b00;
                //         ALUSrcB= 2'b00;
                //         ALUCtrl= 3'b000;
                //         ALUOutCtrl= 1'b0;
                //         EPCCtrl= 1'b0;
                //         PCSource= 3'b000;
                //         DataSrc= 4'b0000;
                //         ShiftSrc= 1'b0;
                //         ShiftAmt= 1'b0;
                //         ShiftCtrl= 3'b000;
                //         Branch_Ctrl= 2'b00;

                //         reset_out = 1'b1;
                //         COUNTER = COUNTER + 1;
                //     end
                //     else if(COUNTER < 6'd37)begin
                //         STATE = ST_DIVM;
                        
                //         PCWrite= 1'b0;
                //         PCWriteCond= 1'b0;
                //         ExcptCtrl= 2'b00;
                //         IorD= 3'b101;
                //         SSCtrl= 2'b00;
                //         mult_ctrl= 1'b0;
                //         DIVASelect= 1'b1;
                //         DIVBSelect= 1'b1;
                //         div_ctrl= 1'b1;
                //         MDSelect= 1'b0;
                //         MEM_write_or_read= 1'b0;
                //         HiCtrl= 1'b0;
                //         LoCtrl= 1'b0;
                //         DivQuotCtrl= 1'b0;
                //         DivRemCtrl= 1'b0;
                //         MDRCtrl= 1'b0;
                //         IR_Write= 1'b0;
                //         LSCtrl= 2'b00;
                //         RegDst= 2'b00;
                //         RegWrite= 1'b0;
                //         AB_Write= 1'b0;
                //         ALUSrcA= 2'b00;
                //         ALUSrcB= 2'b00;
                //         ALUCtrl= 3'b000;
                //         ALUOutCtrl= 1'b0;
                //         EPCCtrl= 1'b0;
                //         PCSource= 3'b000;
                //         DataSrc= 4'b0000;
                //         ShiftSrc= 1'b0;
                //         ShiftAmt= 1'b0;
                //         ShiftCtrl= 3'b000;
                //         Branch_Ctrl= 2'b00;

                //         reset_out = 1'b1;
                //         COUNTER = COUNTER + 1;

                //         if(DIVQ)begin
                //             div_ctrl= 1'b0;
                //             RegDst= 2'b00; ///
                //             RegWrite= 1'b0; ///
                //             ALUSrcA= 2'b00; ///
                //             ALUCtrl= 3'b000; ///
                //             ALUSrcB= 2'b00;
                //             ALUOutCtrl= 1'b0;

                //             STATE = ST_EXCP_DIVZERO;
                //             COUNTER = 6'b000000;
                //         end
                //     end
                //     else if(COUNTER == 6'd37)begin
                //         STATE = ST_COMMON;
                        
                //         PCWrite= 1'b0;
                //         PCWriteCond= 1'b0;
                //         ExcptCtrl= 2'b00;
                //         IorD= 3'b101;
                //         SSCtrl= 2'b00;
                //         mult_ctrl= 1'b0;
                //         DIVASelect= 1'b1;
                //         DIVBSelect= 1'b1;
                //         div_ctrl= 1'b1;
                //         MDSelect= 1'b0;
                //         MEM_write_or_read= 1'b0;
                //         HiCtrl= 1'b0;
                //         LoCtrl= 1'b0;
                //         DivQuotCtrl= 1'b1;
                //         DivRemCtrl= 1'b1;
                //         MDRCtrl= 1'b0;
                //         IR_Write= 1'b0;
                //         LSCtrl= 2'b00;
                //         RegDst= 2'b00;
                //         RegWrite= 1'b0;
                //         AB_Write= 1'b0;
                //         ALUSrcA= 2'b00;
                //         ALUSrcB= 2'b00;
                //         ALUCtrl= 3'b000;
                //         ALUOutCtrl= 1'b0;
                //         EPCCtrl= 1'b0;
                //         PCSource= 3'b000;
                //         DataSrc= 4'b0000;
                //         ShiftSrc= 1'b0;
                //         ShiftAmt= 1'b0;
                //         ShiftCtrl= 3'b000;
                //         Branch_Ctrl= 2'b00;

                //         reset_out = 1'b1;
                //         COUNTER = 6'b000000;
                //     end

                // end
                ST_LW, ST_LH, ST_LB, ST_SW, ST_SH, ST_SB: begin
                    if (COUNTER == 6'd0) begin // Mem[adress]; aluout = adress; adress = rs+signextend16to32(offset)
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b001; // RES
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0; // ler da memória
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; // reg A: rs
                        ALUSrcB= 2'b10; // sign_extend_16_32(offset)
                        ALUCtrl= 3'b001; // soma
                        ALUOutCtrl= 1'b1; // escrever em ALUOUT
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd1) begin // wait & close off aluout
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b001; // done
                        SSCtrl= 2'b00;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0; // lendo
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; // reg A: rs
                        ALUSrcB= 2'b10; // sign_extend_16_32(offset)
                        ALUCtrl= 3'b001; // soma
                        ALUOutCtrl= 1'b0; // done => shut it off, cause we'll need the address later
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd2) begin // mdr = mem[adress]; ssctrl; lsctrl
                        case(STATE)
                            ST_LW: begin
                                lsCtrl = 2'b00;
                                ssCtrl = 2'b00;
                            end
                            ST_LH: begin
                                lsCtrl = 2'b01;
                                ssCtrl = 2'b00;
                            end
                            ST_LB: begin
                                lsCtrl = 2'b10;
                                ssCtrl = 2'b00;
                            end
                            ST_SW: begin
                                lsCtrl = 2'b00;
                                ssCtrl = 2'b00;
                            end
                            ST_SH: begin
                                lsCtrl = 2'b00;
                                ssCtrl = 2'b01;
                            end
                            ST_SB: begin
                                lsCtrl = 2'b00;
                                ssCtrl = 2'b10;
                            end
                        endcase
                        PCWrite= 1'b0;
                        PCWriteCond= 1'b0;
                        ExcptCtrl= 2'b00;
                        IorD= 3'b001;
                        SSCtrl= ssCtrl;
                        mult_ctrl= 1'b0;
                        DIVASelect= 1'b0;
                        DIVBSelect= 1'b0;
                        div_ctrl= 1'b0;
                        MDSelect= 1'b0;
                        MEM_write_or_read= 1'b0;
                        HiCtrl= 1'b0;
                        LoCtrl= 1'b0;
                        MDRCtrl= 1'b1; // escrever em mdr, pq memória já carregou
                        IR_Write= 1'b0;
                        LSCtrl= lsCtrl;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; // reg A: rs
                        ALUSrcB= 2'b10; // sign_extend_16_32(offset)
                        ALUCtrl= 3'b001; // soma
                        ALUOutCtrl= 1'b0;
                        EPCCtrl= 1'b0;
                        PCSource= 3'b000;
                        DataSrc= 4'b0000;
                        ShiftSrc= 1'b0;
                        ShiftAmt= 1'b0;
                        ShiftCtrl= 3'b000;
                        Branch_Ctrl= 2'b00;

                        reset_out = 1'b0;

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd3) begin
                        case(STATE)
                        ST_SW, ST_SH, ST_SB: begin
                            // SSCtrl; close off MDR; MemWrite
                            PCWrite= 1'b0;
                            PCWriteCond= 1'b0;
                            ExcptCtrl= 2'b00;
                            IorD= 3'b010; // ALUOut => the address we saved
                            SSCtrl= ssCtrl; // ler de SSCtrl
                            mult_ctrl= 1'b0;
                            DIVASelect= 1'b0;
                            DIVBSelect= 1'b0;
                            div_ctrl= 1'b0;
                            MDSelect= 1'b0;
                            MEM_write_or_read= 1'b1; // escrever na memória
                            HiCtrl= 1'b0;
                            LoCtrl= 1'b0;
                            MDRCtrl= 1'b0; // done => fechar MDR pra não ter mudança
                            IR_Write= 1'b0;
                            LSCtrl= 2'b00; // x
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

                            COUNTER = 6'd0;
                            STATE = ST_COMMON;
                        end
                        ST_LW, ST_LH, ST_LB: begin
                            // lsCtrl; close off MDR; MemWrite
                            PCWrite= 1'b0;
                            PCWriteCond= 1'b0;
                            ExcptCtrl= 2'b00;
                            IorD= 3'b000;
                            SSCtrl= 0'b00; // x
                            mult_ctrl= 1'b0;
                            DIVASelect= 1'b0;
                            DIVBSelect= 1'b0;
                            div_ctrl= 1'b0;
                            MDSelect= 1'b0;
                            MEM_write_or_read= 1'b0;
                            HiCtrl= 1'b0;
                            LoCtrl= 1'b0;
                            MDRCtrl= 1'b0; // done => fechar MDR pra não ter mudança
                            IR_Write= 1'b0;
                            LSCtrl= lsCtrl; ///
                            RegDst= 2'b00; // escrever em rt
                            RegWrite= 1'b1;  // escrever
                            AB_Write= 1'b0;
                            ALUSrcA= 2'b00;
                            ALUSrcB= 2'b00;
                            ALUCtrl= 3'b000;
                            ALUOutCtrl= 1'b0;
                            EPCCtrl= 1'b0;
                            PCSource= 3'b000;
                            DataSrc= 4'b0001; // saída de ls
                            ShiftSrc= 1'b0;
                            ShiftAmt= 1'b0;
                            ShiftCtrl= 3'b000;
                            Branch_Ctrl= 2'b00;

                            reset_out = 1'b0;

                            COUNTER = 6'd0;
                            STATE = ST_COMMON;
                        end
                        endcase
                    end
                end
	        endcase
        end      
    end
endmodule