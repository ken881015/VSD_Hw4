`include "CPU/PC.sv"
`include "CPU/Bar_IFID.sv"
`include "CPU/Decoder.sv"
`include "CPU/RegFile.sv"
`include "CPU/ImmGen.sv"
`include "CPU/Controller.sv"
`include "CPU/BranchComp.sv"
`include "CPU/Bar_IDEX.sv"
`include "CPU/ALU.sv"
`include "CPU/CSRLU.sv"
`include "CPU/Bar_EXME.sv"
`include "CPU/Bar_MEWB.sv"
`include "CPU/Forward.sv"
`include "CPU/Hazard.sv"
`include "CPU/PCSel.sv"
`include "CPU/CSReg.sv"
// `include "../include/Config.svh" 



module CPU(
    input clk,
    input rst,

    // Interface for InstMem and DataMem
    output [31:0] face_pc,
    input  [31:0] face_inst,

    output [31:0] face_ALUOut,
    output [31:0] face_Wdata,
    output [3:0]  face_MemRW,
    output        face_DMOn,
    input  [31:0] face_Rdata,
    
    input PCstall_axi,
    input DMstall_axi
);

logic [31:0] ALUOut;
logic [31:0] pc;
logic [31:0] pc_ifid_out;
logic [31:0] inst_ifid_out;
logic[31:0] imm;
logic[31:0] r1d;
logic[31:0] r2d;
logic[31:0] fwd1;
logic[31:0] fwd2;
logic [6:0] funct7;
logic [4:0] r2a;
logic [4:0] r1a;
logic [2:0] funct3;
logic [4:0] rda;
logic [6:0] opcode;
logic [24:0] imm_material;
logic BrEq;
logic BrLT;
logic PCSel;
logic [2:0] ImmSel;
logic RegWEn;
logic BrUn;
logic ASel;
logic BSel;
logic [3:0] ALUSel;
logic [3:0] MemRW;
logic [1:0] WBSel;
logic LUI;
logic DMOn;
logic CSRWEn;
logic retire;
logic [31:0] CSR_rdata;
logic [31:0] pc_idex_out;
logic [4:0] r1a_idex_out;
logic [4:0] r2a_idex_out;
logic [31:0] r1d_idex_out;
logic [31:0] r2d_idex_out;
logic [4:0]  rda_idex_out;
logic [31:0] imm_idex_out;
logic [2:0] funct3_idex_out;
logic ASel_idex_out;
logic BSel_idex_out;
logic [3:0] ALUSel_idex_out;
logic [3:0] MemRW_idex_out;
logic [1:0] WBSel_idex_out;
logic RegWEn_idex_out;
logic [6:0] opcode_idex_out;
logic BrUn_idex_out;
logic LUI_idex_out;
logic DMOn_idex_out;
logic CSRWEn_idex_out;
logic[31:0] lui_out;
logic[31:0] a_out;
logic[31:0] b_out;
logic[31:0] CSR_rs1;
logic[31:0] CSRLUOut;
logic[31:0] pc_exme_out;
logic[4:0] rda_exme_out;
logic[2:0] funct3_exme_out;
logic[31:0] ALUOut_exme_out;
logic[31:0] fwd2_exme_out;
logic[3:0] MemRW_exme_out;
logic DMOn_exme_out;
logic[1:0] WBSel_exme_out;
logic RegWEn_exme_out;
logic[31:0] CSR_rdata_exme_out;
logic[31:0] pc_mewb_out;
logic [4:0] rda_mewb_out;
logic [31:0] ALUOut_mewb_out;
logic [31:0] DMRdata_mewb_out;
logic [2:0] funct3_mewb_out;
logic [1:0] WBSel_mewb_out;
logic RegWEn_mewb_out;
logic [31:0] CSR_rdata_mewb_out;
logic [31:0] WBdata;
logic [31:0] pc_added;
logic DH_flush;

// added for Inst SRAM inst signal stablelization
logic init;
always_ff @(posedge rst or posedge clk) begin
    init <= (rst)? 1'b1 : 1'b0;
end

/* Stage 1 */

// Output PC for Instruction Memory and wait for Instruction back.
assign face_pc = pc;

PC m_pc(
    .clk(clk),
    .rst(rst),
    .PCSel_EX(PCSel),
    .DH_flush(DH_flush),
    .ALUOut(ALUOut),
    .pc_out(pc),

    // modification due to axi
    .PCstall_axi(PCstall_axi),
    .DMstall_axi(DMstall_axi)
);

Bar_IFID m_bar_ifid(
    .clk(clk),
    .rst(rst),
    .init(init),
    .DH_flush(DH_flush),
    .inst_in(face_inst),
    .inst_out(inst_ifid_out),
    .pc_in(pc),
    .pc_out(pc_ifid_out),
    .PCSel_EX(PCSel),
    .DMstall_axi(DMstall_axi),
    .PCstall_axi(PCstall_axi)
);

/** Stage 2 **/

Decoder m_decoder(
    .inst(inst_ifid_out),
    .funct7(funct7),
    .r2a(r2a),
    .r1a(r1a),
    .funct3(funct3),
    .rda(rda),
    .opcode(opcode),
    .imm_material(imm_material)
);

Controller m_controller(
    .funct7(funct7),
    .funct3(funct3),
    .opcode(opcode),
    .ImmSel(ImmSel),
    .RegWEn(RegWEn),
    .BrUn(BrUn),
    .ASel(ASel),
    .BSel(BSel),
    .ALUSel(ALUSel),
    .MemRW(MemRW),
    .WBSel(WBSel),
    .LUI(LUI),
    .DMOn(DMOn),
    .CSRWEn(CSRWEn)
);

ImmGen m_immgen(
    .ImmSel(ImmSel),
    .imm_material(imm_material),
    .imm(imm)
);

Bar_IDEX m_bar_idex(
    .clk(clk), 
    .rst(rst),
    .DH_flush(DH_flush),
    .PCSel_EX(PCSel),
    .pc_in(pc_ifid_out), .pc_out(pc_idex_out),
    .r1a_in(r1a),        .r1a_out(r1a_idex_out),    
    .r2a_in(r2a),        .r2a_out(r2a_idex_out),
    .rda_in(rda),        .rda_out(rda_idex_out),
    .imm_in(imm),        .imm_out(imm_idex_out),
    .funct3_in(funct3), .funct3_out(funct3_idex_out),
    .ASel_in(ASel),   .ASel_out(ASel_idex_out),
    .BSel_in(BSel),   .BSel_out(BSel_idex_out),
    .ALUSel_in(ALUSel), .ALUSel_out(ALUSel_idex_out),
    .MemRW_in(MemRW),  .MemRW_out(MemRW_idex_out),
    .WBSel_in(WBSel),  .WBSel_out(WBSel_idex_out),
    .RegWEn_in(RegWEn), .RegWEn_out(RegWEn_idex_out),
    .opcode_in(opcode),.opcode_out(opcode_idex_out),
    .BrUn_in(BrUn),.BrUn_out(BrUn_idex_out),
    .LUI_in(LUI),    .LUI_out(LUI_idex_out),
    .DMOn_in(DMOn), .DMOn_out(DMOn_idex_out),
    .CSRWEn_in(CSRWEn), .CSRWEn_out(CSRWEn_idex_out),
    .DMstall_axi(DMstall_axi),
    .PCstall_axi(PCstall_axi)
);

/* stage 3 */
BranchComp m_branchcomp(
    .BrUn(BrUn_idex_out),
    .src1(fwd1),
    .src2(fwd2),
    .BrEq(BrEq),
    .BrLT(BrLT)
);

PCSel m_pcsel(
    .opcode(opcode_idex_out),
    .funct3(funct3_idex_out),
    .BrEq(BrEq),
    .BrLT(BrLT),
    .PCSel(PCSel)
);

assign lui_out = (LUI_idex_out == 1'b0) ? pc_idex_out : 32'b0;
assign a_out = (ASel_idex_out == 1'b0) ? fwd1 : lui_out;
assign b_out = (BSel_idex_out == 1'b0) ? fwd2 : imm_idex_out;

ALU m_alu(
    .src1(a_out),
    .src2(b_out),
    .ALUSel(ALUSel_idex_out),
    .ALUOut(ALUOut)
);

RegFile m_regfile(
    .clk(clk),
    .rst(rst),

    //todo : put the signal 
    .wen(RegWEn_mewb_out),
    .wa(rda_mewb_out), 
    .wd(WBdata),

    .r1a(r1a_idex_out), .r1d(r1d),
    .r2a(r2a_idex_out), .r2d(r2d),

    .PCstall_axi(PCstall_axi)
);

assign retire = (opcode_idex_out == 7'b0) ? 1'b0 : 1'b1;

CSReg m_csr(
    .clk(clk),
    .rst(rst),
    
    .raddr(imm_idex_out[11:0]),
    .rdata(CSR_rdata),

    .waddr(imm_idex_out[11:0]),
    .wdata(CSRLUOut),
    .wen(CSRWEn_idex_out),

    .retire(retire),
    .PCstall_axi(PCstall_axi)
);

// chose uimm or register value by left bit of funct3
assign CSR_rs1 = (funct3_idex_out[2])? {27'b0,r1a_idex_out} : fwd1;

CSRLU m_csrlu(
    .csr(CSR_rdata),
    .rs1(CSR_rs1),
    .funct3(funct3_idex_out),

    .CSRLUOut(CSRLUOut)
);

Bar_EXME m_bar_exme(
    .clk(clk),
    .rst(rst),
    .pc_in(pc_idex_out),.pc_out(pc_exme_out),
    .rda_in(rda_idex_out),.rda_out(rda_exme_out),
    .funct3_in(funct3_idex_out),.funct3_out(funct3_exme_out),
    .DMWdata_in(fwd2),.DMWdata_out(fwd2_exme_out), 
    .ALUOut_in(ALUOut),.ALUOut_out(ALUOut_exme_out),
    .MemRW_in(MemRW_idex_out),.MemRW_out(MemRW_exme_out),
    .DMOn_in(DMOn_idex_out), .DMOn_out(DMOn_exme_out),
    .WBSel_in(WBSel_idex_out),.WBSel_out(WBSel_exme_out),
    .RegWEn_in(RegWEn_idex_out),.RegWEn_out(RegWEn_exme_out),
    .CSR_rdata_in(CSR_rdata), .CSR_rdata_out(CSR_rdata_exme_out),

    .DMstall_axi(DMstall_axi),
    .PCstall_axi(PCstall_axi)
);

/* stage 4 */

// Output Address calculated by ALU for Data Memory with some control signals,
// 
assign face_ALUOut = ALUOut_exme_out;
assign face_Wdata = fwd2_exme_out;
assign face_MemRW = MemRW_exme_out;
assign face_DMOn = DMOn_exme_out;

Bar_MEWB m_bar_mewb(
    .clk(clk),
    .rst(rst),
    .pc_in(pc_exme_out),.pc_out(pc_mewb_out),
    .rda_in(rda_exme_out),.rda_out(rda_mewb_out),
    .ALUOut_in(ALUOut_exme_out),.ALUOut_out(ALUOut_mewb_out),
    .DMRdata_in(face_Rdata),.DMRdata_out(DMRdata_mewb_out),
    .funct3_in(funct3_exme_out),.funct3_out(funct3_mewb_out),
    .WBSel_in(WBSel_exme_out),.WBSel_out(WBSel_mewb_out),
    .RegWEn_in(RegWEn_exme_out),.RegWEn_out(RegWEn_mewb_out),
    .CSR_rdata_in(CSR_rdata_exme_out), .CSR_rdata_out(CSR_rdata_mewb_out),
    .PCstall_axi(PCstall_axi)
);



/* Stage 5 */
// Most of signals are connected back to Regfile...

assign pc_added = pc_mewb_out + 32'd4;

logic[31:0] DMRdata_masked;

logic [1:0] DMRdata_sel;
assign DMRdata_sel = ALUOut_mewb_out[1:0];

logic[15:0] DMRdata_hword;
assign DMRdata_hword = (DMRdata_sel == 2'd2)? DMRdata_mewb_out[31:16] : DMRdata_mewb_out[15:0];

logic[7:0] DMRdata_byte;
assign DMRdata_byte = (DMRdata_sel == 2'd3)? DMRdata_mewb_out[31:24] :
                      (DMRdata_sel == 2'd2)? DMRdata_mewb_out[23:16] :
                      (DMRdata_sel == 2'd1)? DMRdata_mewb_out[15:8]  :
                                             DMRdata_mewb_out[7:0]   ;

always_comb begin
    unique case(funct3_mewb_out)
        `P_WORD: DMRdata_masked = DMRdata_mewb_out;

        `P_HALF: DMRdata_masked = {{16{DMRdata_hword[15]}},DMRdata_hword};
        `P_UHALF: DMRdata_masked = {16'b0,DMRdata_hword};

        `P_UBYTE: DMRdata_masked = {24'b0,DMRdata_byte};
        `P_BYTE: DMRdata_masked = {{24{DMRdata_byte[7]}},DMRdata_byte};
        default:DMRdata_masked = 32'b0;
    endcase
end

// WBdata Configration
// 0 : from Data Mem
// 1 : from ALU
// 2 : from PC+4
// 3 : from CSR
assign WBdata = (WBSel_mewb_out == 2'd0) ? DMRdata_masked :
                (WBSel_mewb_out == 2'd1) ? ALUOut_mewb_out :
                (WBSel_mewb_out == 2'd2) ? pc_added :
                (WBSel_mewb_out == 2'd3) ? CSR_rdata_mewb_out :
                32'b0 ;

logic [31:0] Data_ME;
assign Data_ME = (WBSel_exme_out == 2'd3)? CSR_rdata_exme_out : ALUOut_exme_out;

/* Fowarding */
Forward m_forward(
    .RegWEn_WB(RegWEn_mewb_out),
    .RegWEn_ME(RegWEn_exme_out),

    // Address from EX, ME, WB
    .Addr_WB(rda_mewb_out),
    .Addr_ME(rda_exme_out),
    .Addr1_EX(r1a_idex_out),
    .Addr2_EX(r2a_idex_out),

    // Data from EX, ME, WB
    .Data_WB(WBdata),
    .Data_ME(Data_ME),
    .Data1_EX(r1d),    
    .Data2_EX(r2d),

    .Data_fwd1(fwd1),
    .Data_fwd2(fwd2)
);

Hazard m_hazard(
    // for Detacting Load instruction
    .RegWEn_EX(RegWEn_idex_out),
    .WBSel_EX(WBSel_idex_out),
    .rda_EX(rda_idex_out),

    // input 
    .r1a_ID(r1a),
    .r2a_ID(r2a),
    .opcode_ID(opcode),

    .DH_flush(DH_flush)
);


endmodule
