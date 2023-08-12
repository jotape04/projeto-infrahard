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
    reg [1:0] branchCtrl;
    

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
                RegDst= 2'b10; // o registrador é o 29
                RegWrite= 1'b1; // vamos escrever no registrador
                AB_Write= 1'b0;
                ALUSrcA= 2'b00;
                ALUSrcB= 2'b00;
                ALUCtrl= 3'b000;
                ALUOutCtrl= 1'b0;
                EPCCtrl= 1'b0;
                PCSource= 3'b000;
                DataSrc= 4'b1000; // vamos escrever 227
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
                    if (COUNTER == 6'd0) begin
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
                        if (Ofw == 1'b1) 
                        begin
                            ALUSrcA= 2'b00; ///
                            ALUCtrl= 3'b000; ///
                            ALUOutCtrl= 1'b0; ///
                            STATE = ST_EXCP_OVERFLOW;
                            COUNTER = 6'b000000;
                        end
                    end
                    else if (COUNTER == 6'd1) begin
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
                    if (COUNTER == 6'd0) begin
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
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b011; ///
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
                    else if (COUNTER == 6'd1) begin
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
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b01; ///
                        RegWrite= 1'b1; ///
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b011; ///
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
                        ALUCtrl= 3'b011; ///
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
                        ALUCtrl = 3'b010; ///
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
                ST_SUB: begin
                    if (COUNTER == 6'd0) begin
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
                        MDRCtrl= 1'b0;
                        IR_Write= 1'b0;
                        LSCtrl= 2'b00;
                        RegDst= 2'b00;
                        RegWrite= 1'b0;
                        AB_Write= 1'b0;
                        ALUSrcA= 2'b01; ///
                        ALUSrcB= 2'b00; ///
                        ALUCtrl= 3'b010; ///
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
                    else if (COUNTER == 6'd1) begin
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
                        ALUCtrl = 3'b010; ///
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
                ST_EXCP_OPCODE_INEXISTS, ST_EXCP_OVERFLOW, ST_EXCP_DIVZERO: begin
                    if (COUNTER == 6'd0) begin
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
                        MDRCtrl= 1'b1; // write from the memory
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

                        COUNTER = COUNTER +1;
                    end
                    else if (COUNTER == 6'd1 || COUNTER == 6'd2) begin
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
                        MDRCtrl= 1'b1; // write from the memory
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

                        COUNTER = COUNTER +1;
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
	   endcase
        end      
    end
endmodule

// if (COUNTER == 6'd0) begin
//     STATE = YOUR_STATE;

//     PCWrite= 1'b0;
//     PCWriteCond= 1'b0;
//     ExcptCtrl= 2'b00;
//     IorD= 3'b000;
//     SSCtrl= 2'b00;
//     mult_ctrl= 1'b0;
//     DIVASelect= 1'b0;
//     DIVBSelect= 1'b0;
//     div_ctrl= 1'b0;
//     MDSelect= 1'b0;
//     MEM_write_or_read= 1'b0;
//     HiCtrl= 1'b0;
//     LoCtrl= 1'b0;
//     MDRCtrl= 1'b0;
//     IR_Write= 1'b0;
//     LSCtrl= 2'b00;
//     RegDst= 2'b00;
//     RegWrite= 1'b0;
//     AB_Write= 1'b0;
//     ALUSrcA= 2'b00;
//     ALUSrcB= 2'b00;
//     ALUCtrl= 3'b000;
//     ALUOutCtrl= 1'b0;
//     EPCCtrl= 1'b0;
//     PCSource= 3'b000;
//     DataSrc= 4'b0000;
//     ShiftSrc= 1'b0;
//     ShiftAmt= 1'b0;
//     ShiftCtrl= 3'b000;
//     Branch_Ctrl= 2'b00;

//     reset_out = 1'b0;

//     COUNTER = COUNTER +1;
// end