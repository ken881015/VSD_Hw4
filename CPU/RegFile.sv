module RegFile(
    input clk,
    input rst,

    input wen,
    input[4:0] wa, input[31:0] wd,

    input[4:0] r1a, output logic [31:0] r1d,
    input[4:0] r2a, output logic [31:0] r2d,

    input PCstall_axi
);

logic[31:0] regs[31:0];

// forwarding for write back data be used by future instruction.
assign r1d = regs[r1a];
assign r2d = regs[r2a];

/*
always_comb begin
    
    if (r1a == 5'b0) r1d = 32'b0;
    else begin
        if(wen == 1'b1 && wa == r1a) r1d = wd;
        else r1d = regs[r1a];
    end

    if (r2a == 5'b0) r2d = 32'b0;
    else begin
        if(wen == 1'b1 && wa == r2a) r2d = wd;
        else r2d = regs[r2a];
    end
end
*/

always_ff @(posedge clk) begin
    if(rst) begin
        foreach(regs[i]) begin
            regs[i] <= 32'b0;
        end
    end
    else begin
        if(!PCstall_axi && (wen && wa != 5'd0))begin
            regs[wa] <= wd;
        end
    end
end

endmodule
