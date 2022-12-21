`include "../include/Config.svh" 

module CSRLU(
    input [31:0] csr,
    input [31:0] rs1,
    input [2:0] funct3,

    output logic [31:0] CSRLUOut
);

always_comb begin
    case(funct3[1:0])
        `RW  : CSRLUOut = rs1;
        `RS  : CSRLUOut = csr | rs1;
        `RC  : CSRLUOut = csr & (~rs1);
        `RWI : CSRLUOut = rs1;
        `RSI : CSRLUOut = csr | rs1;
        `RCI : CSRLUOut = csr & (~rs1);
        default: CSRLUOut = 32'b0;
    endcase
end

endmodule