module S2F_cdc(
    input f_clk,
    input f_rst,

    input  WTO_in,
    output WTO_out
);

logic fast1_reg, fast2_reg;

always_ff @ (posedge f_clk) begin
    if(f_rst) begin
        fast1_reg <= 1'b0;
        fast2_reg <= 1'b0;
    end
    else begin
        fast1_reg <= WTO_in;
        fast2_reg <= fast1_reg;
    end
end

assign WTO_out = fast2_reg;

endmodule