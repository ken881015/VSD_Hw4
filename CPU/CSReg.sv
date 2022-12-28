module CSReg(
    input clk,
    input rst,

    // Read
    input[11:0] addr,
    
    output logic [31:0] rdata,

    // for jumoing to ISR process
    output PC_isr,

    // Write
    input[31:0] wdata,
    input       wen,

    // for counting effective instruction
    input retire,

    // for sync with the frequency of AXI (time for handshake)
    input PCstall_axi,

    input nop,
    input wfi,
    input [31:0] pc,
    input mret,
    input ex_interrupt,
    input tm_interrupt
);

localparam A_Mstatus   = 12'h300; // 0
localparam A_Mie       = 12'h304; // 1
localparam A_Mtvec     = 12'h305; // 2 
localparam A_Mepc      = 12'h341; // 3
localparam A_Mip       = 12'h344; // 4
localparam A_Mcycle    = 12'hB00; // 5
localparam A_Minstret  = 12'hB02; // 6
localparam A_Mcycleh   = 12'hB80; // 7
localparam A_Minstreth = 12'hB82; // 8

// Mstatus
logic [1:0] MPP;
logic MPIE,MIE;

// Mtvec
logic [31:0] mtvec;
assign mtvec = 32'h0001_0000;

// Mip
logic MEIP, MTIP;
assign MEIP = 1'b0;
assign MTIP = 1'b0;

// Mie
logic MEIE, MTIE;

// Mepc
logic [31:0] mepc;

enum logic[1:0]{
    Wait_itrpt  = 2'd0,
    Taken_exipt = 2'd1,
    Taken_tmipt = 2'd2,
    ISR         = 2'd3 // Interrupt Service Routine
} state,nxt_state;


always_ff @(posedge clk) begin
    if(rst) begin
        state <= Wait_itrpt;
    end
    else begin
        if(!PCstall_axi) state <= nxt_state;
    end
end

always_comb begin
    case(state)
        Wait_itrpt : nxt_state = (MIE && MEIE && ex_interrupt)? Taken_exipt :
                                 (MIE && MTIE && tm_interrupt)? Taken_tmipt : Wait_itrpt; // Global Enable && Local Enable &&　interupt from sensor
        
        Taken_exipt: nxt_state = (!nop)? ISR : Taken_exipt;
        Taken_tmipt: nxt_state = (!nop)? ISR : Taken_tmipt;

        ISR: nxt_state = (mret)? Wait_itrpt : ISR;
    endcase
end

always_ff @(posedge clk) begin
    if(rst) begin
        MPP  <= 2'b0;
        MPIE <= 1'b0;
        MIE  <= 1'b0;
        MEIE <= 1'b0;
        MTIE <= 1'b0;
        mepc <= 32'b0;
    end
    else begin
        // // clock
        // {CSRegs[7],CSRegs[5]} <= {CSRegs[7],CSRegs[5]} + 64'b1;

        // // Instret
        // if(retire == 1'b1) begin
        //     {CSRegs[8],CSRegs[6]} <= {CSRegs[8],CSRegs[6]} + 64'd1;
        // end
        
        if(!PCstall_axi) begin
            if(state == Wait_itrpt) begin
                // Write due to interupt taken
                if(MIE && ((MEIE && ex_interrupt) || (MTIE && tm_interrupt))) begin
                    MPIE <= MIE;
                    MIE  <= 1'b0;
                    MPP  <= 2'b11;
                end
            end
            else if (state == Taken_exipt || state == Taken_tmipt) begin
                // Only Record the effective inst then jump to mtvec. 
                if(!nop) begin
                    mepc <= (wfi)? pc+32'd4 : pc;
                end
            end
            else if (state == ISR && mret) begin
                MPIE <= 1'b1;
                MIE  <= MPIE;
                MPP  <= 2'b11;
            end

            // Write by instruction
            if(wen)begin
                case(addr)
                    A_Mstatus  : begin
                        MPP <= wdata[12:11];
                        MPIE <= wdata[7];
                        MIE <= wdata[3];
                    end
                    A_Mie      : begin
                        MEIE <= wdata[11];
                        MTIE <= wdata[7];
                    end  
                    A_Mepc     : mepc <= wdata;
                endcase
            end

        end
    end
end

assign PC_isr = (state == Taken_exipt || state == Taken_tmipt) && (!nop);

always_comb begin
    if(state == Wait_itrpt) begin
        case(addr)
            A_Mstatus   : rdata = {19'b0,MPP,3'b0,MPIE,3'b0,MIE,3'b0};
            A_Mie       : rdata = {20'b0,MEIE,3'b0,MTIE,7'b0};
            A_Mtvec     : rdata = mtvec;
            A_Mepc      : rdata = mepc;
            A_Mip       : rdata = {20'b0,MEIP,3'b0,MTIP,7'b0};
            // A_Mcycle    : rdata = CSRegs[5];
            // A_Minstret  : rdata = CSRegs[6];
            // A_Mcycleh   : rdata = CSRegs[7];
            // A_Minstreth : rdata = CSRegs[8];
            default   : rdata = 32'b0;
        endcase
    end
    else if (state == Taken_exipt) begin
        rdata = mtvec;
    end
    else if (state == Taken_tmipt) begin
        rdata = mtvec;
    end
    else if (state == ISR) begin
        rdata = mepc;
    end
    else begin
        rdata = 32'b0;
    end
end

endmodule