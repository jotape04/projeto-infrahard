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
    wire PC_Write;
    wire [1:0] ExcptCtrl;
    wire [2:0] IorD;
    wire [1:0] SSCtrl;
    wire mult_ctrl;
    wire DIVASelect;
    wire DIVBSelect;
    wire RegAWrite;
    wire RegBWrite;
    wire MDSelect;
    wire MEM_write_or_read;
    wire HiCtrl;
    wire LoCtrl;
    wire MDRCtrl;
    wire IR_Write;
    wire LSCtrl;
    wire [1:0] RegDst;
    wire RegWrite;
    wire A_Write;
    wire B_Write;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [2:0] ALUCtrl;
    wire [2:0] PCSource;
    wire [3:0] DataSrc;
    wire ALUOutCtrl;

    // Data Wires
    wire [31:0] PC_in;
    wire [31:0] PC_out;

    wire [31:0] RES;
    wire [31:0] ALUOut;
    wire [31:0] Excpt;
    wire [31:0] Reg_A;
    wire [31:0] Reg_B;
    wire [31:0] addr;

    wire [31:0] Write_data_Reg;
    wire [31:0] Write_data_Mem;
    wire [31:0] Mem_data;

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET; // the immediate
    wire [4:0] RD = OFFSET[15:11];

    wire [4:0] Write_Reg;

    wire [31:0] Read_data1;
    wire [31:0] Read_data2;

    wire [31:0] A_Out;
    wire [31:0] B_Out;

    wire [31:0] Src_A;
    wire [31:0] MDR;

    wire [31:0] Src_B;
    wire [31:0] SignExtend16to32; // the extended immediate
    wire [31:0] SignExtendShift;

    wire [31:0] SeiLa;
    wire [31:0] Seila2;
    wire [31:0] EPC;

    wire [31:0] MultHi;
    wire [31:0] MultLo;

    wire [31:0] DIV_A_in;
    wire [31:0] DIV_B_in;
    wire [31:0] DivHi;
    wire [31:0] DivLo;
    wire DIVQ;

    wire [31:0] Hi_in;
    wire [31:0] Hi_out;

    wire [31:0] Lo_in;
    wire [31:0] Lo_out;

    wire [31:0] MDR_out;

    wire [31:0] LS_out;

    sign_extend_16_32 signExt16to32( // extends the immediate
        OFFSET,
        SignExtend16to32
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
        Reg_A,
        Reg_B,
        addr
    );

    mux_2_to_1 MuxDivASelect_(
        DIVASelect,
        A_Out,
        MDR,
        DIV_A_in
    );

    mux_2_to_1 MuxDivBSelect_(
        DIVBSelect,
        B_Out,
        MDR,
        DIV_B_in
    );

    mux_2_to_1 MuxHi_(
        MDSelect,
        DivHi,
        MultHi,
        Hi_in,
    );

    mux_2_to_1 MuxLo_(
        MDSelect,
        DivLo,
        MultLo,
        Lo_in,
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
        Write_data_Reg
    );

    mux_ulaA MuxA_(
        ALUSrcA,
        PC_out,
        A_Out,
        MDR,
        Src_A
    );

    mux_ulaB MuxB_(
        ALUSrcB,
        B_Out,
        SignExtend16to32,
        SignExtendShift,
	    Src_B
    );

    mux_pcsource MuxPC_(
        PCSource,
        RES,
        ALUOut,
        SeiLa,
        Seila2,
        MDR,
        EPC,
        PC_in
    );

    Registrador PC_(
        clk,
        reset,
        PC_Write,
        PC_in,
        PC_out
    );

    ss SS_(
        clk,
        reset,
        SSCtrl,
        B_Out,
        MDR,
        Write_data_Mem
    );

    mult Mult_(
        clk,
        reset,
        mult_ctrl,
        A_Out,
        B_Out,
        MultHi,
        MultLo
    );

    div Div_(
        clk,
        reset,
        RegAWrite,
        RegBWrite,
        DIV_A_in,
        DIV_B_in,
        DivHi,
        DivLo,
        DIVQ
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

    Registrador LS_(
        clk,
        reset,
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
        A_Write,
        Read_data1,
        A_Out
    );

    Registrador B_(
        clk,
        reset,
        B_Write,
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

    ctrl_unit Ctrl_(
        clk,//
        reset,
        Gt,//
        Eq,
        Lt,
        Ng,
        Zr,
        Ofw,
        OPCODE,//
        PC_Write,//
        IorD,
        MEM_write_or_read,
        IR_Write,
        RegDst,
        RegWrite,
        AB_Write,
        ALUSrcA,
        ALUSrcB,
        ALUCtrl,
        ALUOutCtrl,
        PCSource,
        DataSrc,
        reset
    );

endmodule

/* //! todo:
[x] - aplicar sign_extend_16_32
[] - aplicar shiftleft para resultar em SignExtendShift
[x] - implementar registrador ALUOut junto com o controlador ALUOutCtrl (?)
*/