// Header file
`include "../include/AXI_define.svh"
`include "../include/Config.svh"

// Sub-Module file
`include "CPU_wrapper.sv"
`include "SRAM_wrapper.sv"
`include "ROM_wrapper.sv"
`include "sctrl_wrapper.sv"
`include "WDT_wrapper.sv"
`include "DRAM_wrapper.sv"
`include "tag_array_wrapper.sv"
`include "data_array_wrapper.sv"
`include "AXI/AXI.sv"
`include "S2F_cdc.sv"

module top(
    input clk,
    input rst,

	// Clock and Rst for Watch Dog Timer
	input clk2,
	input rst2,

	// Connect with Sensor
	input        sensor_ready,
	input [31:0] sensor_out,
	output       sensor_en,
	
	// Connect with ROM
	input[31:0] ROM_out,
	output logic ROM_read,
	output logic ROM_enable,
	output[11:0] ROM_address,
	
	// Connect with DRAM
	input[31:0] DRAM_Q,
	input DRAM_valid,
	output DRAM_CSn,
	output[3:0] DRAM_WEn,
	output DRAM_RASn,
	output DRAM_CASn,
	output[10:0] DRAM_A,
	output[31:0] DRAM_D
);

	//SLAVE INTERFACE FOR MASTER--------------------------------------------------//
	//WRITE ADDRESS
	logic [`AXI_ID_BITS-1:0]   AWID_M1;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_M1;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_M1;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1;
	logic [1:0]                AWBURST_M1;
	logic                      AWVALID_M1;
	logic                      AWREADY_M1;
	//WRITE DATA
	logic [`AXI_DATA_BITS-1:0] WDATA_M1;
	logic [`AXI_STRB_BITS-1:0] WSTRB_M1;
	logic                      WLAST_M1;
	logic                      WVALID_M1;
	logic                      WREADY_M1;
	//WRITE RESPONSE
	logic [`AXI_ID_BITS-1:0]   BID_M1;
	logic [1:0]                BRESP_M1;
	logic                      BVALID_M1;
	logic                      BREADY_M1;
	
	//READ ADDRESS0
	logic [`AXI_ID_BITS-1:0]   ARID_M0;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_M0;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_M0;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0;
	logic [1:0]                ARBURST_M0;
	logic   				   ARVALID_M0;
	logic                      ARREADY_M0;
	//READ DATA0
	logic [`AXI_ID_BITS-1:0]   RID_M0;
	logic [`AXI_DATA_BITS-1:0] RDATA_M0;
	logic [1:0]                RRESP_M0;
	logic                      RLAST_M0;
	logic                      RVALID_M0;
	logic                      RREADY_M0;
	//READ ADDRESS1
	logic [`AXI_ID_BITS-1:0]   ARID_M1;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_M1;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_M1;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1;
	logic [1:0]                ARBURST_M1;
	logic                      ARVALID_M1;
	logic                      ARREADY_M1;
	//READ DATA1
	logic [`AXI_ID_BITS-1:0]   RID_M1;
	logic [`AXI_DATA_BITS-1:0] RDATA_M1;
	logic [1:0]                RRESP_M1;
	logic                      RLAST_M1;
	logic                      RVALID_M1;
	logic                      RREADY_M1;

	//MASTER INTERFACE FOR SLAVES--------------------------------------------------//
	//WRITE ADDRESS1
	logic [`AXI_IDS_BITS-1:0]  AWID_S1;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S1;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S1;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1;
	logic [1:0]                AWBURST_S1;
	logic                      AWVALID_S1;
	logic                      AWREADY_S1;
	//WRITE DATA1
	logic [`AXI_DATA_BITS-1:0] WDATA_S1;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S1;
	logic                      WLAST_S1;
	logic                      WVALID_S1;
	logic                      WREADY_S1;
	//WRITE RESPONSE1
	logic [`AXI_IDS_BITS-1:0]  BID_S1;
	logic [1:0]                BRESP_S1;
	logic                      BVALID_S1;
	logic                      BREADY_S1;
	
	//WRITE ADDRESS2
	logic [`AXI_IDS_BITS-1:0]  AWID_S2;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S2;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S2;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2;
	logic [1:0]                AWBURST_S2;
	logic                      AWVALID_S2;
	logic                      AWREADY_S2;
	//WRITE DATA2
	logic [`AXI_DATA_BITS-1:0] WDATA_S2;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S2;
	logic                      WLAST_S2;
	logic                      WVALID_S2;
	logic                      WREADY_S2;
	//WRITE RESPONSE2
	logic [`AXI_IDS_BITS-1:0]  BID_S2;
	logic [1:0]                BRESP_S2;
	logic                      BVALID_S2;
	logic                      BREADY_S2;

	//WRITE ADDRESS3
	logic [`AXI_IDS_BITS-1:0]  AWID_S3;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S3;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S3;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3;
	logic [1:0]                AWBURST_S3;
	logic                      AWVALID_S3;
	logic                      AWREADY_S3;
	//WRITE DATA3
	logic [`AXI_DATA_BITS-1:0] WDATA_S3;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S3;
	logic                      WLAST_S3;
	logic                      WVALID_S3;
	logic                      WREADY_S3;
	//WRITE RESPONSE3
	logic [`AXI_IDS_BITS-1:0]  BID_S3;
	logic [1:0]                BRESP_S3;
	logic                      BVALID_S3;
	logic                      BREADY_S3;

	//WRITE ADDRESS4
	logic [`AXI_IDS_BITS-1:0]  AWID_S4;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S4;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S4;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4;
	logic [1:0]                AWBURST_S4;
	logic                      AWVALID_S4;
	logic                      AWREADY_S4;
	//WRITE DATA3
	logic [`AXI_DATA_BITS-1:0] WDATA_S4;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S4;
	logic                      WLAST_S4;
	logic                      WVALID_S4;
	logic                      WREADY_S4;
	//WRITE RESPONSE3
	logic [`AXI_IDS_BITS-1:0]  BID_S4;
	logic [1:0]                BRESP_S4;
	logic                      BVALID_S4;
	logic                      BREADY_S4;

	//WRITE ADDRESS5
	logic [`AXI_IDS_BITS-1:0]  AWID_S5;
	logic [`AXI_ADDR_BITS-1:0] AWADDR_S5;
	logic [`AXI_LEN_BITS-1:0]  AWLEN_S5;
	logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5;
	logic [1:0]                AWBURST_S5;
	logic                      AWVALID_S5;
	logic                      AWREADY_S5;
	//WRITE DATA5
	logic [`AXI_DATA_BITS-1:0] WDATA_S5;
	logic [`AXI_STRB_BITS-1:0] WSTRB_S5;
	logic                      WLAST_S5;
	logic                      WVALID_S5;
	logic                      WREADY_S5;
	//WRITE RESPONSE5
	logic [`AXI_IDS_BITS-1:0]  BID_S5;
	logic [1:0]                BRESP_S5;
	logic                      BVALID_S5;
	logic                      BREADY_S5;
	
	//READ ADDRESS0
	logic [`AXI_IDS_BITS-1:0]  ARID_S0;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S0;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S0;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0;
	logic [1:0]                ARBURST_S0;
	logic                      ARVALID_S0;
	logic                      ARREADY_S0;
	//READ DATA0
	logic [`AXI_IDS_BITS-1:0]  RID_S0;
	logic [`AXI_DATA_BITS-1:0] RDATA_S0;
	logic [1:0]                RRESP_S0;
	logic                      RLAST_S0;
	logic                      RVALID_S0;
	logic                      RREADY_S0;

	//READ ADDRESS1
	logic [`AXI_IDS_BITS-1:0]  ARID_S1;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S1;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S1;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1;
	logic [1:0]                ARBURST_S1;
	logic                      ARVALID_S1;
	logic                      ARREADY_S1;
	//READ DATA1
	logic [`AXI_IDS_BITS-1:0]  RID_S1;
	logic [`AXI_DATA_BITS-1:0] RDATA_S1;
	logic [1:0]                RRESP_S1;
	logic                      RLAST_S1;
	logic                      RVALID_S1;
	logic                      RREADY_S1;
	
	//READ ADDRESS2
	logic [`AXI_IDS_BITS-1:0]  ARID_S2;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S2;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S2;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2;
	logic [1:0]                ARBURST_S2;
	logic                      ARVALID_S2;
	logic                      ARREADY_S2;
	//READ DATA2
	logic [`AXI_IDS_BITS-1:0]  RID_S2;
	logic [`AXI_DATA_BITS-1:0] RDATA_S2;
	logic [1:0]                RRESP_S2;
	logic                      RLAST_S2;
	logic                      RVALID_S2;
	logic                      RREADY_S2;

	//READ ADDRESS3
	logic [`AXI_IDS_BITS-1:0]  ARID_S3;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S3;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S3;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3;
	logic [1:0]                ARBURST_S3;
	logic                      ARVALID_S3;
	logic                      ARREADY_S3;
	//READ DATA3
	logic [`AXI_IDS_BITS-1:0]  RID_S3;
	logic [`AXI_DATA_BITS-1:0] RDATA_S3;
	logic [1:0]                RRESP_S3;
	logic                      RLAST_S3;
	logic                      RVALID_S3;
	logic                      RREADY_S3;

	//READ ADDRESS5
	logic [`AXI_IDS_BITS-1:0]  ARID_S5;
	logic [`AXI_ADDR_BITS-1:0] ARADDR_S5;
	logic [`AXI_LEN_BITS-1:0]  ARLEN_S5;
	logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5;
	logic [1:0]                ARBURST_S5;
	logic                      ARVALID_S5;
	logic                      ARREADY_S5;
	//READ DATA4
	logic [`AXI_IDS_BITS-1:0]  RID_S5;
	logic [`AXI_DATA_BITS-1:0] RDATA_S5;
	logic [1:0]                RRESP_S5;
	logic                      RLAST_S5;
	logic                      RVALID_S5;
	logic                      RREADY_S5;

	// Interuption
	logic sctrl_interrupt;
	logic t_interrupt_slow;
	logic t_interrupt_fast;

	// Master 0 & 1
	CPU_wrapper m_cpu_wrapper(
    	.ACLK(clk),
    	.ARESET(rst),

		.ex_interrupt(sctrl_interrupt),
		.tm_interrupt(t_interrupt_fast),

		//READ ADDRESS0
		.ARID_M0(ARID_M0),
		.ARADDR_M0(ARADDR_M0),
		.ARLEN_M0(ARLEN_M0),
		.ARSIZE_M0(ARSIZE_M0),
		.ARBURST_M0(ARBURST_M0),
		.ARVALID_M0(ARVALID_M0),
		.ARREADY_M0(ARREADY_M0),

		//READ DATA0
		.RID_M0(RID_M0),
		.RDATA_M0(RDATA_M0),
		.RRESP_M0(RRESP_M0),
		.RLAST_M0(RLAST_M0),
		.RVALID_M0(RVALID_M0),
    	.RREADY_M0(RREADY_M0),

		//READ ADDRESS1
		.ARID_M1(ARID_M1),
		.ARADDR_M1(ARADDR_M1),
		.ARLEN_M1(ARLEN_M1),
		.ARSIZE_M1(ARSIZE_M1),
		.ARBURST_M1(ARBURST_M1),
		.ARVALID_M1(ARVALID_M1),
		.ARREADY_M1(ARREADY_M1),

		//READ DATA1
		.RID_M1(RID_M1),
		.RDATA_M1(RDATA_M1),
		.RRESP_M1(RRESP_M1),
		.RLAST_M1(RLAST_M1),
		.RVALID_M1(RVALID_M1),
		.RREADY_M1(RREADY_M1),

		//WRITE ADDRESS
  		.AWID_M1(AWID_M1),
		.AWADDR_M1(AWADDR_M1),
		.AWLEN_M1(AWLEN_M1),
		.AWSIZE_M1(AWSIZE_M1),
		.AWBURST_M1(AWBURST_M1),
		.AWVALID_M1(AWVALID_M1),
		.AWREADY_M1(AWREADY_M1),

		// WRITE DATA
		.WDATA_M1(WDATA_M1),
		.WSTRB_M1(WSTRB_M1),
		.WLAST_M1(WLAST_M1),
		.WVALID_M1(WVALID_M1),
		.WREADY_M1(WREADY_M1),

		// WRITE RESPONSE
		.BID_M1(BID_M1),
		.BRESP_M1(BRESP_M1),
		.BVALID_M1(BVALID_M1),
		.BREADY_M1(BREADY_M1)
	);

	// Bridge
	AXI m_axi(
		.ACLK(clk),
		.ARESET(rst),

		//WRITE ADDRESS
		.AWID_M1(AWID_M1),
		.AWADDR_M1(AWADDR_M1),
		.AWLEN_M1(AWLEN_M1),
		.AWSIZE_M1(AWSIZE_M1),
		.AWBURST_M1(AWBURST_M1),
		.AWVALID_M1(AWVALID_M1),
		.AWREADY_M1(AWREADY_M1),

		//WRITE DATA
		.WDATA_M1(WDATA_M1),
		.WSTRB_M1(WSTRB_M1),
		.WLAST_M1(WLAST_M1),
		.WVALID_M1(WVALID_M1),
		.WREADY_M1(WREADY_M1),

		//WRITE RESPONSE
		.BID_M1(BID_M1),
		.BRESP_M1(BRESP_M1),
		.BVALID_M1(BVALID_M1),
		.BREADY_M1(BREADY_M1),

		//READ ADDRESS0
		.ARID_M0(ARID_M0),
		.ARADDR_M0(ARADDR_M0),
		.ARLEN_M0(ARLEN_M0),
		.ARSIZE_M0(ARSIZE_M0),
		.ARBURST_M0(ARBURST_M0),
		.ARVALID_M0(ARVALID_M0),
		.ARREADY_M0(ARREADY_M0),

		//READ DATA0
		.RID_M0(RID_M0),
		.RDATA_M0(RDATA_M0),
		.RRESP_M0(RRESP_M0),
		.RLAST_M0(RLAST_M0),
		.RVALID_M0(RVALID_M0),
    	.RREADY_M0(RREADY_M0),

		//READ ADDRESS1
		.ARID_M1(ARID_M1),
		.ARADDR_M1(ARADDR_M1),
		.ARLEN_M1(ARLEN_M1),
		.ARSIZE_M1(ARSIZE_M1),
		.ARBURST_M1(ARBURST_M1),
		.ARVALID_M1(ARVALID_M1),
		.ARREADY_M1(ARREADY_M1),

		//READ DATA1
		.RID_M1(RID_M1),
		.RDATA_M1(RDATA_M1),
		.RRESP_M1(RRESP_M1),
		.RLAST_M1(RLAST_M1),
		.RVALID_M1(RVALID_M1),
    	.RREADY_M1(RREADY_M1),
		
		//WRITE ADDRESS1
		.AWID_S1(AWID_S1),
		.AWADDR_S1(AWADDR_S1),
		.AWLEN_S1(AWLEN_S1),
		.AWSIZE_S1(AWSIZE_S1),
		.AWBURST_S1(AWBURST_S1),
		.AWVALID_S1(AWVALID_S1),
		.AWREADY_S1(AWREADY_S1),

		//WRITE DATA1
		.WDATA_S1(WDATA_S1),
		.WSTRB_S1(WSTRB_S1),
		.WLAST_S1(WLAST_S1),
		.WVALID_S1(WVALID_S1),
		.WREADY_S1(WREADY_S1),

		//WRITE RESPONSE1
		.BID_S1(BID_S1),
		.BRESP_S1(BRESP_S1),
		.BVALID_S1(BVALID_S1),
		.BREADY_S1(BREADY_S1),
	
		//WRITE ADDRESS2
		.AWID_S2(AWID_S2),
		.AWADDR_S2(AWADDR_S2),
		.AWLEN_S2(AWLEN_S2),
		.AWSIZE_S2(AWSIZE_S2),
		.AWBURST_S2(AWBURST_S2),
		.AWVALID_S2(AWVALID_S2),
		.AWREADY_S2(AWREADY_S2),

		//WRITE DATA2
		.WDATA_S2(WDATA_S2),
		.WSTRB_S2(WSTRB_S2),
		.WLAST_S2(WLAST_S2),
		.WVALID_S2(WVALID_S2),
		.WREADY_S2(WREADY_S2),

		//WRITE RESPONSE2
		.BID_S2(BID_S2),
		.BRESP_S2(BRESP_S2),
		.BVALID_S2(BVALID_S2),
		.BREADY_S2(BREADY_S2),

		//WRITE ADDRESS3
		.AWID_S3(AWID_S3),
		.AWADDR_S3(AWADDR_S3),
		.AWLEN_S3(AWLEN_S3),
		.AWSIZE_S3(AWSIZE_S3),
		.AWBURST_S3(AWBURST_S3),
		.AWVALID_S3(AWVALID_S3),
		.AWREADY_S3(AWREADY_S3),

		//WRITE DATA3
		.WDATA_S3(WDATA_S3),
		.WSTRB_S3(WSTRB_S3),
		.WLAST_S3(WLAST_S3),
		.WVALID_S3(WVALID_S3),
		.WREADY_S3(WREADY_S3),

		//WRITE RESPONSE3
		.BID_S3(BID_S3),
		.BRESP_S3(BRESP_S3),
		.BVALID_S3(BVALID_S3),
		.BREADY_S3(BREADY_S3),

		//WRITE ADDRESS4
		.AWID_S4(AWID_S4),
		.AWADDR_S4(AWADDR_S4),
		.AWLEN_S4(AWLEN_S4),
		.AWSIZE_S4(AWSIZE_S4),
		.AWBURST_S4(AWBURST_S4),
		.AWVALID_S4(AWVALID_S4),
		.AWREADY_S4(AWREADY_S4),

		//WRITE DATA4
		.WDATA_S4(WDATA_S4),
		.WSTRB_S4(WSTRB_S4),
		.WLAST_S4(WLAST_S4),
		.WVALID_S4(WVALID_S4),
		.WREADY_S4(WREADY_S4),

		//WRITE RESPONSE4
		.BID_S4(BID_S4),
		.BRESP_S4(BRESP_S4),
		.BVALID_S4(BVALID_S4),
		.BREADY_S4(BREADY_S4),

		//WRITE ADDRESS5
		.AWID_S5(AWID_S5),
		.AWADDR_S5(AWADDR_S5),
		.AWLEN_S5(AWLEN_S5),
		.AWSIZE_S5(AWSIZE_S5),
		.AWBURST_S5(AWBURST_S5),
		.AWVALID_S5(AWVALID_S5),
		.AWREADY_S5(AWREADY_S5),

		//WRITE DATA4
		.WDATA_S5(WDATA_S5),
		.WSTRB_S5(WSTRB_S5),
		.WLAST_S5(WLAST_S5),
		.WVALID_S5(WVALID_S5),
		.WREADY_S5(WREADY_S5),

		//WRITE RESPONSE4
		.BID_S5(BID_S5),
		.BRESP_S5(BRESP_S5),
		.BVALID_S5(BVALID_S5),
		.BREADY_S5(BREADY_S5),

		//READ ADDRESS0
		.ARID_S0(ARID_S0),
		.ARADDR_S0(ARADDR_S0),
		.ARLEN_S0(ARLEN_S0),
		.ARSIZE_S0(ARSIZE_S0),
		.ARBURST_S0(ARBURST_S0),
		.ARVALID_S0(ARVALID_S0),
		.ARREADY_S0(ARREADY_S0),

		//READ DATA0
		.RID_S0(RID_S0),
		.RDATA_S0(RDATA_S0),
		.RRESP_S0(RRESP_S0),
		.RLAST_S0(RLAST_S0),
		.RVALID_S0(RVALID_S0),
		.RREADY_S0(RREADY_S0),

		//READ ADDRESS1
		.ARID_S1(ARID_S1),
		.ARADDR_S1(ARADDR_S1),
		.ARLEN_S1(ARLEN_S1),
		.ARSIZE_S1(ARSIZE_S1),
		.ARBURST_S1(ARBURST_S1),
		.ARVALID_S1(ARVALID_S1),
		.ARREADY_S1(ARREADY_S1),

		//READ DATA1
		.RID_S1(RID_S1),
		.RDATA_S1(RDATA_S1),
		.RRESP_S1(RRESP_S1),
		.RLAST_S1(RLAST_S1),
		.RVALID_S1(RVALID_S1),
		.RREADY_S1(RREADY_S1),

		//READ ADDRESS2
		.ARID_S2(ARID_S2),
		.ARADDR_S2(ARADDR_S2),
		.ARLEN_S2(ARLEN_S2),
		.ARSIZE_S2(ARSIZE_S2),
		.ARBURST_S2(ARBURST_S2),
		.ARVALID_S2(ARVALID_S2),
		.ARREADY_S2(ARREADY_S2),

		//READ DATA2
		.RID_S2(RID_S2),
		.RDATA_S2(RDATA_S2),
		.RRESP_S2(RRESP_S2),
		.RLAST_S2(RLAST_S2),
		.RVALID_S2(RVALID_S2),
		.RREADY_S2(RREADY_S2),

		//READ ADDRESS3
		.ARID_S3(ARID_S3),
		.ARADDR_S3(ARADDR_S3),
		.ARLEN_S3(ARLEN_S3),
		.ARSIZE_S3(ARSIZE_S3),
		.ARBURST_S3(ARBURST_S3),
		.ARVALID_S3(ARVALID_S3),
		.ARREADY_S3(ARREADY_S3),

		//READ DATA3
		.RID_S3(RID_S3),
		.RDATA_S3(RDATA_S3),
		.RRESP_S3(RRESP_S3),
		.RLAST_S3(RLAST_S3),
		.RVALID_S3(RVALID_S3),
		.RREADY_S3(RREADY_S3),

		//READ ADDRESS5
		.ARID_S5(ARID_S5),
		.ARADDR_S5(ARADDR_S5),
		.ARLEN_S5(ARLEN_S5),
		.ARSIZE_S5(ARSIZE_S5),
		.ARBURST_S5(ARBURST_S5),
		.ARVALID_S5(ARVALID_S5),
		.ARREADY_S5(ARREADY_S5),

		//READ DATA4
		.RID_S5(RID_S5),
		.RDATA_S5(RDATA_S5),
		.RRESP_S5(RRESP_S5),
		.RLAST_S5(RLAST_S5),
		.RVALID_S5(RVALID_S5),
		.RREADY_S5(RREADY_S5)
	);

	// slave 0
	ROM_wrapper m_rom_wrapper(
		.ACLK(clk),
		.ARESET(rst),

		// toward AXI
		.ARID_S(ARID_S0),
		.ARADDR_S(ARADDR_S0),
		.ARLEN_S(ARLEN_S0),
		.ARSIZE_S(ARSIZE_S0),
		.ARBURST_S(ARBURST_S0),
		.ARVALID_S(ARVALID_S0),
		.ARREADY_S(ARREADY_S0),

		.RID_S(RID_S0),
		.RDATA_S(RDATA_S0),
		.RRESP_S(RRESP_S0),
		.RLAST_S(RLAST_S0),
		.RVALID_S(RVALID_S0),
		.RREADY_S(RREADY_S0),

		// toward ROM
		.ROM_out(ROM_out),
		.ROM_read(ROM_read),
		.ROM_enable(ROM_enable),
		.ROM_address(ROM_address)
	);

	// slave 1
	SRAM_wrapper IM1(
		.ACLK(clk),
		.ARESET(rst),
		.AWID_S(AWID_S1),
		.AWADDR_S(AWADDR_S1),
		.AWLEN_S(AWLEN_S1),
		.AWSIZE_S(AWSIZE_S1),
		.AWBURST_S(AWBURST_S1),
		.AWVALID_S(AWVALID_S1),
		.AWREADY_S(AWREADY_S1),
		.WDATA_S(WDATA_S1),
		.WSTRB_S(WSTRB_S1),
		.WLAST_S(WLAST_S1),
		.WVALID_S(WVALID_S1),
		.WREADY_S(WREADY_S1),
		.BID_S(BID_S1),
		.BRESP_S(BRESP_S1),
		.BVALID_S(BVALID_S1),
		.BREADY_S(BREADY_S1),
		.ARID_S(ARID_S1),
		.ARADDR_S(ARADDR_S1),
		.ARLEN_S(ARLEN_S1),
		.ARSIZE_S(ARSIZE_S1),
		.ARBURST_S(ARBURST_S1),
		.ARVALID_S(ARVALID_S1),
		.ARREADY_S(ARREADY_S1),
		.RID_S(RID_S1),
		.RDATA_S(RDATA_S1),
		.RRESP_S(RRESP_S1),
		.RLAST_S(RLAST_S1),
		.RVALID_S(RVALID_S1),
		.RREADY_S(RREADY_S1)
	);
	
	// slave 2
	SRAM_wrapper DM1(
		.ACLK(clk),
		.ARESET(rst),
		.AWID_S(AWID_S2),
		.AWADDR_S(AWADDR_S2),
		.AWLEN_S(AWLEN_S2),
		.AWSIZE_S(AWSIZE_S2),
		.AWBURST_S(AWBURST_S2),
		.AWVALID_S(AWVALID_S2),
		.AWREADY_S(AWREADY_S2),
		.WDATA_S(WDATA_S2),
		.WSTRB_S(WSTRB_S2),
		.WLAST_S(WLAST_S2),
		.WVALID_S(WVALID_S2),
		.WREADY_S(WREADY_S2),
		.BID_S(BID_S2),
		.BRESP_S(BRESP_S2),
		.BVALID_S(BVALID_S2),
		.BREADY_S(BREADY_S2),
		.ARID_S(ARID_S2),
		.ARADDR_S(ARADDR_S2),
		.ARLEN_S(ARLEN_S2),
		.ARSIZE_S(ARSIZE_S2),
		.ARBURST_S(ARBURST_S2),
		.ARVALID_S(ARVALID_S2),
		.ARREADY_S(ARREADY_S2),
		.RID_S(RID_S2),
		.RDATA_S(RDATA_S2),
		.RRESP_S(RRESP_S2),
		.RLAST_S(RLAST_S2),
		.RVALID_S(RVALID_S2),
		.RREADY_S(RREADY_S2)
	);

	// slave 3
	sctrl_wrapper sctrl_wrapper(
		.ACLK(clk),
		.ARESET(rst),

		// Connect with Sensor
		.sensor_ready(sensor_ready),
		.sensor_out(sensor_out),
		.sensor_en(sensor_en),

		// Connect with CPU skip AXI
  		.sctrl_interrupt(sctrl_interrupt),

		// AXI slave 3 ports
		.AWID_S(AWID_S3),
		.AWADDR_S(AWADDR_S3),
		.AWLEN_S(AWLEN_S3),
		.AWSIZE_S(AWSIZE_S3),
		.AWBURST_S(AWBURST_S3),
		.AWVALID_S(AWVALID_S3),
		.AWREADY_S(AWREADY_S3),

		.WDATA_S(WDATA_S3),
		.WSTRB_S(WSTRB_S3),
		.WLAST_S(WLAST_S3),
		.WVALID_S(WVALID_S3),
		.WREADY_S(WREADY_S3),

		.BID_S(BID_S3),
		.BRESP_S(BRESP_S3),
		.BVALID_S(BVALID_S3),
		.BREADY_S(BREADY_S3),

		.ARID_S(ARID_S3),
		.ARADDR_S(ARADDR_S3),
		.ARLEN_S(ARLEN_S3),
		.ARSIZE_S(ARSIZE_S3),
		.ARBURST_S(ARBURST_S3),
		.ARVALID_S(ARVALID_S3),
		.ARREADY_S(ARREADY_S3),

		.RID_S(RID_S3),
		.RDATA_S(RDATA_S3),
		.RRESP_S(RRESP_S3),
		.RLAST_S(RLAST_S3),
		.RVALID_S(RVALID_S3),
		.RREADY_S(RREADY_S3)
	);

	// slave 4
	WDT_wrapper WDT1(
		.clk(clk),
		.rst(rst),
		.clk2(clk2),
		.rst2(rst2),
		
		.WTO(t_interrupt_slow),
		
		.AWID_S(AWID_S4),
		.AWADDR_S(AWADDR_S4),
		.AWLEN_S(AWLEN_S4),
		.AWSIZE_S(AWSIZE_S4),
		.AWBURST_S(AWBURST_S4),
		.AWVALID_S(AWVALID_S4),
		.AWREADY_S(AWREADY_S4),

		.WDATA_S(WDATA_S4),
		.WSTRB_S(WSTRB_S4),
		.WLAST_S(WLAST_S4),
		.WVALID_S(WVALID_S4),
		.WREADY_S(WREADY_S4),

		.BID_S(BID_S4),
		.BRESP_S(BRESP_S4),
		.BVALID_S(BVALID_S4),
		.BREADY_S(BREADY_S4)
	);

	// slave 5
	DRAM_wrapper DRAM_W1(
		.ACLK(clk),
		.ARESET(rst),

		.AWID_S(AWID_S5),
		.AWADDR_S(AWADDR_S5),
		.AWLEN_S(AWLEN_S5),
		.AWSIZE_S(AWSIZE_S5),
		.AWBURST_S(AWBURST_S5),
		.AWVALID_S(AWVALID_S5),
		.AWREADY_S(AWREADY_S5),

		.WDATA_S(WDATA_S5),
		.WSTRB_S(WSTRB_S5),
		.WLAST_S(WLAST_S5),
		.WVALID_S(WVALID_S5),
		.WREADY_S(WREADY_S5),

		.BID_S(BID_S5),
		.BRESP_S(BRESP_S5),
		.BVALID_S(BVALID_S5),
		.BREADY_S(BREADY_S5),

		.ARID_S(ARID_S5),
		.ARADDR_S(ARADDR_S5),
		.ARLEN_S(ARLEN_S5),
		.ARSIZE_S(ARSIZE_S5),
		.ARBURST_S(ARBURST_S5),
		.ARVALID_S(ARVALID_S5),
		.ARREADY_S(ARREADY_S5),

		.RID_S(RID_S5),
		.RDATA_S(RDATA_S5),
		.RRESP_S(RRESP_S5),
		.RLAST_S(RLAST_S5),
		.RVALID_S(RVALID_S5),
		.RREADY_S(RREADY_S5),

		// ports toward DRAM
		.DRAM_CSn(DRAM_CSn),
		.DRAM_WEn(DRAM_WEn),
		.DRAM_RASn(DRAM_RASn),
		.DRAM_CASn(DRAM_CASn),
		.DRAM_A(DRAM_A),
		.DRAM_D(DRAM_D),
		.DRAM_Q(DRAM_Q),
		.DRAM_valid(DRAM_valid)
	);

	S2F_cdc m_s2f(
		.f_clk(clk),
		.f_rst(rst),
		.s_clk(clk2),
		.s_rst(rst2),

		.in(t_interrupt_slow),
		.out(t_interrupt_fast)
	);
endmodule
