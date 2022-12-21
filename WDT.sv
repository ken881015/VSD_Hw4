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

//watchdog timer
logic [31:0] cnt;

always_ff@(posedge clk2) begin
	if(rst2) begin
    cnt <= 32'b0;
    WTO <= 1'b0;
  end

	else begin
		if(WDEN) begin
			if(WDLIVE) cnt <= 32'b0;
			else cnt <= (cnt == WTOCNT)? cnt : cnt + 32'b1;

      WTO <= (cnt == WTOCNT);
		end
		else begin
      cnt <= 32'b0;
      WTO <= 1'b0;
    end
	end
end

endmodule
