`include "../include/AXI_define.svh"
`include "../include/Config.svh"

`include "WDT.sv"

module WDT_wrapper(
  input clk,
  input rst,
  input clk2,
  input rst2,
  
  output WTO,
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
  input                            BREADY_S
);

logic [11:0] A_reg;

//wires for WDT
logic WDEN;
logic WDLIVE;
logic [31:0] WTOCNT;

// FSM parameters 
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

always_ff @(posedge clk) begin
    if(rst)begin
		A_reg <= 12'b0;
		WDEN <= 1'b0;
		WDLIVE <= 1'b0;
		WTOCNT <= 32'b0;
    end
    else begin
        if(AWREADY_S && AWVALID_S) begin
            A_reg <= AWADDR_S[11:0];
        end

        if(WREADY_S && WVALID_S) begin
            if(A_reg == 12'h100) WDEN   <= WDATA_S[0];
            if(A_reg == 12'h200) WDLIVE <= WDATA_S[0];
			if(A_reg == 12'h300) WTOCNT <= WDATA_S;
        end
    end
end

// Write Behavior of Slave ===============================

// stage register description
always_ff @(posedge clk) begin
    if(rst) state_W_S <= 3'b0;
    else state_W_S <= nxt_state_W_S;
end

// next state circuit description
always_comb begin
    case(state_W_S)
        IDLE    : nxt_state_W_S = Set_HS1; 

        Set_HS1 : nxt_state_W_S = (AWVALID_S)? HS1 : Set_HS1; // Set AWREADY_S, WREADY_S to high

        HS1     : nxt_state_W_S = Set_HSM; 

        Set_HSM : nxt_state_W_S =  (WVALID_S && WLAST_S)? HSM : Set_HSM;

        HSM     : nxt_state_W_S = Set_HS2; 

        Set_HS2 : nxt_state_W_S = (BREADY_S)? IDLE : Set_HS2; // Set BVALID_S to high

        default : nxt_state_W_S = IDLE;
    endcase
end

assign AWREADY_S = (state_W_S == Set_HS1);
assign WREADY_S  = (state_W_S == Set_HSM);
assign BVALID_S  = (state_W_S == Set_HS2);

logic[7:0] BID_S_reg;
always_ff @(posedge clk) begin
    if(rst)begin
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

WDT WDT_m(
  .clk(clk),
  .rst(rst),
  .clk2(clk2),
  .rst2(rst2),

  .WDEN(WDEN),
  .WDLIVE(WDLIVE),
  .WTOCNT(WTOCNT),

  .WTO(WTO)

);
endmodule
