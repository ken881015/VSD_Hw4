module WDT(
  input clk,
  input rst,
  input clk2, //10MHz
  input rst2,

  input WDEN,
  input WDLIVE,
  input [31:0] WTOCNT,

  output logic WTO
);

logic [31:0] counter;
logic WTO_s1;
logic WTO_s2;

always_ff@(posedge clk2 or posedge rst or posedge rst2) begin
	if(rst || rst2) begin
		counter <= 32'b0;
		WTO_s1 <= 1'b0;
	end
	else begin
		if(WDEN) begin
			if(WDLIVE) begin
				counter <= 32'b0;
				WTO_s1 <= 1'b0;
			end
			else if(counter > WTOCNT) begin
				counter <= counter;
				WTO_s1 <= 1'b1;
			end
			else begin
				counter <= counter + 32'b1;
				WTO_s1 <= 1'b0;
			end
		end
		else begin
			counter <= 32'b0;
			WTO_s1 <= 1'b0;
		end
	end
end

always_ff@(posedge clk or posedge rst or posedge rst2) begin
	if(rst || rst2) begin
		WTO_s2 <= 1'b0;
	end
	else begin
		WTO_s2 <= WTO_s1;
	end
end

always_ff@(posedge clk or posedge rst or posedge rst2) begin
	if(rst || rst2) begin
		WTO <= 1'b0;
	end
	else begin
		WTO <= WTO_s2;
	end
end

endmodule
