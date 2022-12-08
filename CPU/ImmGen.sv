`include "../include/Config.svh" 

module ImmGen(
    input[2:0] ImmSel,
    input[24:0] imm_material,
    
    output logic[31:0] imm
);

logic [31:0] imm_shf;
assign imm_shf = {imm_material,7'b0};

// if - else
always_comb begin
    unique if (ImmSel == `Itype) imm = {{20{imm_shf[31]}},imm_shf[31:20]};
    else   if (ImmSel == `Stype) imm = {{20{imm_shf[31]}},imm_shf[31:25],imm_shf[11:7]};
    else   if (ImmSel == `Btype) imm = {{20{imm_shf[31]}},imm_shf[7],imm_shf[30:25],imm_shf[11:8],1'b0};
    else   if (ImmSel == `Utype) imm = {imm_shf[31:12],12'b0};
    else   if (ImmSel == `Jtype) imm = {{12{imm_shf[31]}},imm_shf[19:12],imm_shf[20],imm_shf[30:21],1'b0};
    else imm = 32'b0; 
end

endmodule
