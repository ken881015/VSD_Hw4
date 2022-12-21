`include "../include/AXI_define.svh"
`include "../include/Config.svh"

`include "sensor_ctrl.sv"

module sctrl_wrapper(
  input ACLK,
  input ARESET,
  
  // Connect with Sensor
  input sensor_ready,
  input [31:0] sensor_out,
  output sensor_en,

  // Connect with CPU
  output sctrl_interrupt,
  
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
  input [`AXI_IDS_BITS-1:0]  ARID_S,
  input [`AXI_ADDR_BITS-1:0] ARADDR_S,
  input [`AXI_LEN_BITS-1:0]  ARLEN_S,
  input [`AXI_SIZE_BITS-1:0] ARSIZE_S,
  input [1:0]                ARBURST_S,
  input                      ARVALID_S,
  output logic               ARREADY_S,
  //READ DATA
  output logic [`AXI_IDS_BITS-1:0]  RID_S,
  output logic [`AXI_DATA_BITS-1:0] RDATA_S,
  output logic [1:0]                RRESP_S,
  output logic                      RLAST_S,
  output logic                      RVALID_S,
  input                             RREADY_S
);

//wires for sensor_controller
logic sctrl_en;
logic sctrl_clear;
logic [11:0] sctrl_addr;

logic [31:0] sctrl_out;

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

always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        sctrl_addr <= 12'b0;
        sctrl_en <= 1'b0;
        sctrl_clear <= 1'b0;
    end
    else begin
        if(ARREADY_S && ARVALID_S) begin
            sctrl_addr <= ARADDR_S[11:0];
        end
        else if(AWREADY_S && AWVALID_S) begin
            sctrl_addr <= AWADDR_S[11:0];
        end

        if(WREADY_S && WVALID_S) begin
            if(sctrl_addr == 12'h100) sctrl_en <= WDATA_S[0];
            if(sctrl_addr == 12'h200) sctrl_clear <= WDATA_S[0];
        end
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

        Set_HS2    :  nxt_state_R_S = (RREADY_S && RLAST_S)? IDLE : Set_HS2; // Set RVALID_S and RLAST_S to high

        default    :  nxt_state_R_S = IDLE;

    endcase
end 

assign ARREADY_S = (state_R_S == Set_HS1);
assign RVALID_S = (state_R_S == Set_HS2);


logic [3:0] ARLEN_S_reg;
logic [7:0] RID_S_reg;
logic[31:0] RDATA_S_reg;

assign RID_S = RID_S_reg;
assign RRESP_S = `AXI_RESP_OKAY;
assign RDATA_S = RDATA_S_reg;

always_ff @(posedge ACLK ) begin
    if(ARESET)begin
        ARLEN_S_reg <= 4'b0;
        RID_S_reg <= 8'b0;
        RDATA_S_reg <= 32'b0;
    end
    else begin
        if(ARVALID_S && ARREADY_S) begin
            ARLEN_S_reg <= ARLEN_S;
            RID_S_reg <= ARID_S;
        end

        if(state_R_S  == Store_Data) begin
            RDATA_S_reg <= sctrl_out;
        end
    end
end

assign RLAST_S = RVALID_S;

// Write Behavior of Slave ===============================

// stage register description
always_ff @(posedge ACLK ) begin
    if(ARESET) state_W_S <= 3'b0;
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



sensor_ctrl sensor_ctrl_m(
  .clk(ACLK),
  .rst(ARESET),
  // inputs from Core 
  .sctrl_en(sctrl_en),
  .sctrl_clear(sctrl_clear),
  .sctrl_addr(sctrl_addr[7:2]),

  // inputs from Sensor 
  .sensor_ready(sensor_ready),
  .sensor_out(sensor_out),

  // Core outputs
  .sctrl_interrupt(sctrl_interrupt), 
  .sctrl_out(sctrl_out),

  // Sensor outputs
  .sensor_en(sensor_en)
);

endmodule
