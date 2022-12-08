`include "../include/AXI_define.svh"
`include "../include/Config.svh"
`include "CPU.sv"
`include "L1C_inst.sv"
`include "L1C_data.sv"

module CPU_wrapper (
    input ACLK,
	input ARESETn,

    // CPU: Inst Mem Read Channel (Master 0)
    //READ ADDRESS0
	output logic [`AXI_ID_BITS-1:0] ARID_M0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output logic [1:0] ARBURST_M0,
	output logic ARVALID_M0,
	input ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0] RID_M0,
	input [`AXI_DATA_BITS-1:0] RDATA_M0,
	input [1:0] RRESP_M0,
	input RLAST_M0,
	input RVALID_M0,
	output logic RREADY_M0,

    // CPU:  Data Mem Read Channel (Master 1)
    //READ ADDRESS1
	output logic [`AXI_ID_BITS-1:0] ARID_M1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output logic [1:0] ARBURST_M1,
	output logic ARVALID_M1,
	input ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0] RID_M1,
	input [`AXI_DATA_BITS-1:0] RDATA_M1,
	input [1:0] RRESP_M1,
	input RLAST_M1,
	input RVALID_M1,
	output logic RREADY_M1,

    // CPU: Data Mem Write Channel (Master 1)
    //WRITE ADDRESS
	output logic [`AXI_ID_BITS-1:0] AWID_M1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_M1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output logic [1:0] AWBURST_M1,
	output logic AWVALID_M1,
	input AWREADY_M1,
	//WRITE DATA
	output logic [`AXI_DATA_BITS-1:0] WDATA_M1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output logic WLAST_M1,
	output logic WVALID_M1,
	input WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0] BID_M1,
	input [1:0] BRESP_M1,
	input BVALID_M1,
	output logic BREADY_M1
);

// inverse reset signal for active high design habit.
logic ARESET;
assign ARESET = !ARESETn;

// wire for CPU output port
logic [31:0] ADDR_cpu;
logic [31:0] DATA_cpu;
logic [3:0] MemRW_cpu;
logic        DMOn_cpu;

// wire for Inst.cache port 

// Input
logic I_wait;

// Output
logic [31:0] core_out_ic;
logic core_wait_ic;
logic I_req;
logic[31:0] I_addr;

// wire for Data.cache port 

// Input
logic D_wait;

// Output
logic[31:0] core_out_dc;
logic core_wait_dc;
logic D_req;
logic[31:0] D_addr;
logic D_write;
logic[31:0] D_in;
logic[2:0] D_type;

// the signal show the need of using DM
logic DMOn;
logic DMOn_enable;

// FSM parameters for 3 types (IM read, DM read, DM write)
logic [2:0] state_R_M0, nxt_state_R_M0;
logic [2:0] state_R_M1, nxt_state_R_M1;
logic [2:0] state_W_M1, nxt_state_W_M1;

// define state name by using macro
localparam IDLE       = 3'b000;

localparam Set_HS1    = 3'b001; // set one of signal (ready or valid) that can self control to high
localparam HS1        = 3'b010;

// M means middle, it is added because Write behavior needs 3 times HS.
localparam Set_HSM    = 3'b011; // set one of signal (ready or valid) that can self control to high
localparam HSM        = 3'b100; 

localparam Store_Data = 3'b101;
localparam Set_HS2    = 3'b110; // set one of signal (ready or valid) that can self control to high

// Read Behavior of Master 0 ================================

// stage register descirption
always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET) state_R_M0 <= 3'b0;
    else state_R_M0 <= nxt_state_R_M0;
end

// next state circuit description
always_comb begin
    case(state_R_M0)
        IDLE       : nxt_state_R_M0 = (I_req)? Set_HS1 : IDLE; 
        
        Set_HS1    : nxt_state_R_M0 = (ARREADY_M0)? HS1 : Set_HS1; // Set ARVALID_M0 to high
        
        HS1        : nxt_state_R_M0 = Store_Data; 
        
        Store_Data : nxt_state_R_M0 = Set_HS2;

        Set_HS2    :  begin
            if(RVALID_M0) nxt_state_R_M0 = (RLAST_M0)? IDLE : HS1;
            
            else          nxt_state_R_M0 = Set_HS2;
        end
        
        default    : nxt_state_R_M0 = IDLE;
        
    endcase
end 

// output signal description
assign ARVALID_M0 = (state_R_M0 == Set_HS1);
assign RREADY_M0 = (state_R_M0 == Set_HS2);

assign ARID_M0 = 4'b0;
assign ARLEN_M0 = 4'b0011; // burst: 4 beats
assign ARSIZE_M0 = 3'd2; // data size 4 bytes
assign ARBURST_M0 = `AXI_BURST_INC;

// stall PC for signal stablization while interact with slave 0 (InstMem)
logic PCstall_axi;
// assign PCstall_axi = !(RLAST_M0 && RVALID_M0 && RREADY_M0); // stall until Master 0 Read HS2 happended
assign PCstall_axi = core_wait_ic ;


// Read Behavior of Master 1 =================================

// to avoid second times hand-shaking in one turn

always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)DMOn_enable <= 1'b0;
	else
	begin
		if(!core_wait_ic) begin
			DMOn_enable <= 1'b1;
		end
		else if (!core_wait_dc || (BREADY_M1 && BVALID_M1)) begin
			DMOn_enable <= 1'b0;
		end
	end
end

// stage register descirption
always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)state_R_M1 <= 3'b00;
    else state_R_M1 <= nxt_state_R_M1;
end

// Means this insruction (Load / Store) needs to use Data Memory

assign DMOn = DMOn_cpu && DMOn_enable;

// next state circuit description
always_comb begin
    case(state_R_M1)
        IDLE       : nxt_state_R_M1 = (D_req && !D_write)? Set_HS1 : IDLE; 

        Set_HS1    : nxt_state_R_M1 = (ARREADY_M1)? HS1 : Set_HS1; // Set ARVALID_M1 to high

        HS1        : nxt_state_R_M1 = Store_Data; 

        Store_Data : nxt_state_R_M1 = Set_HS2;

        Set_HS2    :  begin
            if(RVALID_M1) nxt_state_R_M1 = (RLAST_M1)? IDLE : HS1;
            
            else          nxt_state_R_M1 = Set_HS2;
        end

        default    : nxt_state_R_M1 = IDLE;

    endcase
end 

// output signal description
assign ARVALID_M1 = (state_R_M1 == Set_HS1);
assign RREADY_M1 = (state_R_M1 == Set_HS2);

// Register for control signal and data, Due to the data mem addr is for read and write at the same time
logic [31:0] ARADDR_M1_reg;
logic [31:0] RDATA_M0_reg;
logic [31:0] RDATA_M1_reg;

always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)begin
        ARADDR_M1_reg <= 32'b0;
        RDATA_M0_reg <= 32'b0;
        RDATA_M1_reg <= 32'b0;
    end
    else begin
        if(D_req && !D_write) ARADDR_M1_reg <= D_addr;

        if(!core_wait_ic) RDATA_M0_reg <= core_out_ic;

        if(!core_wait_dc) RDATA_M1_reg <= core_out_dc;
    end
end

assign ARADDR_M1 = ARADDR_M1_reg;

assign ARID_M1 = 4'b0;
assign ARLEN_M1 = 4'b0011; // burst: 4 beat
assign ARSIZE_M1 = 3'd2; // data size 4 bytes
assign ARBURST_M1 = `AXI_BURST_INC;


// Write Behavior of Master 1 =================================

// stage register descirption
always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)state_W_M1 <= 3'b00;
    else state_W_M1 <= nxt_state_W_M1;
end

// next state circuit description
always_comb begin
    case(state_W_M1)
        IDLE     : nxt_state_W_M1 = (D_req && D_write)? Set_HS1 : IDLE; 
        
        Set_HS1  : nxt_state_W_M1 = (AWREADY_M1)? HS1 : Set_HS1; // Set AWVALID_M1, WVALID_M1 to high
        
        HS1      : nxt_state_W_M1 = Set_HSM; 

        Set_HSM  : nxt_state_W_M1 =  (WREADY_M1 && WLAST_M1)? HSM : Set_HSM;
        
        HSM      : nxt_state_W_M1 = Set_HS2; 
        
        Set_HS2  : nxt_state_W_M1 = (BVALID_M1)? IDLE : Set_HS2; // Set BREADY to high

        default   : nxt_state_W_M1 = IDLE;

    endcase
end

// Register for control signal and data, Due to the data mem addr is for read and write at the same time
logic [31:0] AWADDR_M1_reg;
logic [31:0] WDATA_M1_reg;
logic [3:0] WSTRB_M1_reg;
// added because this assetion: If Data before control is not allowed write data handshake should follow control

always_ff @(posedge ARESET or posedge ACLK ) begin
    if(ARESET)begin
        AWADDR_M1_reg <= 32'b0;
        WDATA_M1_reg <= 32'b0;
        WSTRB_M1_reg <= 4'b0;
    end
    else begin
        if(D_req && D_write) begin
            AWADDR_M1_reg <= D_addr;
            WDATA_M1_reg <= D_in;
            WSTRB_M1_reg <= ~MemRW_cpu;
            // for AXI write strobe 1111 means write whole 4 bytes.
            // for sram write enable 1111 means not allow writing.
        end
    end
end

assign AWADDR_M1 = AWADDR_M1_reg;
assign WDATA_M1  = WDATA_M1_reg;
assign WSTRB_M1  = WSTRB_M1_reg;

assign AWVALID_M1 = (state_W_M1 == Set_HS1);
assign WVALID_M1  = (state_W_M1 == Set_HSM);
assign BREADY_M1  = (state_W_M1 == Set_HS2);

assign AWID_M1 = 4'b0;
assign AWLEN_M1 = 4'b0;
assign AWSIZE_M1 = 3'd2;
assign AWBURST_M1 = `AXI_BURST_INC;
assign WLAST_M1 = 1'b1;

logic DMstall_axi;
assign DMstall_axi = core_wait_dc;

CPU m_cpu(
	.clk(ACLK),
	.rst(ARESET),

	// Master 0: send read request to Inst Mem (slave 0)
	.face_pc(ARADDR_M0),
	.face_inst(RDATA_M0_reg),

	// Master 1: send read/write request to Data Mem (slave 1)
    .face_ALUOut(ADDR_cpu),
	.face_Wdata(DATA_cpu),
	.face_MemRW(MemRW_cpu),
    .face_DMOn(DMOn_cpu),
	.face_Rdata(RDATA_M1_reg),

    // Modification signal due to AXI properties
    .PCstall_axi(PCstall_axi), // resolve monitor 0 stable issue of raddr
    .DMstall_axi(DMstall_axi)
);


assign I_wait = !(RREADY_M0 && RVALID_M0);

L1C_inst L1CI(
    .clk(ACLK),
    .rst(ARESET),

    // Core to CPU wrapper
    .core_addr(ARADDR_M0),
    .core_req(!DMOn),
    .core_write(1'b0), // always 0 for inst cache
    .core_in(32'b0), // No allow for write data in
    .core_type(3'b010), // always 3'b010 = CACHE_WORD

    // Mem to CPU wrapper
    .I_out(RDATA_M0), // Instruction from CPU wrapper <- AXI <- Inst Mem
    .I_wait(I_wait), // Used when Read Miss

    // CPU wrapper to core
    .core_out(core_out_ic),
    .core_wait(core_wait_ic), // longer than I_wait, We need to use spacial locality

    // CPU wrapper to Mem
    .I_req(I_req), // High when Read Miss
    .I_addr(I_addr),
    .I_write(), // always 0 for inst cache
    .I_in(), // always 0 for inst cache
    .I_type() // always 3'b010 = CACHE_WORD
);

logic write_dc;
logic[2:0] core_type_dc;

assign write_dc = (!(&MemRW_cpu)) && DMOn;
assign D_wait = !((!write_dc && RREADY_M1 && RVALID_M1 ) || 
                  ( write_dc && BREADY_M1 && BVALID_M1 ));

assign core_type_dc = (MemRW_cpu == 4'b1110)? `CACHE_BYTE  : 
                      (MemRW_cpu == 4'b1100)? `CACHE_HWORD :
                      (MemRW_cpu == 4'b0000)? `CACHE_WORD  : 3'b0;

L1C_data L1CD(
    .clk(ACLK),
    .rst(ARESET),

    // Core to CPU wrapper
    .core_addr(ADDR_cpu),
    .core_req(DMOn),
    .core_write(write_dc), // always 0 for inst cache
    .core_in(DATA_cpu), // No allow for write data in
    .core_type(core_type_dc), // always 3'b010 = CACHE_WORD

    // Mem to CPU wrapper
    .D_out(RDATA_M1), // Instruction from CPU wrapper <- AXI <- Inst Mem
    .D_wait(D_wait), // Used when Read Miss

    // CPU wrapper to core
    .core_out(core_out_dc),
    .core_wait(core_wait_dc), // longer than I_wait, We need to use spacial locality

    // CPU wrapper to Mem
    .D_req(D_req), // High when Read Miss, Write Hit/Miss
    .D_addr(D_addr),
    .D_write(D_write),
    .D_in(D_in), // always 0 for inst cache
    .D_type(D_type) // always 3'b010 = CACHE_WORD
);

endmodule