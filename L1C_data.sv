//================================================
// Auther:      Chen Yun-Ru (May)
// Filename:    L1C_data.sv
// Description: L1 Cache for data
// Version:     0.1
//================================================
`include "../include/def.svh"

module L1C_data(
    input clk,
    input rst,
    // Core to CPU wrapper
    input [`DATA_BITS-1:0] core_addr,
    input core_req,
    input core_write,
    input [`DATA_BITS-1:0] core_in,
    input [`CACHE_TYPE_BITS-1:0] core_type,
    // Mem to CPU wrapper
    input [`DATA_BITS-1:0] D_out,
    input D_wait,
    // CPU wrapper to core
    output logic [`DATA_BITS-1:0] core_out,
    output core_wait,
    // CPU wrapper to Mem
    output logic D_req,
    output logic [`DATA_BITS-1:0] D_addr,
    output D_write,
    output [`DATA_BITS-1:0] D_in,
    output [`CACHE_TYPE_BITS-1:0] D_type
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
    logic[2:0] state, nxt_state;
    
    assign DA_read = 1'b1;
    assign TA_read = 1'b1;

    localparam Idle        = 3'd0;
    localparam Judge_R     = 3'd1; 
    localparam ReadMiss    = 3'd2; // read a line from memory
    localparam Uncacheable = 3'd3;
    localparam Judge_W     = 3'd4; 
    localparam WriteHit    = 3'd5; // write data into cache and memory
    localparam WriteMiss   = 3'd6; // only write data into memory

    // instant for data accessing
    assign index = core_addr[9:4];

    logic [1:0] offset;
    logic TA_match;
    logic cacheable;

    assign TA_in  = core_addr [31:10];
    assign offset = core_addr [3:2];
    assign TA_match = (TA_in == TA_out);
    assign cacheable = core_addr [31:10] != 22'h040000;
    
    //Read  
    always_ff @( posedge clk or posedge rst) begin
        if(rst)state <= 3'b0;
        else state <= nxt_state;
    end

    
    // comb circuit for nxt_state_R 
    always_comb begin
        case(state)
            Idle : nxt_state = (core_req)? ((core_write)? Judge_W : Judge_R) : Idle;
            
            Judge_R : nxt_state = (TA_match && valid[index])?  Idle : ReadMiss; // TA_out is obtaion by core_addr in Idle

            ReadMiss : begin
                if(cacheable) begin
                    nxt_state = (counter == 2'b11 && !D_wait)? Judge_R : ReadMiss;
                end
                else begin
                    nxt_state = Uncacheable;
                end
            end

            Uncacheable : nxt_state = (!D_wait)? Idle : Uncacheable;

            Judge_W : nxt_state = (TA_match && valid[index])?  WriteHit : WriteMiss;

            WriteHit : nxt_state = (!D_wait)? Idle : WriteHit;

            WriteMiss : nxt_state = (!D_wait)? Idle : WriteMiss;

            default : nxt_state = Idle;
        endcase
    end

    // T: total, M: miss, H: hit
    logic [31:0] RTCnt,RMCnt, WHCnt, WMCnt;
    always_ff @( posedge clk or posedge rst) begin
        if(rst)begin
            RTCnt <= 32'b0;
            RMCnt <= 32'b0;
            WHCnt <= 32'b0;
            WMCnt <= 32'b0;
        end
        else begin
            // Read
            if(state == Judge_R) begin
                if(valid[index] && (TA_match)) begin
                    RTCnt <= RTCnt + 32'b1;
                end
                else begin
                    RMCnt <= RMCnt + 32'b1;
                end
            end
            
            // Write
            if(state == Judge_W) begin
                if(valid[index] && (TA_match)) begin
                    WHCnt <= WHCnt + 32'b1;
                end
                else begin
                    WMCnt <= WMCnt + 32'b1;
                end
            end
        end
    end

    logic Hit, Miss;
    assign Hit = (state == Judge_R || state == Judge_W) && valid[index] && (TA_match);
    assign Miss = (state == Judge_R || state == Judge_W) && !(valid[index] && (TA_match));

    
    always_comb begin
        // core_wait and core_out when Read Hit
        if ((state == Judge_R && (TA_match && valid[index]))) begin
            case(offset)
                2'b00 : core_out = DA_out[31:0];
                2'b01 : core_out = DA_out[63:32];
                2'b10 : core_out = DA_out[95:64];
                2'b11 : core_out = DA_out[127:96];
            endcase
        end
        else if(state == Uncacheable && !D_wait) begin
            core_out = D_out;
        end
        else begin
            core_out = 32'b0;
        end
    end

    assign core_wait = ((state==Judge_R) && (TA_match && valid[index])) || (state == Uncacheable && !D_wait)? 1'b0 : 1'b1;
    assign D_req = (state == ReadMiss || state == WriteMiss || state == WriteHit)? 1'b1 : 1'b0;
	assign D_addr = (state == ReadMiss || state == WriteMiss || state == WriteHit)? core_addr : 32'b0;
    
    always_ff @( posedge clk or posedge rst) begin
        if(rst) begin
            counter <= 2'b0;
            valid <= 64'b0;
        end
        else begin
            if(state == ReadMiss) begin
                counter <= (!D_wait)? counter + 2'b1 : counter;
            end
            else begin
                counter <= 2'b0;
            end

            if(state == ReadMiss && !D_wait && counter == 2'b11) begin
                valid[index] <= 1'b1;
            end
        end
    end
	
    assign D_write = (state == WriteHit || state == WriteMiss)? 1'b1 : 1'b0; 
    assign D_in = (state == WriteHit || state == WriteMiss)? core_in : 32'b0; 
    assign D_type = core_type; 
	
    logic[3:0] data_type, data_type_shf;
    logic[31:0] core_in_shf;

    assign data_type = (core_type == `CACHE_BYTE) ? 4'b1110:
                       (core_type == `CACHE_HWORD)? 4'b1100: 4'b0000;

    
    always_comb begin
        case(core_addr[1:0])
            // left
            2'd0: begin
                data_type_shf = data_type;
                core_in_shf = core_in;
            end
            2'd1: begin
                data_type_shf = {data_type[2:0],data_type[3]};
                core_in_shf = {core_in[23:0],core_in[31:24]};
            end
            2'd2: begin
                data_type_shf = {data_type[1:0],data_type[3:2]};
                core_in_shf = {core_in[15:0],core_in[31:16]};
            end
            2'd3: begin
                data_type_shf = {data_type[0],data_type[3:1]};
                core_in_shf = {core_in[7:0],core_in[31:8]};
            end
        endcase
    end

    always_comb begin
        if(state == ReadMiss && !D_wait) begin
            case(counter)
                2'b00:begin
                    DA_in = {96'b0,D_out};
                    DA_write = {16'hFFF0};
                end
                2'b01:begin
                    DA_in = {64'b0,D_out,32'b0};
                    DA_write = {16'hFF0F};
                end
                2'b10:begin
                    DA_in = {32'b0,D_out,64'b0};
                    DA_write = {16'hF0FF};
                end
                2'b11:begin
                    DA_in = {D_out,96'b0};
                    DA_write = {16'h0FFF};
                end
            endcase

            TA_write = 1'b0;
        end

        else if(state == WriteHit) begin
            case(offset)
                2'b00:begin
                    DA_in = {96'b0,core_in_shf};
                    DA_write = {12'hFFF,data_type_shf};
                end
                2'b01:begin
                    DA_in = {64'b0,core_in_shf,32'b0};
                    DA_write = {8'hFF, data_type_shf, 4'hF};
                end
                2'b10:begin
                    DA_in = {32'b0,core_in_shf,64'b0};
                    DA_write = {4'hF, data_type_shf, 8'hFF};
                end
                2'b11:begin
                    DA_in = {core_in_shf,96'b0};
                    DA_write = {data_type_shf,12'hFFF};
                end
            endcase
            TA_write = 1'b1;
        end

        else begin
            DA_in = 128'b0;
            DA_write = 16'hFFFF;
            TA_write = 1'b1;
        end
    end
endmodule

