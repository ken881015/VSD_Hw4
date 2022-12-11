module CSReg(
    input clk,
    input rst,
    input retire,
    input[11:0] addr,
    output logic [31:0] data,

    input PCstall_axi
);

logic[63:0] clock;
logic[63:0] Instret;

// Size: 4096 * 64 bits
logic[63:0] CSRegs[(1<<12)-1 :0];

always_ff @(posedge rst or posedge clk) begin
    if(rst) begin
        clock <= 64'b0;
        Instret <= 64'b0;
    end
    else begin
        clock <= clock + 64'd1;
        
        if(!PCstall_axi && retire == 1'b1) begin
            Instret <= Instret + 64'd1;
        end
    end
end

always_comb begin 
    case({addr[7],addr[1]})
        2'b11: data = Instret[32+:32];
        2'b01: data = Instret[0+:32];
        2'b10: data = clock[32+:32];
        2'b00: data = clock[0+:32];
    endcase
end

endmodule