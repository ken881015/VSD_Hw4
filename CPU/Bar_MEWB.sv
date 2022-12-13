module Bar_MEWB(
    input clk, 
    input rst,
    input[31:0] pc_in,       output logic [31:0] pc_out,
    input [4:0] rda_in,     output logic [4:0] rda_out,
    input [31:0] ALUOut_in, output logic [31:0] ALUOut_out,
    input [31:0] DMRdata_in,  output logic [31:0] DMRdata_out,
    input [2:0] funct3_in,  output logic [2:0] funct3_out,
    input [1:0] WBSel_in,   output logic [1:0] WBSel_out,
    input RegWEn_in,        output logic RegWEn_out,
    input[31:0] CSR_rdata_in,  output logic [31:0] CSR_rdata_out,

    input PCstall_axi
);

// assign DMRdata_out = DMRdata_in;

always_ff @(posedge rst or posedge clk ) begin
    if(rst) begin
        pc_out <= 32'b0;
        rda_out    <= 5'b0;
        ALUOut_out <= 32'b0;
        DMRdata_out <= 32'b0;
        funct3_out <= 3'b0;
        WBSel_out  <= 2'b0;
        RegWEn_out <= 1'b0;
        CSR_rdata_out <= 32'b0;
    end
    else begin
        if(PCstall_axi) begin
            pc_out <= pc_out;
            rda_out    <= rda_out;
            ALUOut_out <= ALUOut_out;
            DMRdata_out <= DMRdata_out;
            funct3_out <= funct3_out;
            WBSel_out  <= WBSel_out;
            RegWEn_out <=  RegWEn_out;
            CSR_rdata_out <= CSR_rdata_out;
        end
        else begin
            pc_out <= pc_in;
            rda_out    <= rda_in;
            ALUOut_out <= ALUOut_in;
            DMRdata_out <= DMRdata_in;
            funct3_out <= funct3_in;
            WBSel_out  <= WBSel_in;
            RegWEn_out <=  RegWEn_in;
            CSR_rdata_out <= CSR_rdata_in;
        end
    end
end

endmodule
