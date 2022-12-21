module Bar_EXME(
    input clk, 
    input rst,
    input[31:0] pc_in,       output logic [31:0] pc_out,
    input[4:0] rda_in,       output logic[4:0] rda_out,
    input[2:0] funct3_in,    output logic[2:0] funct3_out,
    input[31:0] DMWdata_in,  output logic[31:0] DMWdata_out,
    input[31:0] ALUOut_in,   output logic[31:0] ALUOut_out,
    input[3:0] MemRW_in,     output logic[3:0] MemRW_out,
    input DMOn_in,           output logic DMOn_out,
    input[1:0] WBSel_in,     output logic[1:0] WBSel_out,
    input RegWEn_in,         output logic RegWEn_out,
    input[31:0] CSR_rdata_in,  output logic [31:0] CSR_rdata_out,
    
    // add for axi signal modification
    input DMstall_axi,
    input PCstall_axi
);

always_ff@(posedge clk) begin
    if(rst)begin
        pc_out <= 32'b0;
        rda_out <= 5'b0;
        funct3_out <= 3'b0;
        DMWdata_out <= 32'b0;
        ALUOut_out <= 32'b0;
        MemRW_out <= 4'b1111;
        DMOn_out <= 1'b0;
        WBSel_out <= 2'b0;
        RegWEn_out <= 1'b0;
        CSR_rdata_out <= 32'b0;
    end
    else begin
        if(PCstall_axi)begin
            pc_out <= pc_out;
            rda_out <= rda_out;
            funct3_out <= funct3_out;
            DMWdata_out <= DMWdata_out;
            ALUOut_out <= ALUOut_out;
            MemRW_out <= MemRW_out;
            DMOn_out <= DMOn_out;
            WBSel_out <= WBSel_out;
            RegWEn_out <= RegWEn_out;
            CSR_rdata_out <= CSR_rdata_out;
        end
        else begin
            pc_out <= pc_in;
            rda_out <= rda_in;
            funct3_out <= funct3_in;
            DMWdata_out <= DMWdata_in;
            ALUOut_out <= ALUOut_in;
            MemRW_out <= MemRW_in;
            DMOn_out <= DMOn_in;
            WBSel_out <= WBSel_in;
            RegWEn_out <= RegWEn_in;
            CSR_rdata_out <= CSR_rdata_in;
        end
    end
end



endmodule
