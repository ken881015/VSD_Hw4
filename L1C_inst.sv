//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_inst.sv
// Description: L1 Cache for instruction
// Version:     0.1
//================================================
`include "../include/def.svh"

module L1C_inst(
    input clk,
    input rst,

    // Core to CPU wrapper
    input [`DATA_BITS-1:0] core_addr,
    input core_req, // always 1
    input core_write, // always 0 for inst cache
    input [`DATA_BITS-1:0] core_in, // No allow for write data in
    input [`CACHE_TYPE_BITS-1:0] core_type, // always 3'b010 = CACHE_WORD

    // Mem to CPU wrapper
    input [`DATA_BITS-1:0] I_out, // Instruction from CPU wrapper <- AXI <- Inst Mem
    input I_wait, // Used when Read Miss

    // CPU wrapper to core
    output logic [`DATA_BITS-1:0] core_out,
    output logic core_wait, // longer than I_wait, We need to use spacial locality

    // CPU wrapper to Mem
    output logic I_req, // High when read Miss
    output logic [`DATA_BITS-1:0] I_addr,
    output logic I_write, // always 0 for inst cache
    output logic [`DATA_BITS-1:0] I_in, // always 0 for inst cache
    output logic [`CACHE_TYPE_BITS-1:0] I_type // always 3'b010 = CACHE_WORD
);

    logic [`CACHE_INDEX_BITS-1:0] index;
    logic [`CACHE_DATA_BITS-1:0] DA_out;
    logic [`CACHE_DATA_BITS-1:0] DA_in;
    logic [`CACHE_WRITE_BITS-1:0] DA_write;
    logic DA_read;
    logic [`CACHE_TAG_BITS-1:0] TA_out;
    logic [`CACHE_TAG_BITS-1:0] TA_in;
    logic TA_write;
    logic TA_read;
    logic [`CACHE_LINES-1:0] valid;

    //--------------- complete this part by yourself -----------------//

    data_array_wrapper DA(
        .A(index),
        .DO(DA_out),
        .DI(DA_in),
        .CK(clk),
        .WEB(DA_write),
        .OE(DA_read),
        .CS(1'b1)
    );
    
    tag_array_wrapper  TA(
        .A(index),
        .DO(TA_out),
        .DI(TA_in),
        .CK(clk),
        .WEB(TA_write),
        .OE(TA_read),
        .CS(1'b1)
    );

    logic [1:0] counter;
    logic [1:0] state, nxt_state;
    
    assign DA_read = 1'b1;
    assign TA_read = 1'b1;
    
    localparam Idle      = 2'b00;
    localparam Judge     = 2'b01; 
    localparam ReadMiss  = 2'b10; // read a line from memory

    // instant for data accessing
    assign index = core_addr[9:4];

    logic[1:0]  offset;
    logic TA_match;

    assign TA_in  = core_addr [31:10];
    assign offset = core_addr [3:2];
    assign TA_match = (TA_in == TA_out);

    always_ff @( posedge clk) begin
        if(rst)state <= 2'b0;
        else state <= nxt_state;
    end

    // comb circuit for nxt_state 
    always_comb begin
        case(state)
            Idle : nxt_state = (core_req)? Judge : Idle;
            
            Judge : nxt_state = (valid[index])? ((TA_match)? Idle : ReadMiss) : ReadMiss;

            ReadMiss : nxt_state = (counter == 2'b11 && !I_wait)? Judge : ReadMiss;
            
            default : nxt_state = Idle;
        endcase
    end

    logic Hit, Miss;
    assign Hit = (state == Judge) && valid[index] && (TA_match);
    assign Miss = (state == Judge) && !(valid[index] && (TA_match));

    // T: total, M: miss, H: hit
    logic [31:0] RTCnt,RMCnt;
    always_ff @( posedge clk) begin
        if(rst)begin
            RTCnt <= 32'b0;
            RMCnt <= 32'b0;
        end
        else begin
            // Read
            if(state == Judge) begin
                if(valid[index] && (TA_match)) begin
                    RTCnt <= RTCnt + 32'b1;
                end
                else begin
                    RMCnt <= RMCnt + 32'b1;
                end
            end
        end
    end

    always_comb begin
        // core_wait and core_out when Read Hit
        if ((state == Judge && (valid[index]))) begin
            if(TA_match) begin
                case(offset)
                    2'b00 : core_out = DA_out[31:0];
                    2'b01 : core_out = DA_out[63:32];
                    2'b10 : core_out = DA_out[95:64];
                    2'b11 : core_out = DA_out[127:96];
                endcase
            end
            else begin
                core_out = 32'b0;
            end
        end
        else begin
            core_out = 32'b0;
        end
    end

    assign core_wait = (state == Judge && valid[index])? ((TA_match)? 1'b0 : 1'b1) : 1'b1;
    assign I_req = (state == ReadMiss)? 1'b1 : 1'b0;
    assign I_addr = (state == ReadMiss)? core_addr : 32'b0;

    always_ff @( posedge clk) begin
        if(rst) begin
            counter <= 2'b0;

            valid <= 64'b0;
        end
        else begin
            if(state == ReadMiss) begin
                counter <= (!I_wait)? counter + 2'b1 : counter;
            end
            else begin
                counter <= 2'b0;
            end
            
            if(state == ReadMiss && !I_wait && counter == 2'b11) begin
                valid[index] <= 1'b1;
            end
        end
    end

    assign I_write = 1'b0; // always 0 cuz CPU won't write Inst SRAM
    assign I_in = 32'b0; // always 0 cuz CPU won't write Inst SRAM
    assign I_type = 3'b010; // always 3'b010 = CACHE_WORD

    always_comb begin
        if(!I_wait) begin
            case(counter)
                2'b00:begin
                    DA_in = {96'b0,I_out};
                    DA_write = {16'hFFF0};
                end
                2'b01:begin
                    DA_in = {64'b0,I_out,32'b0};
                    DA_write = {16'hFF0F};
                end
                2'b10:begin
                    DA_in = {32'b0,I_out,64'b0};
                    DA_write = {16'hF0FF};
                end
                2'b11:begin
                    DA_in = {I_out,96'b0};
                    DA_write = {16'h0FFF};
                end
            endcase

            TA_write = 1'b0;
        end
        else begin
            DA_in = 128'b0;
            DA_write = 16'hFFFF;
            TA_write = 1'b1;
        end
    end

endmodule