module PC (
    input clk,
    input rst,
    input PCSel_EX,
    input DH_flush,
    input [31:0] PC_jmp,

    output logic [31:0] pc_out,

    input PCstall_axi,
    input DMstall_axi
);

always_ff @(posedge rst or posedge clk) begin
    if(rst)begin
        pc_out <= 32'b0;
    end
    else begin
        if(PCstall_axi) begin
            pc_out <= pc_out;
        end
        else begin
            if(PCSel_EX==1'b1) pc_out <= PC_jmp;
            else if(DH_flush == 1'b1) pc_out <= pc_out;
            else pc_out <= pc_out + 32'd4;
        end
    end
end
    
endmodule
