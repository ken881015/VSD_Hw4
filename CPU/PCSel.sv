`include "../include/Config.svh" 

module PCSel(
    input [6:0] opcode,
    input [2:0] funct3,
    input BrEq,
    input BrLT,
    input wfi,
    input mret,
    input ex_interrupt,
    output logic PCSel
);

always_comb begin
    unique if(opcode == `BRANCH) begin
        unique if(funct3==`EQ  && BrEq==1'b1) PCSel = 1'b1;
        else   if(funct3==`NE  && BrEq==1'b0) PCSel = 1'b1;
        else   if(funct3==`LT  && BrLT==1'b1) PCSel = 1'b1;
        else   if(funct3==`GE  && BrLT==1'b0) PCSel = 1'b1;
        else   if(funct3==`LTU && BrLT==1'b1) PCSel = 1'b1;
        else   if(funct3==`GEU && BrLT==1'b0) PCSel = 1'b1;
        else PCSel = 1'b0;
    end
    else if (opcode == `JAL || opcode == `JALR) begin
        PCSel = 1'b1;
    end
    else if (wfi && ex_interrupt) begin
        PCSel = 1'b1;
    end
    else if (mret) begin
        PCSel = 1'b1;
    end
    else begin
        PCSel = 1'b0;
    end
end

endmodule
