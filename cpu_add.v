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
    wire [2:0]IorD;
    wire MEM_write_or_read;
    wire IR_Write;
    wire [1:0]RegDst;
    wire RegWrite;
    wire AB_Write;
    wire [1:0]ALUSrcA;
    wire [1:0]ALUSrcB;
    wire [2:0] ALUCtrl;
    wire [2:0]PCSource;
    wire [3:0]DataSrc;

    // Data Wires
    wire [31:0] PC_in;
    wire [31:0] PC_out;

    wire [31:0] RES;
    wire [31:0] ALUOut;
    wire [31:0] Excpt;
    wire [31:0] Reg_A;
    wire [31:0] Reg_B;
    wire [31:0] addr;

    wire [31:0] Write_data;
    wire [31:0] Mem_data;

    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] OFFSET;

    wire [4:0] Write_Reg;

    wire Write_Data;
    wire [31:0] Read_data1;
    wire [31:0] Read_data2;

    wire [31:0] A_Out;
    wire [31:0] B_Out;

    wire [31:0] SrcA;
    wire [31:0] MDR;

    wire [31:0] SrcB;
    wire SignExtend;
    wire SignExtendShift;

    wire [31:0] SeiLa;
    wire [31:0] Seila2;
    wire [31:0] EPC;



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

    mux_regdst MuxRegDst_(
        RegDst,
        RT,
        OFFSET,
        Write_Reg
    );

    mux_datasrc MuxDataSrc_(
        DataSrc,
        RES,
        Write_data_Reg
    );

    mux_ulaA MuxA_(
        ALUSrcA,
        PC_out,
        A_Out,
        MDR,
        SrcA
    );

    mux_ulaB MuxB_(
        ALUSrcB,
        B_Out,
        SignExtend,
        SignExtendShift,
	SrcB
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

    Memoria MEM_(
        clk,
        addr,
        MEM_write_or_read,
        Write_data_Mem,
        Mem_data
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

    Banco_reg Regs_(
        clk,
        reset,
        RS,
        RT,
        Write_Reg,
        Write_data_Reg,
        RegWrite,
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
        SrcA,
        SrcB,
        ALUCtrl,
        Gt,
        Eq,
        RES,
        Lt,
        Ofw,
        Ng,
        Zr
    );

    ctrl_unit Ctrl_(
        clk,
        reset,
        Ofw,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt,
        OPCODE,
        PC_Write,
        MEM_write_or_read,
        IR_Write,
        RegWrite,
        AB_Write,
        ALUCtrl,
        RegDst,
        ALUSrcA,
        ALUSrcB,
        PCSource,
        IorD,
        DataSrc
    );

endmodule