//================================================
// Auther:      Chang Wan-Yun (Claire)
// Filename:    AXI.sv
// Description: Top module of AXI
// Version:     1.0 
//================================================
`include "AXI_define.svh"

module AXI(

  input ACLK,
  input ARESET,
  //MASTER INTERFACE
  // M0
  // READ
  input [`AXI_ID_BITS-1:0]          ARID_M0,
  input [`AXI_ADDR_BITS-1:0]        ARADDR_M0,
  input [`AXI_LEN_BITS-1:0]         ARLEN_M0,
  input [`AXI_SIZE_BITS-1:0]        ARSIZE_M0,
  input [1:0]                       ARBURST_M0,
  input                             ARVALID_M0,
  output logic                      ARREADY_M0,
  output logic [`AXI_ID_BITS-1:0]   RID_M0,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
  output logic [1:0]                RRESP_M0,
  output logic                      RLAST_M0,
  output logic                      RVALID_M0,
  input                             RREADY_M0,

  // M1
  // WRITE
  input [`AXI_ID_BITS-1:0]          AWID_M1,
  input [`AXI_ADDR_BITS-1:0]        AWADDR_M1,
  input [`AXI_LEN_BITS-1:0]         AWLEN_M1,
  input [`AXI_SIZE_BITS-1:0]        AWSIZE_M1,
  input [1:0]                       AWBURST_M1,
  input                             AWVALID_M1,
  output logic                      AWREADY_M1,
  input [`AXI_DATA_BITS-1:0]        WDATA_M1,
  input [`AXI_STRB_BITS-1:0]        WSTRB_M1,
  input                             WLAST_M1,
  input                             WVALID_M1,
  output logic                      WREADY_M1,
  output logic [`AXI_ID_BITS-1:0]   BID_M1,
  output logic [1:0]                BRESP_M1,
  output logic                      BVALID_M1,
  input                             BREADY_M1,
  // READ
  input [`AXI_ID_BITS-1:0]          ARID_M1,
  input [`AXI_ADDR_BITS-1:0]        ARADDR_M1,
  input [`AXI_LEN_BITS-1:0]         ARLEN_M1,
  input [`AXI_SIZE_BITS-1:0]        ARSIZE_M1,
  input [1:0]                       ARBURST_M1,
  input                             ARVALID_M1,
  output logic                      ARREADY_M1,
  output logic [`AXI_ID_BITS-1:0]   RID_M1,
  output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
  output logic [1:0]                RRESP_M1,
  output logic                      RLAST_M1,
  output logic                      RVALID_M1,
  input                             RREADY_M1,
  
  //SLAVE INTERFACE
  // S0
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S0,
  output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S0,
  output logic [`AXI_LEN_BITS-1:0]        ARLEN_S0,
  output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S0,
  output logic [1:0]                      ARBURST_S0,
  output logic                      ARVALID_S0,
  input                             ARREADY_S0,
  input [`AXI_IDS_BITS-1:0]         RID_S0,
  input [`AXI_DATA_BITS-1:0]        RDATA_S0,
  input [1:0]                       RRESP_S0,
  input                             RLAST_S0,
  input                             RVALID_S0,
  output logic                      RREADY_S0,
  // S1
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S1,
  output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S1,
  output logic [`AXI_LEN_BITS-1:0]        AWLEN_S1,
  output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S1,
  output logic [1:0]                      AWBURST_S1,
  output logic                      AWVALID_S1,
  input                             AWREADY_S1,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
  output logic                      WLAST_S1,
  output logic                      WVALID_S1,
  input                             WREADY_S1,
  input [`AXI_IDS_BITS-1:0]         BID_S1,
  input [1:0]                       BRESP_S1,
  input                             BVALID_S1,
  output logic                      BREADY_S1,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S1,
  output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S1,
  output logic [`AXI_LEN_BITS-1:0]        ARLEN_S1,
  output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S1,
  output logic [1:0]                      ARBURST_S1,
  output logic                      ARVALID_S1,
  input                             ARREADY_S1,
  input [`AXI_IDS_BITS-1:0]         RID_S1,
  input [`AXI_DATA_BITS-1:0]        RDATA_S1,
  input [1:0]                       RRESP_S1,
  input                             RLAST_S1,
  input                             RVALID_S1,
  output logic                      RREADY_S1,
  // S2
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S2,
  output logic [`AXI_ADDR_BITS-1:0]       AWADDR_S2,
  output logic [`AXI_LEN_BITS-1:0]        AWLEN_S2,
  output logic [`AXI_SIZE_BITS-1:0]       AWSIZE_S2,
  output logic [1:0]                      AWBURST_S2,
  output logic                      AWVALID_S2,
  input                             AWREADY_S2,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
  output logic                      WLAST_S2,
  output logic                      WVALID_S2,
  input                             WREADY_S2,
  input [`AXI_IDS_BITS-1:0]         BID_S2,
  input [1:0]                       BRESP_S2,
  input                             BVALID_S2,
  output logic                      BREADY_S2,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S2,
  output logic [`AXI_ADDR_BITS-1:0]       ARADDR_S2,
  output logic [`AXI_LEN_BITS-1:0]        ARLEN_S2,
  output logic [`AXI_SIZE_BITS-1:0]       ARSIZE_S2,
  output logic [1:0]                ARBURST_S2,
  output logic                      ARVALID_S2,
  input                             ARREADY_S2,
  input [`AXI_IDS_BITS-1:0]         RID_S2,
  input [`AXI_DATA_BITS-1:0]        RDATA_S2,
  input [1:0]                       RRESP_S2,
  input                             RLAST_S2,
  input                             RVALID_S2,
  output logic                      RREADY_S2,
  
  // S3
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S3,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S3,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
  output logic [1:0]                AWBURST_S3,
  output logic                      AWVALID_S3,
  input                             AWREADY_S3,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
  output logic                      WLAST_S3,
  output logic                      WVALID_S3,
  input                             WREADY_S3,
  input [`AXI_IDS_BITS-1:0]         BID_S3,
  input [1:0]                       BRESP_S3,
  input                             BVALID_S3,
  output  logic                     BREADY_S3,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S3,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
  output logic [`AXI_LEN_BITS-1:0]  ARLEN_S3,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
  output logic [1:0]                ARBURST_S3,
  output logic                      ARVALID_S3,
  input                             ARREADY_S3,
  input [`AXI_IDS_BITS-1:0]         RID_S3,
  input [`AXI_DATA_BITS-1:0]        RDATA_S3,
  input [1:0]                       RRESP_S3,
  input                             RLAST_S3,
  input                             RVALID_S3,
  output logic                      RREADY_S3,

  // S4
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S4,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S4,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
  output logic [1:0]                AWBURST_S4,
  output logic                      AWVALID_S4,
  input                             AWREADY_S4,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
  output logic                      WLAST_S4,
  output logic                      WVALID_S4,
  input                             WREADY_S4,
  input [`AXI_IDS_BITS-1:0]         BID_S4,
  input [1:0]                       BRESP_S4,
  input                             BVALID_S4,
  output logic                      BREADY_S4,

  // S5
  // WRITE
  output logic [`AXI_IDS_BITS-1:0]  AWID_S5,
  output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
  output logic [`AXI_LEN_BITS-1:0]  AWLEN_S5,
  output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
  output logic [1:0]                AWBURST_S5,
  output logic                      AWVALID_S5,
  input                             AWREADY_S5,
  output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
  output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
  output logic                      WLAST_S5,
  output logic                      WVALID_S5,
  input                             WREADY_S5,
  input [`AXI_IDS_BITS-1:0]         BID_S5,
  input [1:0]                       BRESP_S5,
  input                             BVALID_S5,
  output logic                      BREADY_S5,
  // READ
  output logic [`AXI_IDS_BITS-1:0]  ARID_S5,
  output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
  output logic [`AXI_LEN_BITS-1:0]  ARLEN_S5,
  output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
  output logic [1:0]                ARBURST_S5,
  output logic                      ARVALID_S5,
  input                             ARREADY_S5,
  input [`AXI_IDS_BITS-1:0]         RID_S5,
  input [`AXI_DATA_BITS-1:0]        RDATA_S5,
  input [1:0]                       RRESP_S5,
  input                             RLAST_S5,
  input                             RVALID_S5,
  output logic                      RREADY_S5
);

// ROM   0x0000_0000 ~ 0x0000_1FFF slave0
// IM    0x0001_0000 ~ 0x0001_FFFF slave1
// DM    0x0002_0000 ~ 0x0002_FFFF slave2
// Sctrl 0x1000_0000 ~ 0x1000_03FF slave3
// WDT   0x1001_0000 ~ 0x1001_03FF slave4
// DRAM  0x2000_0000 ~ 0x207F_FFFF slave5

 //---------- you should put your design here ----------//
	// SA means Start Address, I take left half as parameter

  	// parameter SA_S0 I use this method -> ARADDR_reg[31:13] == 0
	parameter SA_S1 = 16'h0001; // LHS
	parameter SA_S2 = 16'h0002; // LHS
	// parameter SA_S3 I use this method -> ARADDR_reg[31:10] == 22'h040000
	// parameter SA_S4 I use this method -> ARADDR_reg[31:10] == 22'h040040
	// parameter SA_S5 I use this method -> ARADDR_reg[31:23] == 9'h040
	
	logic [1:0] state_R, nxt_state_R;
	logic [1:0] state_W, nxt_state_W;

	// FSM parameter naming
	localparam IDLE     = 2'b00;
	localparam Read_M0  = 2'b01;
	localparam Read_M1  = 2'b10;
	localparam Write_M1 = 2'b11;

	// Round robbing counter
	// You can adjust frequency of alternative turn.
	`define CNT_LENGTH 3
	logic [`CNT_LENGTH-1:0] cnt;
	logic chance;

	// cnt: Counter
	always_ff@(posedge ACLK) begin
		if(ARESET)begin
			cnt <= `CNT_LENGTH'b0;
		end
		else begin
			// Within the valid period, if the Master does not request, the opportunity will be handed over to another Master according to Counter.
			cnt <= (state_R == IDLE && state_W == IDLE)? cnt + 3'b1 : `CNT_LENGTH'b0;
		end
	end

	always_ff@(posedge ACLK) begin
		if(ARESET)begin
			chance <= 1'b0;
		end
		else begin
			if(state_R == IDLE && state_W == IDLE) begin
				if(cnt == {`CNT_LENGTH{1'b1}}) begin
					chance <= !chance;
				end
			end
			else begin
				// Master 0 read behavior (with Slave 0) completed
				if((RLAST_S0 && RREADY_M0 && RVALID_S0) || 
				   (RLAST_S1 && RREADY_M0 && RVALID_S1) ||
				   (RLAST_S3 && RREADY_M0 && RVALID_S3) ||
				   (RLAST_S5 && RREADY_M0 && RVALID_S5))begin
					chance <= ~chance;
				end

				// Master 1 read/write behavior (with Slave 0 or Slave 1) completed
				else if(((RLAST_S0 && RREADY_M1 && RVALID_S0) || 
				         (RLAST_S1 && RREADY_M1 && RVALID_S1) ||
						 (RLAST_S2 && RREADY_M1 && RVALID_S2) ||
						 (RLAST_S3 && RREADY_M1 && RVALID_S3) || 
						 (RLAST_S5 && RREADY_M1 && RVALID_S5)) ||

				        ((BREADY_M1 && BVALID_S1) || 
						 (BREADY_M1 && BVALID_S2) ||
						 (BREADY_M1 && BVALID_S3) || 
						 (BREADY_M1 && BVALID_S4) || 
						 (BREADY_M1 && BVALID_S5))) begin
					chance <= ~chance;
				end
			end
		end
	end

	logic M0_turn, M1_turn;
	assign M0_turn = ~chance;
	assign M1_turn = chance;
	

	// Illustration of CPU (master0, master1 limitations): 
	// 1. Master 0 only has read function
	// 2. Master 1 has both function but won't do both simultaneously
	
	//================================== READ FSM ==================================
	always_ff@(posedge ACLK) begin
		if(ARESET) state_R <= IDLE;
		else state_R <= nxt_state_R;
	end

	// Next State Declaration
	always_comb begin
		case(state_R)
			IDLE: begin
				if      (M0_turn && ARVALID_M0) nxt_state_R = Read_M0;
				else if (M1_turn && ARVALID_M1) nxt_state_R = Read_M1;
				else nxt_state_R = IDLE;
			end
			Read_M0:begin
				nxt_state_R = ((RLAST_S0 && RREADY_M0 && RVALID_S0) || 
				               (RLAST_S1 && RREADY_M0 && RVALID_S1) ||
							   (RLAST_S3 && RREADY_M0 && RVALID_S3) ||
							   (RLAST_S5 && RREADY_M0 && RVALID_S5))? IDLE : Read_M0;
			end
			Read_M1:begin
				nxt_state_R = ((RLAST_S0 && RREADY_M1 && RVALID_S0) || 
				               (RLAST_S1 && RREADY_M1 && RVALID_S1) || 
							   (RLAST_S2 && RREADY_M1 && RVALID_S2) ||
							   (RLAST_S3 && RREADY_M1 && RVALID_S3) ||
							   (RLAST_S5 && RREADY_M1 && RVALID_S5))? IDLE : Read_M1;
			end
			default:begin
				nxt_state_R = IDLE;
			end
		endcase
	end

	// Address Register for Identifing Slave
	logic [31:0] ARADDR_reg;

	always_ff@(posedge ACLK) begin
		if(ARESET) begin
			ARADDR_reg <= 32'b0;
		end
		else begin
			if (state_R == IDLE && (M0_turn && ARVALID_M0)) ARADDR_reg <= ARADDR_M0;
			else if   (state_R == IDLE && (M1_turn && ARVALID_M1)) ARADDR_reg <= ARADDR_M1;
		end
	end

	

	// Output Signal Delcaration
	always_comb begin
		case(state_R)
			// Ignore the Idle description. Use default as " Idle" to reduce the code
			Read_M0:begin
				// request to Slave 0
				if(ARADDR_reg[31:13] == 19'b0 ) begin
					ARREADY_M0 = ARREADY_S0;

					RID_M0     = RID_S0[3:0];
					RDATA_M0   = RDATA_S0;
					RRESP_M0   = RRESP_S0;
					RLAST_M0   = RLAST_S0;
					RVALID_M0  = RVALID_S0;
				end
				// request to Slave 1
				else if(ARADDR_reg[31:16] == SA_S1)begin
					ARREADY_M0 = ARREADY_S1;

					RID_M0     = RID_S1[3:0];
					RDATA_M0   = RDATA_S1;
					RRESP_M0   = RRESP_S1;
					RLAST_M0   = RLAST_S1;
					RVALID_M0  = RVALID_S1;
				end
				// request to Slave 3
				else if(ARADDR_reg[31:10] == 22'h040000)begin
					ARREADY_M0 = ARREADY_S3;

					RID_M0     = RID_S3[3:0];
					RDATA_M0   = RDATA_S3;
					RRESP_M0   = RRESP_S3;
					RLAST_M0   = RLAST_S3;
					RVALID_M0  = RVALID_S3;
				end
				// request to Slave 5
				else if(ARADDR_reg[31:23] == 9'h040)begin
					ARREADY_M0 = ARREADY_S5;

					RID_M0     = RID_S5[3:0];
					RDATA_M0   = RDATA_S5;
					RRESP_M0   = RRESP_S5;
					RLAST_M0   = RLAST_S5;
					RVALID_M0  = RVALID_S5;
				end
				else begin
					ARREADY_M0 = 1'b0;

					RID_M0     = 4'b0;
					RDATA_M0   = 32'b0;
					RRESP_M0   = 2'b0;
					RLAST_M0   = 1'b0;
					RVALID_M0  = 1'b0;
				end


				ARID_S0    = (ARADDR_reg[31:13] == 19'b0 )? {4'b0,ARID_M0} : 8'b0;
				ARADDR_S0  = (ARADDR_reg[31:13] == 19'b0 )? ARADDR_M0 : 32'b0;
				ARLEN_S0   = (ARADDR_reg[31:13] == 19'b0 )? ARLEN_M0 : 4'b0;
				ARSIZE_S0  = (ARADDR_reg[31:13] == 19'b0 )? ARSIZE_M0 : 3'b0;
				ARBURST_S0 = (ARADDR_reg[31:13] == 19'b0 )? ARBURST_M0 : 2'b0;
				ARVALID_S0 = (ARADDR_reg[31:13] == 19'b0 )? ARVALID_M0 : 1'b0;

				RREADY_S0  = (ARADDR_reg[31:13] == 19'b0 )? RREADY_M0 : 1'b0;

				ARID_S1    = (ARADDR_reg[31:16] == SA_S1)? {4'b0,ARID_M0} : 8'b0;
				ARADDR_S1  = (ARADDR_reg[31:16] == SA_S1)? ARADDR_M0 : 32'b0;
				ARLEN_S1   = (ARADDR_reg[31:16] == SA_S1)? ARLEN_M0 : 4'b0;
				ARSIZE_S1  = (ARADDR_reg[31:16] == SA_S1)? ARSIZE_M0 : 3'b0;
				ARBURST_S1 = (ARADDR_reg[31:16] == SA_S1)? ARBURST_M0 : 2'b0;
				ARVALID_S1 = (ARADDR_reg[31:16] == SA_S1)? ARVALID_M0 : 1'b0;

				RREADY_S1  = (ARADDR_reg[31:16] == SA_S1)? RREADY_M0 : 1'b0;

				ARID_S3    = (ARADDR_reg[31:10] == 22'h040000)? {4'b0,ARID_M0} : 8'b0;
				ARADDR_S3  = (ARADDR_reg[31:10] == 22'h040000)? ARADDR_M0 : 32'b0;
				ARLEN_S3   = (ARADDR_reg[31:10] == 22'h040000)? ARLEN_M0 : 4'b0;
				ARSIZE_S3  = (ARADDR_reg[31:10] == 22'h040000)? ARSIZE_M0 : 3'b0;
				ARBURST_S3 = (ARADDR_reg[31:10] == 22'h040000)? ARBURST_M0 : 2'b0;
				ARVALID_S3 = (ARADDR_reg[31:10] == 22'h040000)? ARVALID_M0 : 1'b0;

				RREADY_S3  = (ARADDR_reg[31:10] == 22'h040000)? RREADY_M0 : 1'b0;

				ARID_S5    = (ARADDR_reg[31:23] == 9'h040)? {4'b0,ARID_M0} : 8'b0;
				ARADDR_S5  = (ARADDR_reg[31:23] == 9'h040)? ARADDR_M0 : 32'b0;
				ARLEN_S5   = (ARADDR_reg[31:23] == 9'h040)? ARLEN_M0 : 4'b0;
				ARSIZE_S5  = (ARADDR_reg[31:23] == 9'h040)? ARSIZE_M0 : 3'b0;
				ARBURST_S5 = (ARADDR_reg[31:23] == 9'h040)? ARBURST_M0 : 2'b0;
				ARVALID_S5 = (ARADDR_reg[31:23] == 9'h040)? ARVALID_M0 : 1'b0;

				RREADY_S5  = (ARADDR_reg[31:23] == 9'h040)? RREADY_M0 : 1'b0;
			
				ARREADY_M1 = 1'b0;

				RID_M1 = 4'b0;
				RDATA_M1 = 32'b0;
				RRESP_M1 = 2'b0;
				RLAST_M1 = 1'b0;
				RVALID_M1 = 1'b0;

				ARID_S2 = 8'b0;
				ARADDR_S2 = 32'b0;
				ARLEN_S2 = 4'b0;
				ARSIZE_S2 = 3'b0;
				ARBURST_S2 = 2'b0;
				ARVALID_S2 = 1'b0;

				RREADY_S2 = 1'b0;
			end
			Read_M1:begin
				ARREADY_M0 = 1'b0;

				RID_M0 = 4'b0;
				RDATA_M0 = 32'b0;
				RRESP_M0 = 2'b0;
				RLAST_M0 = 1'b0;
				RVALID_M0 = 1'b0;
				
				// Request to S0
				if(ARADDR_reg[31:13] == 19'b0 ) begin
					ARREADY_M1 = ARREADY_S0;

					RID_M1     = RID_S0[3:0];
					RDATA_M1   = RDATA_S0;
					RRESP_M1   = RRESP_S0;
					RLAST_M1   = RLAST_S0;
					RVALID_M1  = RVALID_S0;
        		end
				// Request to S1
				else if(ARADDR_reg[31:16] == SA_S1) begin
					ARREADY_M1 = ARREADY_S1;

					RID_M1     = RID_S1[3:0];
					RDATA_M1   = RDATA_S1;
					RRESP_M1   = RRESP_S1;
					RLAST_M1   = RLAST_S1;
					RVALID_M1  = RVALID_S1;
				end
				// Request to S2
				else if(ARADDR_reg[31:16] == SA_S2) begin
					ARREADY_M1 = ARREADY_S2;

					RID_M1     = RID_S2[3:0];
					RDATA_M1   = RDATA_S2;
					RRESP_M1   = RRESP_S2;
					RLAST_M1   = RLAST_S2;
					RVALID_M1  = RVALID_S2;
				end
				// Request to S3
				else if(ARADDR_reg[31:10] == 22'h040000) begin
					ARREADY_M1 = ARREADY_S3;

					RID_M1     = RID_S3[3:0];
					RDATA_M1   = RDATA_S3;
					RRESP_M1   = RRESP_S3;
					RLAST_M1   = RLAST_S3;
					RVALID_M1  = RVALID_S3;
				end

				// Request to S5
				else if(ARADDR_reg[31:23] == 9'h040) begin
					ARREADY_M1 = ARREADY_S5;

					RID_M1     = RID_S5[3:0];
					RDATA_M1   = RDATA_S5;
					RRESP_M1   = RRESP_S5;
					RLAST_M1   = RLAST_S5;
					RVALID_M1  = RVALID_S5;
				end
				else begin
					ARREADY_M1 = 1'b0;

					RID_M1     = 4'b0;
					RDATA_M1   = 32'b0;
					RRESP_M1   = 2'b0;
					RLAST_M1   = 1'b0;
					RVALID_M1  = 1'b0;
				end

        		ARID_S0    = (ARADDR_reg[31:13] == 19'b0 )? {4'b0,ARID_M1} : 8'b0;
				ARADDR_S0  = (ARADDR_reg[31:13] == 19'b0 )? ARADDR_M1 : 32'b0;
				ARLEN_S0   = (ARADDR_reg[31:13] == 19'b0 )? ARLEN_M1 : 4'b0;
				ARSIZE_S0  = (ARADDR_reg[31:13] == 19'b0 )? ARSIZE_M1 : 3'b0;
				ARBURST_S0 = (ARADDR_reg[31:13] == 19'b0 )? ARBURST_M1 : 2'b0;
				ARVALID_S0 = (ARADDR_reg[31:13] == 19'b0 )? ARVALID_M1 : 1'b0;

				RREADY_S0  = (ARADDR_reg[31:13] == 19'b0 )? RREADY_M1 : 1'b0;

				ARID_S1    = (ARADDR_reg[31:16] == SA_S1)? {4'b0,ARID_M1} : 8'b0;
				ARADDR_S1  = (ARADDR_reg[31:16] == SA_S1)? ARADDR_M1 : 32'b0;
				ARLEN_S1   = (ARADDR_reg[31:16] == SA_S1)? ARLEN_M1 : 4'b0;
				ARSIZE_S1  = (ARADDR_reg[31:16] == SA_S1)? ARSIZE_M1 : 3'b0;
				ARBURST_S1 = (ARADDR_reg[31:16] == SA_S1)? ARBURST_M1 : 2'b0;
				ARVALID_S1 = (ARADDR_reg[31:16] == SA_S1)? ARVALID_M1 : 1'b0;

				RREADY_S1  = (ARADDR_reg[31:16] == SA_S1)? RREADY_M1 : 1'b0;

				ARID_S2    = (ARADDR_reg[31:16] == SA_S2)? {4'b0,ARID_M1} : 8'b0;
				ARADDR_S2  = (ARADDR_reg[31:16] == SA_S2)? ARADDR_M1 : 32'b0;
				ARLEN_S2   = (ARADDR_reg[31:16] == SA_S2)? ARLEN_M1 : 4'b0;
				ARSIZE_S2  = (ARADDR_reg[31:16] == SA_S2)? ARSIZE_M1 : 3'b0;
				ARBURST_S2 = (ARADDR_reg[31:16] == SA_S2)? ARBURST_M1 : 2'b0;
				ARVALID_S2 = (ARADDR_reg[31:16] == SA_S2)? ARVALID_M1 : 1'b0;

				RREADY_S2  = (ARADDR_reg[31:16] == SA_S2)? RREADY_M1 : 1'b0;

				ARID_S3    = (ARADDR_reg[31:10] == 22'h040000)? {4'b0,ARID_M1} : 8'b0;
				ARADDR_S3  = (ARADDR_reg[31:10] == 22'h040000)? ARADDR_M1 : 32'b0;
				ARLEN_S3   = (ARADDR_reg[31:10] == 22'h040000)? ARLEN_M1 : 4'b0;
				ARSIZE_S3  = (ARADDR_reg[31:10] == 22'h040000)? ARSIZE_M1 : 3'b0;
				ARBURST_S3 = (ARADDR_reg[31:10] == 22'h040000)? ARBURST_M1 : 2'b0;
				ARVALID_S3 = (ARADDR_reg[31:10] == 22'h040000)? ARVALID_M1 : 1'b0;

				RREADY_S3  = (ARADDR_reg[31:10] == 22'h040000)? RREADY_M1 : 1'b0;

				ARID_S5    = (ARADDR_reg[31:23] == 9'h040)? {4'b0,ARID_M1} : 8'b0;
				ARADDR_S5  = (ARADDR_reg[31:23] == 9'h040)? ARADDR_M1 : 32'b0;
				ARLEN_S5   = (ARADDR_reg[31:23] == 9'h040)? ARLEN_M1 : 4'b0;
				ARSIZE_S5  = (ARADDR_reg[31:23] == 9'h040)? ARSIZE_M1 : 3'b0;
				ARBURST_S5 = (ARADDR_reg[31:23] == 9'h040)? ARBURST_M1 : 2'b0;
				ARVALID_S5 = (ARADDR_reg[31:23] == 9'h040)? ARVALID_M1 : 1'b0;

				RREADY_S5  = (ARADDR_reg[31:23] == 9'h040)? RREADY_M1 : 1'b0;
			
			end
			default:begin
				ARREADY_M0 = 1'b0;

				RID_M0 = 4'b0;
				RDATA_M0 = 32'b0;
				RRESP_M0 = 2'b0;
				RLAST_M0 = 1'b0;
				RVALID_M0 = 1'b0;

				ARREADY_M1 = 1'b0;

				RID_M1 = 4'b0;
				RDATA_M1 = 32'b0;
				RRESP_M1 = 2'b0;
				RLAST_M1 = 1'b0;
				RVALID_M1 = 1'b0;

        		ARID_S0 = 8'b0;
				ARADDR_S0 = 32'b0;
				ARLEN_S0 = 4'b0;
				ARSIZE_S0 = 3'b0;
				ARBURST_S0 = 2'b0;
				ARVALID_S0 = 1'b0;

				RREADY_S0 = 1'b0;

				ARID_S1 = 8'b0;
				ARADDR_S1 = 32'b0;
				ARLEN_S1 = 4'b0;
				ARSIZE_S1 = 3'b0;
				ARBURST_S1 = 2'b0;
				ARVALID_S1 = 1'b0;

				RREADY_S1 = 1'b0;

				ARID_S2 = 8'b0;
				ARADDR_S2 = 32'b0;
				ARLEN_S2 = 4'b0;
				ARSIZE_S2 = 3'b0;
				ARBURST_S2 = 2'b0;
				ARVALID_S2 = 1'b0;

				RREADY_S2 = 1'b0;

				ARID_S3 = 8'b0;
				ARADDR_S3 = 32'b0;
				ARLEN_S3 = 4'b0;
				ARSIZE_S3 = 3'b0;
				ARBURST_S3 = 2'b0;
				ARVALID_S3 = 1'b0;

				RREADY_S3 = 1'b0;

				ARID_S5 = 8'b0;
				ARADDR_S5 = 32'b0;
				ARLEN_S5 = 4'b0;
				ARSIZE_S5 = 3'b0;
				ARBURST_S5 = 2'b0;
				ARVALID_S5 = 1'b0;

				RREADY_S5 = 1'b0;
			end
		endcase
	end

	//================================== WRITE FSM ==================================
	always_ff@(posedge ACLK) begin
		if(ARESET) state_W <= IDLE;
		else state_W <= nxt_state_W;
	end

	always_comb begin
		case(state_W)
		IDLE:begin
			if (M1_turn && AWVALID_M1) nxt_state_W = Write_M1;
			else nxt_state_W = IDLE;
		end
		Write_M1:begin
			nxt_state_W = ((BREADY_M1 && BVALID_S1) ||
			               (BREADY_M1 && BVALID_S2) || 
						   (BREADY_M1 && BVALID_S3) || 
						   (BREADY_M1 && BVALID_S4) || 
						   (BREADY_M1 && BVALID_S5))? IDLE : Write_M1;
		end
		default: nxt_state_W = IDLE;
		endcase
	end

	// Address Register for Identifing Slave
	logic [31:0] AWADDR_reg;

	always_ff@(posedge ACLK) begin
		if(ARESET) begin
			AWADDR_reg <= 32'b0;
		end
		else begin
			if (state_W == IDLE && (M1_turn && AWVALID_M1)) AWADDR_reg <= AWADDR_M1;
		end
	end

	// Output Signal Delcaration
	always_comb begin
		case(state_W)
		// Ignore the Idle description. Use default as " Idle"
		Write_M1:begin
			// Request to s1
			AWID_S1    = (AWADDR_reg[31:16] == SA_S1)? {4'b0,AWID_M1} : 8'b0;
			AWADDR_S1  = (AWADDR_reg[31:16] == SA_S1)? AWADDR_M1 : 32'b0;
			AWLEN_S1   = (AWADDR_reg[31:16] == SA_S1)? AWLEN_M1 : 4'b0;
			AWSIZE_S1  = (AWADDR_reg[31:16] == SA_S1)? AWSIZE_M1 : 3'b0;
			AWBURST_S1 = (AWADDR_reg[31:16] == SA_S1)? AWBURST_M1 : 2'b0;
			AWVALID_S1 = (AWADDR_reg[31:16] == SA_S1)? AWVALID_M1 : 1'b0;

			WDATA_S1   = (AWADDR_reg[31:16] == SA_S1)? WDATA_M1 : 32'b0;
			WSTRB_S1   = (AWADDR_reg[31:16] == SA_S1)? WSTRB_M1 : 4'b0;
			WLAST_S1   = (AWADDR_reg[31:16] == SA_S1)? WLAST_M1 : 1'b0;
			WVALID_S1  = (AWADDR_reg[31:16] == SA_S1)? WVALID_M1 : 1'b0;

			BREADY_S1  = (AWADDR_reg[31:16] == SA_S1)? BREADY_M1 : 	1'b0;
			
			// Request to s2
			AWID_S2    = (AWADDR_reg[31:16] == SA_S2)? {4'b0,AWID_M1} : 8'b0;
			AWADDR_S2  = (AWADDR_reg[31:16] == SA_S2)? AWADDR_M1 : 32'b0;
			AWLEN_S2   = (AWADDR_reg[31:16] == SA_S2)? AWLEN_M1 : 4'b0;
			AWSIZE_S2  = (AWADDR_reg[31:16] == SA_S2)? AWSIZE_M1 : 3'b0;
			AWBURST_S2 = (AWADDR_reg[31:16] == SA_S2)? AWBURST_M1 : 2'b0;
			AWVALID_S2 = (AWADDR_reg[31:16] == SA_S2)? AWVALID_M1 : 1'b0;

			WDATA_S2   = (AWADDR_reg[31:16] == SA_S2)? WDATA_M1 : 32'b0;
			WSTRB_S2   = (AWADDR_reg[31:16] == SA_S2)? WSTRB_M1 : 4'b0;
			WLAST_S2   = (AWADDR_reg[31:16] == SA_S2)? WLAST_M1 : 1'b0;
			WVALID_S2  = (AWADDR_reg[31:16] == SA_S2)? WVALID_M1 : 1'b0;

			BREADY_S2  = (AWADDR_reg[31:16] == SA_S2)? BREADY_M1 : 1'b0;

			// Request to s3
			AWID_S3    = (AWADDR_reg[31:10] == 22'h040000)? {4'b0,AWID_M1} : 8'b0;
			AWADDR_S3  = (AWADDR_reg[31:10] == 22'h040000)? AWADDR_M1 : 32'b0;
			AWLEN_S3   = (AWADDR_reg[31:10] == 22'h040000)? AWLEN_M1 : 4'b0;
			AWSIZE_S3  = (AWADDR_reg[31:10] == 22'h040000)? AWSIZE_M1 : 3'b0;
			AWBURST_S3 = (AWADDR_reg[31:10] == 22'h040000)? AWBURST_M1 : 2'b0;
			AWVALID_S3 = (AWADDR_reg[31:10] == 22'h040000)? AWVALID_M1 : 1'b0;

			WDATA_S3   = (AWADDR_reg[31:10] == 22'h040000)? WDATA_M1 : 32'b0;
			WSTRB_S3   = (AWADDR_reg[31:10] == 22'h040000)? WSTRB_M1 : 4'b0;
			WLAST_S3   = (AWADDR_reg[31:10] == 22'h040000)? WLAST_M1 : 1'b0;
			WVALID_S3  = (AWADDR_reg[31:10] == 22'h040000)? WVALID_M1 : 1'b0;

			BREADY_S3  = (AWADDR_reg[31:10] == 22'h040000)? BREADY_M1 : 1'b0;

			// Request to s4
			AWID_S4    = (AWADDR_reg[31:10] == 22'h040040)? {4'b0,AWID_M1} : 8'b0;
			AWADDR_S4  = (AWADDR_reg[31:10] == 22'h040040)? AWADDR_M1 : 32'b0;
			AWLEN_S4   = (AWADDR_reg[31:10] == 22'h040040)? AWLEN_M1 : 4'b0;
			AWSIZE_S4  = (AWADDR_reg[31:10] == 22'h040040)? AWSIZE_M1 : 3'b0;
			AWBURST_S4 = (AWADDR_reg[31:10] == 22'h040040)? AWBURST_M1 : 2'b0;
			AWVALID_S4 = (AWADDR_reg[31:10] == 22'h040040)? AWVALID_M1 : 1'b0;

			WDATA_S4   = (AWADDR_reg[31:10] == 22'h040040)? WDATA_M1 : 32'b0;
			WSTRB_S4   = (AWADDR_reg[31:10] == 22'h040040)? WSTRB_M1 : 4'b0;
			WLAST_S4   = (AWADDR_reg[31:10] == 22'h040040)? WLAST_M1 : 1'b0;
			WVALID_S4  = (AWADDR_reg[31:10] == 22'h040040)? WVALID_M1 : 1'b0;

			BREADY_S4  = (AWADDR_reg[31:10] == 22'h040040)? BREADY_M1 : 1'b0;
			
			// Request to s5
			AWID_S5    = (AWADDR_reg[31:23] == 9'h040)? {4'b0,AWID_M1} : 8'b0;
			AWADDR_S5  = (AWADDR_reg[31:23] == 9'h040)? AWADDR_M1 : 32'b0;
			AWLEN_S5   = (AWADDR_reg[31:23] == 9'h040)? AWLEN_M1 : 4'b0;
			AWSIZE_S5  = (AWADDR_reg[31:23] == 9'h040)? AWSIZE_M1 : 3'b0;
			AWBURST_S5 = (AWADDR_reg[31:23] == 9'h040)? AWBURST_M1 : 2'b0;
			AWVALID_S5 = (AWADDR_reg[31:23] == 9'h040)? AWVALID_M1 : 1'b0;

			WDATA_S5   = (AWADDR_reg[31:23] == 9'h040)? WDATA_M1 : 32'b0;
			WSTRB_S5   = (AWADDR_reg[31:23] == 9'h040)? WSTRB_M1 : 4'b0;
			WLAST_S5   = (AWADDR_reg[31:23] == 9'h040)? WLAST_M1 : 1'b0;
			WVALID_S5  = (AWADDR_reg[31:23] == 9'h040)? WVALID_M1 : 1'b0;

			BREADY_S5  = (AWADDR_reg[31:23] == 9'h040)? BREADY_M1 : 	1'b0;

			
			if(AWADDR_reg[31:16] == SA_S1) begin
				AWREADY_M1 = AWREADY_S1;
				WREADY_M1 = WREADY_S1;
				BID_M1 = BID_S1[3:0];
				BRESP_M1 = BRESP_S1;
				BVALID_M1 = BVALID_S1;
			end

			else if(AWADDR_reg[31:16] == SA_S2) begin
				AWREADY_M1 = AWREADY_S2;
				WREADY_M1  = WREADY_S2;
				BID_M1     = BID_S2[3:0];
				BRESP_M1   = BRESP_S2;
				BVALID_M1  = BVALID_S2;
			end
			
			else if(AWADDR_reg[31:10] == 22'h040000) begin
				AWREADY_M1 = AWREADY_S3;
				WREADY_M1  = WREADY_S3;
				BID_M1     = BID_S3[3:0];
				BRESP_M1   = BRESP_S3;
				BVALID_M1  = BVALID_S3;
			end

			else if(AWADDR_reg[31:10] == 22'h040040) begin
				AWREADY_M1 = AWREADY_S4;
				WREADY_M1  = WREADY_S4;
				BID_M1     = BID_S4[3:0];
				BRESP_M1   = BRESP_S4;
				BVALID_M1  = BVALID_S4;
			end

			else if(AWADDR_reg[31:23] == 9'h040) begin
				AWREADY_M1 = AWREADY_S5;
				WREADY_M1 = WREADY_S5;
				BID_M1 = BID_S5[3:0];
				BRESP_M1 = BRESP_S5;
				BVALID_M1 = BVALID_S5;
			end

			else begin
				AWREADY_M1 = 1'b0;
				WREADY_M1 = 1'b0;
				BID_M1 = 4'b0;
				BRESP_M1 = 2'b0;
				BVALID_M1 = 1'b0;
			end	

		end
		default:begin
			AWREADY_M1 = 1'b0;
			WREADY_M1 = 1'b0;
			BID_M1 = 4'b0;
			BRESP_M1 = 2'b0;
			BVALID_M1 = 1'b0;

			AWID_S1 = 8'b0;
			AWADDR_S1 = 32'b0;
			AWLEN_S1 = 4'b0;
			AWSIZE_S1 = 3'b0;
			AWBURST_S1 = 2'b0;
			AWVALID_S1 = 1'b0;

			WDATA_S1 = 32'b0;
			WSTRB_S1 = 4'b0;
			WLAST_S1 = 1'b0;
			WVALID_S1 = 1'b0;

			BREADY_S1 = 1'b0;

			AWID_S2 = 8'b0;
			AWADDR_S2 = 32'b0;
			AWLEN_S2 = 4'b0;
			AWSIZE_S2 = 3'b0;
			AWBURST_S2 = 2'b0;
			AWVALID_S2 = 1'b0;

			WDATA_S2 = 32'b0;
			WSTRB_S2 = 4'b0;
			WLAST_S2 = 1'b0;
			WVALID_S2 = 1'b0;

			BREADY_S2 = 1'b0;

			AWID_S3 = 8'b0;
			AWADDR_S3 = 32'b0;
			AWLEN_S3 = 4'b0;
			AWSIZE_S3 = 3'b0;
			AWBURST_S3 = 2'b0;
			AWVALID_S3 = 1'b0;

			WDATA_S3 = 32'b0;
			WSTRB_S3 = 4'b0;
			WLAST_S3 = 1'b0;
			WVALID_S3 = 1'b0;

			BREADY_S3 = 1'b0;

			AWID_S4 = 8'b0;
			AWADDR_S4 = 32'b0;
			AWLEN_S4 = 4'b0;
			AWSIZE_S4 = 3'b0;
			AWBURST_S4 = 2'b0;
			AWVALID_S4 = 1'b0;

			WDATA_S4 = 32'b0;
			WSTRB_S4 = 4'b0;
			WLAST_S4 = 1'b0;
			WVALID_S4 = 1'b0;

			BREADY_S4 = 1'b0;

			AWID_S5 = 8'b0;
			AWADDR_S5 = 32'b0;
			AWLEN_S5 = 4'b0;
			AWSIZE_S5 = 3'b0;
			AWBURST_S5 = 2'b0;
			AWVALID_S5 = 1'b0;

			WDATA_S5 = 32'b0;
			WSTRB_S5 = 4'b0;
			WLAST_S5 = 1'b0;
			WVALID_S5 = 1'b0;

			BREADY_S5 = 1'b0;
		end
		endcase
	end

endmodule
