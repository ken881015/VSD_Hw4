module CSReg(
    input clk,
    input rst,

    // Read
    input[11:0] raddr,
    output logic [31:0] rdata,

    // Write
    input[11:0] waddr,
    input[31:0] wdata,
    input       wen,

    input retire,
    input PCstall_axi
);

localparam Cycle_H   = 12'hC80;
localparam Cycle_L   = 12'hC00;
localparam Instret_H = 12'hC82;
localparam Instret_L = 12'hC02;

localparam Mstatus   = 12'h300;
localparam Mie       = 12'h304;
localparam Mtvec     = 12'h305;
localparam Mepc      = 12'h341;
localparam Mip       = 12'h344;
localparam Mcycle    = 12'hB00;
localparam Minstret  = 12'hB02;
localparam Mcycleh   = 12'hB80;
localparam Minstreth = 12'hB82;

// Hardwired...
localparam Mstatus_mask = 32'h00001888;
localparam Mtvec_mask   = 32'h00010000;
localparam Mip_mask     = 32'h00000880;


// Size: 4096 * 32 bits
logic[31:0] CSRegs[(1<<12)-1 :0];

logic[31:0] wstrb;
assign wstrb = {{16{!waddr[11]}},{16{!waddr[10]}}};

always_ff @(posedge rst or posedge clk) begin
    if(rst) begin
        foreach(CSRegs[i])begin
            CSRegs[i] <= 32'b0;
        end
    end
    else begin
        // clock
        {CSRegs[Cycle_H],CSRegs[Cycle_L]} <= {CSRegs[Cycle_H],CSRegs[Cycle_L]} + 64'b1;

        // Instret
        if(retire == 1'b1) begin
            {CSRegs[Instret_H],CSRegs[Instret_L]} <= {CSRegs[Instret_H],CSRegs[Instret_L]} + 64'd1;
        end
        
        if(!PCstall_axi && (wen && waddr != 12'd0))begin
            CSRegs[waddr] <= wdata & wstrb;
        end
    end
end

always_comb begin
    if(raddr == Mstatus) begin
        rdata = CSRegs[Mstatus] & Mstatus_mask;
    end
    else if(raddr == Mtvec) begin
        rdata = Mtvec_mask;
    end
    // why??
    else if(raddr == Mip) begin
        rdata = CSRegs[Mip] & CSRegs[Mie] & Mip_mask;
    end
    else if(raddr == Mie) begin
        rdata = CSRegs[Mie] & Mip_mask;
    end
    else begin
        rdata = CSRegs[raddr];
    end
end

endmodule