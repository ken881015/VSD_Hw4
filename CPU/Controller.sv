`include "../include/Config.svh" 

module Controller(
    input[6:0] funct7,
    input[2:0] funct3,
    input[6:0] opcode,
    
    output logic[2:0] ImmSel,
    output logic      RegWEn,
    output logic      BrUn,
    output logic      ASel,
    output logic      BSel,
    output logic[3:0] ALUSel,
    output logic[3:0] MemRW,
    output logic[1:0] WBSel,
    output logic      LUI,
    output logic      DMOn,
    output logic      CSRWEn
);

always_comb begin
    unique case (opcode)
        `OP:     ImmSel = `Rtype;
        `OP_IMM: ImmSel = `Itype;
        `LOAD:   ImmSel = `Itype;
        `STORE:  ImmSel = `Stype;
        `BRANCH: ImmSel = `Btype;
        `JAL:    ImmSel = `Jtype;
        `JALR:   ImmSel = `Itype;
        `LUI:    ImmSel = `Utype;
        `AUIPC:  ImmSel = `Utype;
        `SYSTEM: ImmSel = `Itype;
        default: ImmSel =   3'b0;
    endcase
end

assign RegWEn = (opcode == `STORE||opcode == `BRANCH||opcode == `HCF)? 1'b0 : 1'b1;
assign BrUn = funct3[1];
assign ASel = (opcode == `BRANCH || opcode == `JAL || opcode == `AUIPC || opcode == `LUI) ? 1'b1 : 1'b0;
assign BSel = (opcode == `OP) ? 1'b0 : 1'b1;

logic ALUSel_msb;
logic[2:0] ALUSel_lsb;

always_comb begin
    unique if (opcode == `OP) begin
        ALUSel_msb = ({1'b0,funct3} == `ADD ||{1'b0,funct3} == `SRL)? funct7[5] : 1'b0;
    end
    else if (opcode == `OP_IMM)begin
        ALUSel_msb = ({1'b0,funct3} == `SRL)? funct7[5] : 1'b0;
    end
    else begin
        ALUSel_msb = 1'b0;
    end
end

assign ALUSel_lsb = (opcode == `OP || opcode == `OP_IMM)? funct3 : 3'b0;
assign ALUSel = {ALUSel_msb,ALUSel_lsb};

// Remind: Memory write enable is active low
always_comb begin
    if(opcode == `STORE)begin
        case(funct3)
            `P_WORD: MemRW = 4'b0000;
            `P_HALF: MemRW = 4'b1100;
            `P_BYTE: MemRW = 4'b1110;
            default: MemRW = 4'b1111;
        endcase
    end
    else begin
        MemRW = 4'b1111;
    end
end

always_comb begin
    unique if(opcode == `LOAD)                 WBSel = 2'd0; // from Data Memory
    else if(opcode == `JAL || opcode == `JALR) WBSel = 2'd2; // from PC+4
    else if(opcode == `SYSTEM)                 WBSel = 2'd3; // from CSR value
    else                                       WBSel = 2'd1; // from ALU
end

assign LUI = (opcode == `LUI);

assign DMOn = (opcode == `LOAD || opcode == `STORE);

assign CSRWEn = opcode == `SYSTEM;

endmodule
