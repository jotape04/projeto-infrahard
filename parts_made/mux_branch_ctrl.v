module mux_branch_ctrl(
    input wire [1:0] branch_ctrl,
    input wire gt,
    input wire eq,
    input wire PCWrite,
    input wire PCWriteCond,

    output reg out
);

always@(*) begin
    case (branch_ctrl)
        2'b00: out = (eq & PCWriteCond) | PCWrite ; // beq
        2'b01: out = (~eq & PCWriteCond) | PCWrite; // bne
        2'b10: out = (~gt & PCWriteCond) | PCWrite; // ble
        2'b11: out = (gt & PCWriteCond) | PCWrite ; // bgt
    endcase

  end

endmodule
