`include "../include/AXI_define.svh"
`include "../include/Config.svh"

module SRAM_wrapper (
  input ACLK,
  input ARESET,

    //WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0]  AWID_S,
	input [`AXI_ADDR_BITS-1:0] AWADDR_S,
	input [`AXI_LEN_BITS-1:0]  AWLEN_S,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_S,
	input [1:0]                AWBURST_S,
	input                      AWVALID_S,
	output logic               AWREADY_S,
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_S,
	input [`AXI_STRB_BITS-1:0] WSTRB_S,
	input                      WLAST_S,
	input                      WVALID_S,
	output logic               WREADY_S,
	//WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID_S,
	output logic [1:0]               BRESP_S,
	output logic                     BVALID_S,
	input                            BREADY_S,

    //READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID_S,
	input [`AXI_ADDR_BITS-1:0] ARADDR_S,
	input [`AXI_LEN_BITS-1:0] ARLEN_S,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
	input [1:0] ARBURST_S,
	input ARVALID_S,
	output logic ARREADY_S,
	
    //READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID_S,
	output logic [`AXI_DATA_BITS-1:0] RDATA_S,
	output logic [1:0] RRESP_S,
	output logic RLAST_S,
	output logic RVALID_S,
	input RREADY_S
);

// FSM parameters for 3 types (IM read, DM read, DM write)
logic [2:0] state_R_S, nxt_state_R_S;
logic [2:0] state_W_S, nxt_state_W_S;

// define state name by using macro
localparam IDLE       = 3'b000;

localparam Set_HS1    = 3'b001; // set one of signal (ready or valid) that can self control to high
localparam HS1        = 3'b010;

// M means middle, it is added because Write behavior needs 3 times HS.
localparam Set_HSM    = 3'b011; // set one of signal (ready or valid) that can self control to high
localparam HSM        = 3'b100; 

localparam Store_Data = 3'b101;
localparam Set_HS2    = 3'b110; // set one of signal (ready or valid) that can self control to high

// Burst Counter
logic [3:0] BurstCnt;

// wire for SRAM input and output port
logic CS;
assign CS = 1'b1;

logic OE;
assign OE = 1'b1;

logic [13:0] A, A_reg; // A_reg, but i_sram needs it to be named "A"
logic [1:0] offset_reg;
logic [31:0] DI, DI_reg;
logic [31:0] DO;
logic [3:0] WEB;

always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        A_reg <= 14'b0;
        DI_reg <= 32'b0;
        offset_reg <= 2'b0;
    end
    else begin
        if(ARREADY_S && ARVALID_S) begin
            A_reg <= ARADDR_S[15:2];
        end
        else if(AWREADY_S && AWVALID_S) begin
            {A_reg, offset_reg} <= AWADDR_S[15:0];
        end

        if(WREADY_S && WVALID_S) begin
            case(offset_reg)
                2'd0: begin
                    DI_reg <= WDATA_S;
                end
                2'd1: begin
                    DI_reg <= {WDATA_S[23:0],WDATA_S[31:24]};
                end
                2'd2: begin
                    DI_reg <= {WDATA_S[15:0],WDATA_S[31:16]};
                end
                2'd3: begin
                    DI_reg <= {WDATA_S[7:0],WDATA_S[31:8]};
                end
            endcase
        end
    end
end

// assign A = (state_W_S > Set_HS1)? A_reg : {A_reg[13:2], BurstCnt[1:0]};
// assign A = {A_reg[13:2], BurstCnt[1:0]};
// assign A = A_reg + BurstCnt;

assign DI = DI_reg;

always_comb begin
    if(state_W_S == HSM) begin
        case(offset_reg)
            2'd0: begin
                WEB = ~WSTRB_S;
            end
            2'd1: begin
                WEB = ~{WSTRB_S[2:0],WSTRB_S[3]};
            end
            2'd2: begin
                WEB = ~{WSTRB_S[1:0],WSTRB_S[3:2]};
            end
            2'd3: begin
                WEB = ~{WSTRB_S[0],WSTRB_S[3:1]};
            end
        endcase
    end
    else begin
        WEB = 4'b1111;
    end
end

// Read Behavior of Slave ================================

// stage register description
always_ff @(posedge ACLK ) begin
    if(ARESET) state_R_S <= 3'b0;
    else state_R_S <= nxt_state_R_S;
end

// next state circuit description
always_comb begin
    case(state_R_S)
        IDLE       :  nxt_state_R_S = Set_HS1; 

        Set_HS1    :  nxt_state_R_S = (ARVALID_S)? HS1 : Set_HS1; // Set ARREADY_S to high

        HS1        :  nxt_state_R_S = Store_Data; 

        Store_Data :  nxt_state_R_S = Set_HS2;

        Set_HS2    :  nxt_state_R_S =(RREADY_S)? ((RLAST_S)? IDLE: HS1) : Set_HS2;

        default    :  nxt_state_R_S = IDLE;

    endcase
end 

logic [3:0] ARLEN_S_reg;
logic [7:0] RID_S_reg;
logic[31:0] RDATA_S_reg;
logic RVALID_S_reg;

assign ARREADY_S = (state_R_S == Set_HS1);
assign RVALID_S = RVALID_S_reg;
assign RID_S = RID_S_reg;
assign RRESP_S = `AXI_RESP_OKAY;
assign RDATA_S = RDATA_S_reg;

always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        ARLEN_S_reg <= 4'b0;
        RID_S_reg <= 8'b0;
        RDATA_S_reg <= 32'b0;
        RVALID_S_reg <= 1'b0;
    end
    else begin
        if(ARVALID_S && ARREADY_S) begin
            ARLEN_S_reg <= ARLEN_S;
            RID_S_reg <= ARID_S;
        end

        if(state_R_S  == Store_Data) begin
            RDATA_S_reg <= DO;
        end
        else if(state_R_S == IDLE) begin
            RDATA_S_reg <= 32'b0;
        end

        if(state_R_S == Store_Data || state_R_S == Set_HS2) begin
            RVALID_S_reg <= (RREADY_S)? 1'b0: 1'b1;
        end
        else begin
            RVALID_S_reg <= 1'b0;
        end 
    end
end

always_comb begin
    if(state_W_S > Set_HS1) begin
        A = A_reg;
    end
    else begin
        A = (ARLEN_S_reg == 4'b0011)? {A_reg[13:2], BurstCnt[1:0]} : A_reg;
    end
end

assign RLAST_S = (RVALID_S) && (BurstCnt == ARLEN_S_reg);
always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        BurstCnt <= 4'b0;
    end
    else begin
        if(state_R_S == Set_HS2) begin
            if(RREADY_S && RVALID_S)begin
                BurstCnt <= (BurstCnt == ARLEN_S_reg)? 4'b0 : BurstCnt + 4'b1;
            end
        end
        else if(state_R_S == IDLE) begin
            BurstCnt <= 4'b0;
        end
    end
end

// Write Behavior of Slave ===============================

// stage register description
always_ff @(posedge ACLK ) begin
    if(ARESET) state_W_S <= 3'b0;
    else state_W_S <= nxt_state_W_S;
end

// next state circuit description
always_comb begin
    case(state_W_S)
        IDLE      : nxt_state_W_S = Set_HS1; 

        Set_HS1   : nxt_state_W_S = (AWVALID_S)? HS1 : Set_HS1; // Set AWREADY_S, WREADY_S to high

        HS1       : nxt_state_W_S = Set_HSM; 

        Set_HSM   : nxt_state_W_S =  (WVALID_S && WLAST_S)? HSM : Set_HSM;

        HSM       : nxt_state_W_S = Set_HS2; 

        Set_HS2   : nxt_state_W_S = (BREADY_S)? IDLE : Set_HS2; // Set BVALID_S to high

        default   : nxt_state_W_S = IDLE;
    endcase
end

assign AWREADY_S = (state_W_S == Set_HS1);
assign WREADY_S  = (state_W_S == Set_HSM);
assign BVALID_S  = (state_W_S == Set_HS2);

logic[7:0] BID_S_reg;
always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        BID_S_reg <= 8'b0;
    end
    else begin
        if(AWVALID_S && AWREADY_S) begin
            BID_S_reg <= AWID_S;
        end
    end
end

assign BID_S = BID_S_reg;
assign BRESP_S = `AXI_RESP_OKAY;
  

  SRAM i_SRAM (
    .CK   (ACLK    ),

    .A0   (A[0]  ),.A1   (A[1]  ),.A2   (A[2]  ),.A3   (A[3]  ),.A4   (A[4]  ),.A5   (A[5]  ),.A6   (A[6]  ),
    .A7   (A[7]  ),.A8   (A[8]  ),.A9   (A[9]  ),.A10  (A[10] ),.A11  (A[11] ),.A12  (A[12] ),.A13  (A[13] ),

    // Read Data Out
    .DO0  (DO[0] ),.DO1  (DO[1] ),.DO2  (DO[2] ),.DO3  (DO[3] ),.DO4  (DO[4] ),.DO5  (DO[5] ),.DO6  (DO[6] ),.DO7  (DO[7] ),
    .DO8  (DO[8] ),.DO9  (DO[9] ),.DO10 (DO[10]),.DO11 (DO[11]),.DO12 (DO[12]),.DO13 (DO[13]),.DO14 (DO[14]),.DO15 (DO[15]),
    .DO16 (DO[16]),.DO17 (DO[17]),.DO18 (DO[18]),.DO19 (DO[19]),.DO20 (DO[20]),.DO21 (DO[21]),.DO22 (DO[22]),.DO23 (DO[23]),
    .DO24 (DO[24]),.DO25 (DO[25]),.DO26 (DO[26]),.DO27 (DO[27]),.DO28 (DO[28]),.DO29 (DO[29]),.DO30 (DO[30]),.DO31 (DO[31]),
    
    // Write Data In
    .DI0  (DI[0] ),.DI1  (DI[1] ),.DI2  (DI[2] ),.DI3  (DI[3] ),.DI4  (DI[4] ),.DI5  (DI[5] ),.DI6  (DI[6] ),.DI7  (DI[7] ),
    .DI8  (DI[8] ),.DI9  (DI[9] ),.DI10 (DI[10]),.DI11 (DI[11]),.DI12 (DI[12]),.DI13 (DI[13]),.DI14 (DI[14]),.DI15 (DI[15]),
    .DI16 (DI[16]),.DI17 (DI[17]),.DI18 (DI[18]),.DI19 (DI[19]),.DI20 (DI[20]),.DI21 (DI[21]),.DI22 (DI[22]),.DI23 (DI[23]),
    .DI24 (DI[24]),.DI25 (DI[25]),.DI26 (DI[26]),.DI27 (DI[27]),.DI28 (DI[28]),.DI29 (DI[29]),.DI30 (DI[30]),.DI31 (DI[31]),
    
    .WEB0 (WEB[0]),.WEB1 (WEB[1]),.WEB2 (WEB[2]),.WEB3 (WEB[3]),
    
    .OE   (OE    ), // for read data
    .CS   (CS    )
  );

endmodule
