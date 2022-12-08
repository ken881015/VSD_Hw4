`include "../include/Config.svh" 

module ALU(
    input [31:0] src1,
    input [31:0] src2,
    input [3:0] ALUSel,

    output logic [31:0] ALUOut
);

always_comb begin
    unique case(ALUSel)
        `ADD  : ALUOut = $signed(src1) + $signed(src2);
        `SLL  : ALUOut = src1 << src2[4:0];
        `SLT  : ALUOut = ($signed(src1) < $signed(src2)) ? 32'b1 : 32'b0;
        `SLTU : ALUOut = (src1 < src2) ? 32'b1 : 32'b0;
        `XOR  : ALUOut = src1^src2;
        `SRL  : ALUOut = src1 >> src2[4:0];
        `OR   : ALUOut = src1 | src2;
        `AND  : ALUOut = src1 & src2;
        `SUB  : ALUOut = src1 - src2;
        `SRA  : ALUOut = $signed(src1) >>> src2[4:0];
        default: ALUOut = 32'b0;
    endcase
end

endmodule
