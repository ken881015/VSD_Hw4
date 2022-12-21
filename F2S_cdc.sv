module F2S_cdc(
    input s_clk,
    input s_rst,

    input  [31:0] WTOCNT_in,
    output [31:0] WTOCNT_out,

    input  WDEN_in,
    output WDEN_out,

    input  WDLIVE_in,
    output WDLIVE_out
);

logic [31:0] WTOCNT_ff1, WTOCNT_ff2;
logic        WDEN_ff1  , WDEN_ff2;
logic        WDLIVE_ff1, WDLIVE_ff2;

// slow to fast
always_ff @ (posedge s_clk) begin
    if(s_rst) begin
        WTOCNT_ff1 <= 32'b0;
        WTOCNT_ff2 <= 32'b0;
        WDEN_ff1 <= 1'b0;
        WDEN_ff2 <= 1'b0;
        WDLIVE_ff1 <= 1'b0;
        WDLIVE_ff2 <= 1'b0;
    end
    else begin
        WTOCNT_ff1 <= WTOCNT_in;
        WTOCNT_ff2 <= WTOCNT_ff1;

        WDEN_ff1 <= WDEN_in;
        WDEN_ff2 <= WDEN_ff1;

        WDLIVE_ff1 <= WDLIVE_in;
        WDLIVE_ff2 <= WDLIVE_ff1;
    end
end

assign WTOCNT_out = WTOCNT_ff2;
assign WDEN_out   = WDEN_ff2;
assign WDLIVE_out = WDLIVE_ff2;

endmodule