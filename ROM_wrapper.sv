
module ROM_wrapper(
  input ACLK,
  input ARESETn,

  //READ ADDRESS
  input [`AXI_IDS_BITS-1:0]  		ARID_S,
  input [`AXI_ADDR_BITS-1:0] 		ARADDR_S,
  input [`AXI_LEN_BITS-1:0]  		ARLEN_S,
  input [`AXI_SIZE_BITS-1:0] 		ARSIZE_S,
  input [1:0]                		ARBURST_S,
  input                      		ARVALID_S,
  output logic                      ARREADY_S,

  //READ DATA
  output logic [`AXI_IDS_BITS-1:0]  RID_S,
  output logic [`AXI_DATA_BITS-1:0] RDATA_S,
  output logic [1:0]                RRESP_S,
  output logic                      RLAST_S,
  output logic                      RVALID_S,
  input                      		RREADY_S,

  // toward ROM
  input [31:0] ROM_out,
  output logic ROM_read,
  output logic ROM_enable,
  output logic [11:0] ROM_address
);

// inverse reset signal for active high design habit.
logic ARESET;
assign ARESET = ~ARESETn;

// wires for ROM input and output port
assign ROM_read = 1'b1;
assign ROM_enable = 1'b1;

// FSM parameters for Read
logic [2:0] state_R_S, nxt_state_R_S;

localparam IDLE       = 3'b000;

localparam Set_HS1    = 3'b001; // set one of signal (ready or valid) that can self control to high
localparam HS1        = 3'b010;

localparam Store_Data = 3'b011;
localparam Set_HS2    = 3'b100; // set one of signal (ready or valid) that can self control to high

// Burst Counter
logic [3:0] BurstCnt;

logic [11:0] ROM_addr_reg; // ROM_addr_reg, but i_sram needs it to be named "A"


always_ff@(posedge ACLK or posedge ARESET) begin
    if(ARESET)begin
        ROM_addr_reg <= 12'b0;
    end
    else begin
        if(ARREADY_S && ARVALID_S) ROM_addr_reg <= ARADDR_S [13:2];
    end
end

always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET) state_R_S <= 3'b0;
    else state_R_S <= nxt_state_R_S;
end

// next state circuit description
always_comb begin
    case(state_R_S)
        IDLE       : nxt_state_R_S = Set_HS1; 
        
        Set_HS1    : nxt_state_R_S = (ARVALID_S)? HS1 : Set_HS1; // Set ARREADY_S to high
        
        HS1        : nxt_state_R_S = Store_Data; 
        
        Store_Data : nxt_state_R_S = Set_HS2;
        
        Set_HS2    : nxt_state_R_S =(RREADY_S)? ((RLAST_S)? IDLE: HS1) : Set_HS2;

        default    : nxt_state_R_S = IDLE;
    endcase
end 

logic [3:0] ARLEN_S_reg;
logic [7:0] RID_S_reg;
logic RVALID_S_reg;
logic[31:0] RDATA_S_reg;

assign ARREADY_S = (state_R_S == Set_HS1);
assign RVALID_S = RVALID_S_reg;
assign RID_S = RID_S_reg;
assign RRESP_S = `AXI_RESP_OKAY;
assign RDATA_S = RDATA_S_reg;

always_ff @(posedge ARESET or posedge ACLK ) begin
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
            RDATA_S_reg <= ROM_out;
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

assign ROM_address = (ARLEN_S_reg == 4'b0011)? {ROM_addr_reg[11:2], BurstCnt[1:0]} : ROM_addr_reg;

assign RLAST_S = (RVALID_S) && (BurstCnt == ARLEN_S_reg);
always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)begin
        BurstCnt <= 4'b0;
    end
    else begin
        if(state_R_S  == Set_HS2) begin
            if(RREADY_S && RVALID_S) begin
                BurstCnt <= (BurstCnt == ARLEN_S_reg)? 4'b0 : BurstCnt + 4'b1;
            end
        end
        else if(state_R_S == IDLE) begin
            BurstCnt <= 4'b0;
        end
    end
end

	
endmodule
