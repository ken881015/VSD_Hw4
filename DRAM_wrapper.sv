`include "../sim/DRAM/DRAM.sv"

module DRAM_wrapper(
    input ACLK,
    input ARESETn,

    input [`AXI_IDS_BITS-1:0] 	AWID_S,
    input [`AXI_ADDR_BITS-1:0]  AWADDR_S,
    input [`AXI_LEN_BITS-1:0]   AWLEN_S,
    input [`AXI_SIZE_BITS-1:0]  AWSIZE_S,
    input [1:0]                 AWBURST_S,
    input                       AWVALID_S,
    output logic                AWREADY_S,
    
    input [`AXI_DATA_BITS-1:0] WDATA_S,
    input [`AXI_STRB_BITS-1:0] WSTRB_S,
    input                      WLAST_S,
    input                      WVALID_S,
    output logic               WREADY_S,
    
    output logic [`AXI_IDS_BITS-1:0] BID_S,
    output logic [1:0]               BRESP_S,
    output logic                     BVALID_S,
    input                      		   BREADY_S,

    // READ
    input [`AXI_IDS_BITS-1:0]  		ARID_S,
    input [`AXI_ADDR_BITS-1:0]    ARADDR_S,
    input [`AXI_LEN_BITS-1:0]     ARLEN_S,
    input [`AXI_SIZE_BITS-1:0]    ARSIZE_S,
    input [1:0]                   ARBURST_S,
    input                      		ARVALID_S,
    output logic                  ARREADY_S,

    output logic [`AXI_IDS_BITS-1:0]  RID_S,
    output logic [`AXI_DATA_BITS-1:0] RDATA_S,
    output logic [1:0]                RRESP_S,
    output logic                      RLAST_S,
    output logic                      RVALID_S,
    input                     		    RREADY_S,

    input [31:0] DRAM_Q,
    input DRAM_valid,
    output logic DRAM_CSn,
    output logic [3:0] DRAM_WEn,
    output logic DRAM_RASn,
    output logic DRAM_CASn,
    output logic [10:0] DRAM_A,
    output logic [31:0] DRAM_D
);

    // inverse reset signal for active high design habit.
    logic ARESET;
    logic [2:0] DelayCnt;
    logic [3:0] BurstCnt;
    logic[31:0] DRAM_A_reg;
    logic[3:0] ARLEN_S_reg;
    logic[31:0] DRAM_D_reg;
    logic[3:0] DRAM_WEn_reg;
    logic[7:0] BID_S_reg;
    logic[7:0] RID_S_reg;
    logic[10:0] last_row_reg;
    logic[1:0] offset_reg;

    logic[31:0] WDATA_S_msk;

    assign ARESET = ~ARESETn;

    enum logic [2:0] {
        IDLE,   
        ADDR_HS,
        DATA_HS,  
        ACT_ROW, // Active ROW
        ACT_COL, // Active COL
        PRECHARGE
    } state, nxt_state;

    always_ff @( posedge ACLK or posedge ARESET) begin
        if(ARESET)state <= IDLE;
        else state <= nxt_state;
    end

    always_comb begin
        case(state)
            IDLE:begin
                nxt_state = ADDR_HS;
            end
            ADDR_HS:begin
                if(ARREADY_S && ARVALID_S) begin
                    if(last_row_reg == ARADDR_S[22:12])begin
                        nxt_state = ACT_ROW;
                    end
                    else begin
                        nxt_state = PRECHARGE;
                    end
                end
                else if (AWREADY_S && AWVALID_S) nxt_state = DATA_HS;
                else nxt_state = ADDR_HS;
            end
            DATA_HS:begin
                if(WREADY_S && WVALID_S)begin
                    if(last_row_reg == AWADDR_S[22:12])begin
                        nxt_state = ACT_ROW;
                    end
                    else begin
                        nxt_state = PRECHARGE;
                    end
                end
                else nxt_state = DATA_HS;
            end
            PRECHARGE:begin
                nxt_state = (DelayCnt == 3'd4)? ACT_ROW : PRECHARGE;
            end 
            ACT_ROW:begin
                nxt_state = (DelayCnt == 3'd4)? ACT_COL : ACT_ROW;
            end    
            ACT_COL:begin
                nxt_state = (DelayCnt == 3'd4)? IDLE : ACT_COL;
                // Read 
                if(&DRAM_WEn_reg) begin
                    nxt_state = (BurstCnt == ARLEN_S_reg && DelayCnt == 3'd5)? IDLE : ACT_COL;
                end
                // Write
                else begin
                    nxt_state = (DelayCnt == 3'd4)? IDLE : ACT_COL;
                end
            end    
            default:begin
                nxt_state = IDLE;
            end    
        endcase
    end

    // counter for DRAM delay 
    always_ff  @( posedge ACLK or posedge ARESET) begin
        if(ARESET)begin 
            DelayCnt <= 3'd0;
        end
        else begin
            if(state == PRECHARGE || state == ACT_ROW)begin
                DelayCnt <= (DelayCnt == 3'd4)? 3'd0 : DelayCnt + 3'd1 ;
            end
            // additional one cycle for waiting DRAM Rdata valid...
            else if (state == ACT_COL) begin
                // Read...
                if(&DRAM_WEn_reg)begin
                    DelayCnt <= (DelayCnt == 3'd5)? 3'd0 : DelayCnt + 3'd1 ;
                end
                // Write...
                else begin
                    DelayCnt <= (DelayCnt == 3'd4)? 3'd0 : DelayCnt + 3'd1 ;
                end
            end
            else begin
                DelayCnt <= 3'd0;
            end
        end
    end

    // counter for AXI Burst
    always_ff  @( posedge ACLK or posedge ARESET) begin
        if(ARESET)begin 
            BurstCnt <= 4'd0;
        end
        else begin
            if(DRAM_valid)begin
                BurstCnt <= (BurstCnt == ARLEN_S_reg)? 4'd0 : BurstCnt + 4'd1 ;
            end
        end
    end
    
    assign WDATA_S_msk = WDATA_S & {{8{WSTRB_S[3]}},
                                    {8{WSTRB_S[2]}},
                                    {8{WSTRB_S[1]}},
                                    {8{WSTRB_S[0]}}};

    always_ff @(posedge ARESET or posedge ACLK ) begin
        if(ARESET)begin
            DRAM_A_reg <= 32'b0;
            offset_reg <= 2'b0;

            DRAM_D_reg <= 32'b0;
            DRAM_WEn_reg <= 4'hF;

            ARLEN_S_reg <= 4'b0;

            RID_S_reg <= 8'b0;
            BID_S_reg <= 8'b0;

            last_row_reg <= 11'b0;
        end
        else begin
            if(ARREADY_S && ARVALID_S) begin
                DRAM_A_reg <= ARADDR_S;
                RID_S_reg <= ARID_S;
                DRAM_WEn_reg <= 4'hF;
                ARLEN_S_reg <= ARLEN_S;
            end

            if(AWREADY_S && AWVALID_S) begin
                DRAM_A_reg <= AWADDR_S;
                offset_reg <= AWADDR_S[1:0];
                BID_S_reg <= AWID_S;
                DRAM_WEn_reg <= ~WSTRB_S;
            end
            else if(WREADY_S && WVALID_S) begin
                case(offset_reg)
                2'd0: begin
                    DRAM_D_reg <= WDATA_S_msk;
                    DRAM_WEn_reg <= DRAM_WEn_reg;
                end
                2'd1: begin
                    DRAM_D_reg <= {WDATA_S_msk[23:0],WDATA_S_msk[31:24]};
                    DRAM_WEn_reg <= {DRAM_WEn_reg[2:0],DRAM_WEn_reg[3]};
                end
                2'd2: begin
                    DRAM_D_reg <= {WDATA_S_msk[15:0],WDATA_S_msk[31:16]};
                    DRAM_WEn_reg <= {DRAM_WEn_reg[1:0],DRAM_WEn_reg[3:2]};
                end
                2'd3: begin
                    DRAM_D_reg <= {WDATA_S_msk[7:0],WDATA_S_msk[31:8]};
                    DRAM_WEn_reg <= {DRAM_WEn_reg[0],DRAM_WEn_reg[3:1]};
                end
            endcase
            end

            if(!DRAM_CASn)begin
                last_row_reg <= DRAM_A_reg[22:12];
            end
        end
    end

    // Output port toward AXI
    assign AWREADY_S = (state == ADDR_HS)? 1'b1 : 1'b0;
    assign WREADY_S = (state == DATA_HS)? 1'b1 : 1'b0;
    assign BID_S = BID_S_reg;
    assign BRESP_S = `AXI_RESP_OKAY;
    assign BVALID_S = (!(&DRAM_WEn_reg) && state == ACT_COL && DelayCnt == 3'd4)? 1'b1 : 1'b0;

    assign ARREADY_S = (state == ADDR_HS)? 1'b1 : 1'b0;
    assign RID_S = RID_S_reg;
    assign RDATA_S = (DRAM_valid)? DRAM_Q : 32'b0;
    assign RRESP_S = `AXI_RESP_OKAY;
    assign RLAST_S =  (BurstCnt == ARLEN_S_reg) && DRAM_valid;
    assign RVALID_S = DRAM_valid;

    // Outport toward DRAM
    assign DRAM_CSn = 1'b0;

    always_comb begin
        if(state == PRECHARGE)begin
            DRAM_WEn = (DelayCnt == 3'd0)? 4'h0 : 4'hf;
        end
        else if (state == ACT_COL) begin
            DRAM_WEn = (DelayCnt == 3'd0)? DRAM_WEn_reg : 4'hf;
        end
        else DRAM_WEn = 4'hf;
    end
    
    assign DRAM_RASn = ((state == PRECHARGE || state == ACT_ROW) && DelayCnt == 3'd0)? 1'b0 : 1'b1;
    
    assign DRAM_CASn = (state == ACT_COL && DelayCnt == 3'd0)? 1'b0 : 1'b1;

    
    always_comb begin
        if(state == PRECHARGE) begin
            DRAM_A = last_row_reg;
        end
        else if(state == ACT_ROW) begin
            DRAM_A = DRAM_A_reg[22:12];
        end
        else if(state == ACT_COL) begin
            // Read...
            if(&DRAM_WEn_reg)begin
                DRAM_A = {1'b0, DRAM_A_reg[11:4], BurstCnt[1:0]};
            end
            // Write...
            else begin
                DRAM_A = {1'b0, DRAM_A_reg[11:2]} + {7'b0, BurstCnt};
            end
        end
        else begin
            DRAM_A = 11'b0;
        end
    end

    assign DRAM_D = DRAM_D_reg;

endmodule
