module BranchComp(
    input BrUn,
    input [31:0] src1,
    input [31:0] src2,
    
    output logic BrEq,
    output logic BrLT
);

always_comb begin
    // Unsigned Comparation
    if(BrUn) BrLT = (src1 < src2)? 1'b1 : 1'b0;

    // Signed Comparation
    else BrLT = ($signed(src1) < $signed(src2))? 1'b1: 1'b0;
end

assign BrEq = (src1 == src2) ? 1'b1 : 1'b0;

endmodule
