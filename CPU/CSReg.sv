module CSReg(
    input clk,
    input rst,

    // Read
    input[11:0] addr,
    output logic [31:0] rdata,

    // Write
    input[31:0] wdata,
    input       wen,

    input retire,
    input PCstall_axi,

    input wfi,
    input mret,
    input ex_interrupt
);

localparam WFI       = 12'h105;
localparam MRET      = 12'h302;

localparam Mstatus   = 12'h300; // 0
localparam Mie       = 12'h304; // 1
localparam Mtvec     = 12'h305; // 2 
localparam Mepc      = 12'h341; // 3
localparam Mip       = 12'h344; // 4
localparam Mcycle    = 12'hB00; // 5
localparam Minstret  = 12'hB02; // 6
localparam Mcycleh   = 12'hB80; // 7
localparam Minstreth = 12'hB82; // 8

// Mstatus
logic [1:0] MPP;
logic MPIE,MIE;

// Mtvec
logic [31:0] mtvec;
assign mtvec = 32'h0001_0000;

// Mip
logic MEIP, MTIP;

// Mie
logic MEIE, MTIE;

// Mepc
logic [31:0] mepc;

always_ff @(posedge rst or posedge clk) begin
    if(rst) begin
        MPP  <= 2'b0;
        MPIE <= 1'b0;
        MIE  <= 1'b0;
        MEIP <= 1'b0;
        MTIP <= 1'b0;
        MEIE <= 1'b0;
        MTIE <= 1'b0;
    end
    else begin
        // // clock
        // {CSRegs[7],CSRegs[5]} <= {CSRegs[7],CSRegs[5]} + 64'b1;

        // // Instret
        // if(retire == 1'b1) begin
        //     {CSRegs[8],CSRegs[6]} <= {CSRegs[8],CSRegs[6]} + 64'd1;
        // end
        
        if(ex_interrupt)begin
            if(!PCstall_axi)begin
                if((wen && addr == WFI)) begin
                    mepc <= wdata + 32'd4;
                end
                
                MPIE <= MIE;
                MIE <= 1'b0;
                MPP <= 2'b11;
            end
        end

        else begin
            // Write by instruction
            if(!PCstall_axi && (wen && addr != 12'd0))begin
                case(addr)
                    Mstatus  : begin
                        MPP <= wdata[12:11];
                        MPIE <= wdata[7];
                        MIE <= wdata[3];
                    end
                    Mie      : begin
                        MEIE <= wdata[11];
                        MTIE <= wdata[7];
                    end  
                    Mepc     : mepc <= wdata;
                    WFI      : mepc <= wdata;
                endcase
            end
        end
    end
end

always_comb begin
    case(addr)
        Mstatus   : rdata = {19'b0,MPP,3'b0,MPIE,3'b0,MIE,3'b0};
        Mie       : rdata = {20'b0,MEIE,3'b0,MTIE,7'b0};
        Mtvec     : rdata = mtvec;
        Mepc      : rdata = mepc;
        Mip       : rdata = {20'b0,MEIP,3'b0,MTIP,7'b0};
        // Mcycle    : rdata = CSRegs[5];
        // Minstret  : rdata = CSRegs[6];
        // Mcycleh   : rdata = CSRegs[7];
        // Minstreth : rdata = CSRegs[8];
        WFI       : rdata = mtvec;
        MRET      : rdata = mepc;

        default   : rdata = 32'b0;
    endcase
end

endmodule