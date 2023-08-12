module cpu_add(
    input clk,
    input reset
);

    // Flags
    wire Gt;
    wire Eq;
    wire Lt;
    wire Ng;
    wire Zr;
    wire Ofw;

    // Control Wires
    wire PCWrite;
    wire PCWriteCond;
    wire [1:0] ExcptCtrl;
    wire [2:0] IorD;
    wire [1:0] SSCtrl;
    wire mult_ctrl;
    wire DIVASelect;
    wire DIVBSelect;
    wire div_ctrl;
    wire MDSelect;
    wire MEM_write_or_read;
    wire HiCtrl;
    wire LoCtrl;
    wire DivQuotCtrl;
    wire DivRemCtrl;
    wire MDRCtrl;
    wire IR_Write;
    wire [1:0] LSCtrl;
    wire [1:0] RegDst;
    wire RegWrite;
    wire AB_Write;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [2:0] ALUCtrl;
    wire ALUOutCtrl;
    wire EPCCtrl;
    wire [2:0] PCSource;
    wire [3:0] DataSrc;
    wire ShiftSrc;
    wire ShiftAmt;
    wire [2:0] ShiftCtrl;
    wire [1:0] Branch_Ctrl;

    // Data Wires
    wire [31:0] PC_in;
    wire [31:0] PC_out;

    wire PCCtrl;

    wire [31:0] RES;
    wire [31:0] ALUOut;
    wire [31:0] Excpt;
    wire [31:0] addr;

    wire [31:0] Write_data_Reg;
    wire [31:0] Write_data_Mem;
    wire [31:0] Mem_data;

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET; // the immediate
    wire [4:0] RD = OFFSET[15:11];
    wire [5:0] Funct = OFFSET[5:0];
    wire [4:0] shamt = OFFSET[10:6];

    wire [4:0] Write_Reg;

    wire [31:0] Read_data1;
    wire [31:0] Read_data2;

    wire [31:0] A_Out;
    wire [31:0] B_Out;

    wire [31:0] Src_A;

    wire [31:0] Src_B;
    wire [31:0] SignExtend16to32; // the extended immediate
    wire [31:0] SignExtendShiftLeft;
    wire [31:0] Sign_extend_1_32_out;

    wire [31:0] Shift_left;
    wire [31:0] shift_left_2_pc_out;
    wire [31:0] sign_extend_8_32_out;
    wire [31:0] EPC;
    wire [31:0] RegShift_out;

    wire [31:0] MultHi;
    wire [31:0] MultLo;

    wire [31:0] DIV_A_in;
    wire [31:0] DIV_B_in;
    wire [31:0] DivHi;
    wire [31:0] DivLo;
    wire DIVQ;

    wire [31:0] DivQuot_out;
    wire [31:0] DivRem_out;

    wire [31:0] Hi_in;
    wire [31:0] Hi_out;

    wire [31:0] Lo_in;
    wire [31:0] Lo_out;

    wire [31:0] MDR_out;

    wire [31:0] LS_out;

    wire [31:0] EPC_out;

    wire [31:0] ShiftSrc_in;
    wire[4:0] Shamt_in;

    sign_extend_16_32 signExt16to32(
        OFFSET,
        SignExtend16to32
    );

    sign_extend_8_32 signExt8to32(
        MDR_out,
        sign_extend_8_32_out
    );

    mux_excpt_ctrl MuxExcpt_(
        ExcptCtrl,
        Excpt
    );

    mux_iord MuxIord_(
        IorD,
        PC_out,
        RES,
        ALUOut,
        Excpt,
        A_Out,
        B_Out,
        addr
    );

    mux_2_to_1 MuxDivASelect_(
        DIVASelect,
        A_Out,
        MDR_out,
        DIV_A_in
    );

    mux_2_to_1 MuxDivBSelect_(
        DIVBSelect,
        B_Out,
        MDR_out,
        DIV_B_in
    );

    mux_2_to_1 MuxHi_(
        MDSelect,
        DivHi,
        MultHi,
        Hi_in
    );

    mux_2_to_1 MuxLo_(
        MDSelect,
        DivLo,
        MultLo,
        Lo_in
    );

    mux_regdst MuxRegDst_(
        RegDst,
        RT,
        RD,
        Write_Reg
    );

    mux_datasrc MuxDataSrc_(
        DataSrc,
        ALUOut,
        LS_out,
        Hi_out,
        Lo_out,
        Sign_extend_1_32_out,
        SignExtend16to32,
        Shift_left,
        RegShift_out,
        Write_data_Reg
    );

    mux_ulaA MuxA_(
        ALUSrcA,
        PC_out,
        A_Out,
        MDR_out,
        Src_A
    );

    mux_ulaB MuxB_(
        ALUSrcB,
        B_Out,
        SignExtend16to32,
        SignExtendShiftLeft,
	    Src_B
    );

    mux_pcsource MuxPC_(
        PCSource,
        RES,
        ALUOut,
        shift_left_2_pc_out,
        sign_extend_8_32_out,
        MDR_out,
        EPC_out,
        PC_in
    );

    Registrador PC_(
        clk,
        reset,
        PCCtrl,
        PC_in,
        PC_out
    );

    StoreSize SS_(
        SSCtrl,
        MDR_out,
        B_Out,
        Write_data_Mem
    );

    mult Mult_(
        clk,
        mult_ctrl,
        reset,
        A_Out,
        B_Out,
        MultHi,
        MultLo
    );

    div Div_(
        clk,
        reset,
        div_ctrl,
        DIV_A_in,
        DIV_B_in,
        DivHi,
        DivLo,
        DIVQ
    );

    Registrador DivQuot_(
        clk,
        reset,
        DivQuotCtrl,
        DivHi,
        DivQuot_out
    );

    Registrador DivRem_(
        clk,
        reset,
        DivRemCtrl,
        DivLo,
        DivRem_out
    );

    Memoria MEM_(
        addr,
        clk,
        MEM_write_or_read,
        Write_data_Mem,
        Mem_data
    );

    Registrador Hi_(
        clk,
        reset,
        HiCtrl,
        Hi_in,
        Hi_out
    );

    Registrador Lo_(
        clk,
        reset,
        LoCtrl,
        Lo_in,
        Lo_out
    );

    Registrador MDR_(
        clk,
        reset,
        MDRCtrl,
        Mem_data,
        MDR_out
    );

    Instr_Reg IR_(
        clk,
        reset,
        IR_Write,
        Mem_data,
        OPCODE,
        RS,
        RT,
        OFFSET
    );

    LoadSize LS_(
        LSCtrl,
        MDR_out,
        LS_out
    );

    Banco_reg Regs_(
        clk,
        reset,
        RegWrite,
        RS,
        RT,
        Write_Reg,
        Write_data_Reg,
        Read_data1,
        Read_data2
    );

    Registrador A_(
        clk,
        reset,
        AB_Write,
        Read_data1,
        A_Out
    );

    Registrador B_(
        clk,
        reset,
        AB_Write,
        Read_data2,
        B_Out
    );

    ula32 ULA_(
        Src_A,
        Src_B,
        ALUCtrl,
        RES,
        Ofw,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );

    Registrador ALUOUT(
        clk,
        reset,
        ALUOutCtrl,
        RES,
        ALUOut
    );

    Registrador EPC_(
        clk,
        reset,
        EPCCtrl,
        RES,
        EPC_out
    );

    ctrl_unit Ctrl_(
        clk,
        reset,
        Gt,
        Eq,
        Lt,
        Ng,
        Zr,
        Ofw,
        DIVQ,
        OPCODE,
        Funct,
        PCWrite,
        PCWriteCond,
        ExcptCtrl,
        IorD,
        SSCtrl,
        mult_ctrl,
        DIVASelect,
        DIVBSelect,
        div_ctrl,
        MDSelect,
        MEM_write_or_read,
        HiCtrl,
        LoCtrl,
        DivQuotCtrl,
        DivRemCtrl,
        MDRCtrl,
        IR_Write,
        LSCtrl,
        RegDst,
        RegWrite,
        AB_Write,
        ALUSrcA,
        ALUSrcB,
        ALUCtrl,
        ALUOutCtrl,
        EPCCtrl,
        PCSource,
        DataSrc,
        ShiftSrc,
        ShiftAmt,
        ShiftCtrl,
        Branch_Ctrl,
        reset
    );

    mux_2_to_1 mux_shift_src(
        ShiftSrc,
        A_Out,
        B_Out,
        ShiftSrc_in
    );
    
    mux_shift_amount mux_shift_amt(
        ShiftAmt,
        B_Out,
        shamt,
        Shamt_in
    );

    reg_shift RegShift_(
        ShiftCtrl,
        ShiftSrc_in,
        Shamt_in,
        RegShift_out
    );

    mux_branch_ctrl mux_branch_ctrl (
        Branch_Ctrl,
        Gt,
        Eq,
        PCWrite,
        PCWriteCond,
        PCCtrl
    );

    shift_left_2_PC shift_left_2_PC(
        PC_out,
        RS,
        RT,
        OFFSET,
        shift_left_2_pc_out
    );

    sign_extend_1_32 sign_extend_1_32(
        Lt,
        Sign_extend_1_32_out 
    );

    shift_left_2 shift_left_2(
        SignExtend16to32,
        SignExtendShiftLeft
    );

    shift_left_16 shift_left_16(
        OFFSET,
        Shift_left
    );

endmodule