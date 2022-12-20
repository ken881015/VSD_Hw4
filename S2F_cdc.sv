module S2F_cdc(
    input f_clk,
    input f_rst,
    input s_clk,
    input s_rst,

    input  in,
    output out
);

logic fast1_reg, fast2_reg, fast3_reg;

always_ff @ (posedge f_clk) begin
    if(f_rst) begin
        fast1_reg <= 1'b0;
        fast2_reg <= 1'b0;
        fast3_reg <= 1'b0;
    end
    else begin
        fast1_reg <= in;
        fast2_reg <= fast1_reg;
        fast3_reg <= fast2_reg;
    end
end

assign out = fast1_reg & (~fast3_reg);

endmodule