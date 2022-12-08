module Bar_IFID(
    input clk,
    input rst,
    input init,
    input PCSel_EX,
    input DH_flush,

    input[31:0] pc_in, output logic[31:0] pc_out,
    input[31:0] inst_in, output logic[31:0] inst_out,
    
    // add for axi signal modification
    input DMstall_axi,
    input PCstall_axi
);

// without delay because sram has did it
// flush when jump happend
logic DH_flush_delay;
logic PCSel_EX_delay;
logic [31:0] inst_delay;

always_ff @(posedge rst or posedge clk ) begin
    if(rst)begin
        pc_out <= 32'b0;
        DH_flush_delay <= 1'b0;
        PCSel_EX_delay <= 1'b0;
        inst_delay <= 32'b0;
    end
    else begin
        if(PCstall_axi)begin
            pc_out <= pc_out;
            DH_flush_delay <= DH_flush_delay;
            PCSel_EX_delay <= PCSel_EX_delay;
            inst_delay <= inst_delay;
        end
        else begin
            if(PCSel_EX == 1'b1) pc_out <= 32'd0;
            else if(DH_flush == 1'b1) pc_out <= pc_out;
            else pc_out <= pc_in;

            DH_flush_delay <= DH_flush;
            PCSel_EX_delay <= PCSel_EX;

            inst_delay <= inst_in;
        end
    end
end

always_comb begin
    if(init) inst_out = 32'b0;
    else if(DH_flush_delay) inst_out = inst_delay;
    else if(PCSel_EX_delay) inst_out = 32'b0;
    else inst_out = inst_in;
end

endmodule