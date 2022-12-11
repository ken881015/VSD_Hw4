module Decoder (
    input[31:0] inst,

    
    // output logic [6:0] funct7,
    output logic funct7_1bit,
    output logic [4:0] r2a,    
    output logic [4:0] r1a,    
    output logic [2:0] funct3,    
    output logic [4:0] rda,    
    output logic [6:0] opcode,
    output logic [24:0] imm_material,
    output logic [11:0] CSRAddr
);

// assign funct7       = inst[31:25];
assign funct7_1bit  = inst[30];
assign r2a          = inst[24:20];
assign r1a          = inst[19:15];
assign funct3       = inst[14:12];
assign rda          = inst[11:7];
assign opcode       = inst[6:0];
assign imm_material = inst[31:7];
assign CSRAddr      = inst[31:20];
    
endmodule
