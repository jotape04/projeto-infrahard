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
    wire [2:0] IorD;
    wire MEM_write_or_read;
    wire IR_Write;
    wire [1:0] RegDst;
    wire RegWrite;
    wire AB_Write;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [2:0] ALUCtrl;
    wire [2:0] PCSource;
    wire [3:0] DataSrc;

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
    wire [4:0] RD;
    wire [15:0] OFFSET;

    wire [4:0] Write_Reg;

    wire [31:0] Read_data1;
    wire [31:0] Read_data2;

    wire [31:0] A_Out;
    wire [31:0] B_Out;

    wire [31:0] Src_A;
    wire [31:0] MDR;

    wire [31:0] Src_B;
    wire [31:0] SignExtend16to32;
    wire [31:0] SignExtendShift;

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
        RD,
        Write_Reg
    );

    mux_datasrc MuxDataSrc_(
        DataSrc,
        ALUOut,
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

    Memoria MEM_(
        addr,
        clk,
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
        PCSource,
        DataSrc
    );

endmodule

/* //! todo:
[] - aplicar sign_extend_16_32
[] - aplicar shiftleft para resultar em SignExtendShift
[] - implementar registrador ALUOut junto com o controlador ALUOutCtrl (?)
*/