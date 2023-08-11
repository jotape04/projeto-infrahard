module mux_branch_ctrl(
    input wire [1:0]branch_ctrl,
    input wire gt,
    input wire eq,

    input wire PCWriteCond,
    input wire PCWrite,

    output reg out
);

always@(*) begin
    case (branch_ctrl)
        
        2'b00: out = (gt & PCWriteCond) | PCWrite ;
        2'b01: out = (~gt & PCWriteCond) | PCWrite;
        2'b10: out = (~eq & PCWriteCond) | PCWrite;
        2'b11: out = (eq & PCWriteCond) | PCWrite ;

    endcase

  end

endmodule
