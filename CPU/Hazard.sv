`include "../include/Config.svh" 

module Hazard(
    // for Detacting Load instruction
    input RegWEn_EX,
    input[1:0] WBSel_EX,
    input [4:0] rda_EX,

    // input 
    input [4:0] r1a_ID,
    input [4:0] r2a_ID,
    input [6:0] opcode_ID,

    output DH_flush
);

logic Hzd_1;
logic Hzd_2;

assign DH_flush = Hzd_1 || Hzd_2;

always_comb begin
    //Default case
    Hzd_1 = 1'b0;
    Hzd_2 = 1'b0;

    // load instruction
    if(WBSel_EX == 2'd0 && RegWEn_EX == 1'b1) begin
        
        // for the instruction that needs rs1
        if(opcode_ID == `OP     || opcode_ID == `OP_IMM ||
           opcode_ID == `LOAD   || opcode_ID == `STORE  ||
           opcode_ID == `BRANCH || opcode_ID == `JALR ) 
        begin
            // Load-Use Hazard
            if(r1a_ID == rda_EX) begin
                Hzd_1 = 1'b1;
            end
        end

        // for the instruction that needs rs2
        if(opcode_ID == `OP|| opcode_ID == `STORE|| opcode_ID == `BRANCH ) 
        begin
            // Load-Use Hazard
            if(r2a_ID == rda_EX) begin
                Hzd_2 = 1'b1;
            end
        end
    end
end


    
endmodule
