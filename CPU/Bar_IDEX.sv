module Bar_IDEX(
    input clk, 
    input rst,
    input DH_flush,
    input PCSel_EX,
    input[31:0] pc_in,      output logic [31:0]pc_out,
    input [4:0]r1a_in,      output logic[4:0]r1a_out,
    input [4:0]r2a_in,      output logic[4:0]r2a_out,    
    input[4:0]rda_in,       output logic  [4:0]rda_out,
    input[31:0]imm_in,      output logic [31:0]imm_out,
    input[2:0]funct3_in,    output logic [2:0] funct3_out,
    input ASel_in,          output logic  ASel_out,
    input BSel_in,          output logic  BSel_out,
    input[3:0] ALUSel_in,   output logic [3:0] ALUSel_out,
    input[3:0] MemRW_in,    output logic [3:0] MemRW_out,
    input[1:0] WBSel_in,    output logic [1:0] WBSel_out,
    input RegWEn_in,        output logic  RegWEn_out,
    input [6:0] opcode_in,  output logic [6:0] opcode_out,
    input BrUn_in,          output logic BrUn_out,
    input LUI_in,           output logic  LUI_out,
    input DMOn_in,          output logic DMOn_out,
    input CSRWEn_in,        output logic CSRWEn_out,
    
    // add for axi signal modification
    input DMstall_axi,
    input PCstall_axi
);

always_ff @(posedge clk)begin
    if(rst)begin
        pc_out      <= 32'b0;
        r1a_out     <= 5'b0;
        r2a_out     <= 5'b0;        
        rda_out     <= 5'b0;
        imm_out     <= 32'b0;
        funct3_out  <= 3'b0;
        ASel_out    <= 1'b0;
        BSel_out    <= 1'b0;
        ALUSel_out  <= 4'b0;
        MemRW_out   <= 4'b1111;
        WBSel_out   <= 2'b0;
        RegWEn_out  <= 1'b0;
        opcode_out  <= 7'b0;
        BrUn_out    <= 1'b0;
        LUI_out     <= 1'b0;
        DMOn_out    <= 1'b0;
        CSRWEn_out  <= 1'b0;
    end
    else begin
        if(PCstall_axi)begin
            pc_out     <= pc_out      ;
            r1a_out    <= r1a_out     ;
            r2a_out    <= r2a_out     ;            
            rda_out    <= rda_out     ;
            imm_out    <= imm_out     ;
            funct3_out <= funct3_out  ;
            ASel_out   <= ASel_out    ;
            BSel_out   <= BSel_out    ;
            ALUSel_out <= ALUSel_out  ;
            MemRW_out  <= MemRW_out   ;
            WBSel_out  <= WBSel_out   ;
            RegWEn_out <= RegWEn_out  ;
            opcode_out <= opcode_out  ;
            BrUn_out   <= BrUn_out    ;
            LUI_out    <= LUI_out     ;
            DMOn_out   <= DMOn_out    ;
            CSRWEn_out <= CSRWEn_out  ;
        end
        else begin
            if(PCSel_EX == 1'b1 || DH_flush == 1'b1) begin
                pc_out      <= 32'b0;
                r1a_out     <= 5'b0;
                r2a_out     <= 5'b0;            
                rda_out     <= 5'b0;
                imm_out     <= 32'b0;
                funct3_out  <= 3'b0;
                ASel_out    <= 1'b0;
                BSel_out    <= 1'b0;
                ALUSel_out  <= 4'b0;
                MemRW_out   <= 4'b1111;
                WBSel_out   <= 2'b0;
                RegWEn_out  <= 1'b0;
                opcode_out  <= 7'b0;
                BrUn_out    <= 1'b0;
                LUI_out     <= 1'b0;
                DMOn_out    <= 1'b0;
                CSRWEn_out  <= 1'b0;
            end
            // flush when jump happen
            else begin
                pc_out      <= pc_in      ;
                r1a_out     <= r1a_in     ;
                r2a_out     <= r2a_in     ;
                rda_out     <= rda_in     ;
                imm_out     <= imm_in     ;
                funct3_out  <= funct3_in  ;
                ASel_out    <= ASel_in    ;
                BSel_out    <= BSel_in    ;
                ALUSel_out  <= ALUSel_in  ;
                MemRW_out   <= MemRW_in   ;
                WBSel_out   <= WBSel_in   ;
                RegWEn_out  <= RegWEn_in  ;
                opcode_out  <= opcode_in  ;
                BrUn_out    <= BrUn_in    ;
                LUI_out     <= LUI_in     ;
                DMOn_out    <= DMOn_in   ;
                CSRWEn_out  <= CSRWEn_in  ;
            end
        end
    end
end

endmodule
