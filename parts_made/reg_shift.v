module reg_shift(
    input wire [2:0] sel,
    input wire [31:0] src,
    input wire [4:0] amt,
    output reg [31:0] out
);

    if(sel == 3'b011) 
    begin

        assign out = src >> amt;

    end 
    else if(sel == 3'b010) 
    begin

        assign out = src << amt;

    end
    else if(sel == 3'b100) 
    begin

        assign out = src >>> amt;

    end

endmodule