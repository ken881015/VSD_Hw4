module Forward(
    input RegWEn_WB,
    input RegWEn_ME,

    input [4:0] Addr_WB,
    input [4:0] Addr_ME,
    input [4:0] Addr1_EX,
    input [4:0] Addr2_EX,

    input [31:0] Data_WB,
    input [31:0] Data_ME,
    input [31:0] Data1_EX,    
    input [31:0] Data2_EX,
    output logic [31:0] Data_fwd1,
    output logic [31:0] Data_fwd2
);

// priority ME >  WB
// OPcode should be considered, too. ???


assign Data_fwd1 = (RegWEn_ME == 1'b1 && Addr1_EX == Addr_ME && Addr1_EX != 5'd0)? Data_ME :
                   (RegWEn_WB == 1'b1 && Addr1_EX == Addr_WB && Addr1_EX != 5'd0)? Data_WB :
                   Data1_EX;

assign Data_fwd2 = (RegWEn_ME == 1'b1 && Addr2_EX == Addr_ME && Addr1_EX != 5'd0)? Data_ME :
                   (RegWEn_WB == 1'b1 && Addr2_EX == Addr_WB && Addr1_EX != 5'd0)? Data_WB :
                   Data2_EX;

endmodule
