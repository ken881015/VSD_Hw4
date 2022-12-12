module CSReg(
    input clk,
    input rst,
    input retire,
    input[11:0] addr,
    output logic [31:0] data,

    input PCstall_axi
);

// Size: 4096 * 32 bits
logic[31:0] CSRegs[(1<<12)-1 :0];

always_ff @(posedge rst or posedge clk) begin
    if(rst) begin
        foreach(CSRegs[i])begin
            CSRegs[i] <= 32'b0;
        end
    end
    else begin
        // clock
        {CSRegs[12'hC80],CSRegs[12'hC00]} <= {CSRegs[12'hC80],CSRegs[12'hC00]} + 64'b1;

        // Instret
        if(retire == 1'b1) begin
            {CSRegs[12'hC82],CSRegs[12'hC02]} <= {CSRegs[12'hC82],CSRegs[12'hC02]} + 64'd1;
        end
    end
end

assign data = CSRegs[addr];

endmodule