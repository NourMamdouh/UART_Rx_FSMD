module flag_reg(input clk,
input rst,
input w_en,
input data_in,
output reg data_out
    );
	 
	 always @(posedge clk, posedge rst) begin
		if(rst) begin
			data_out <= 0;
		end
		else begin
			if(w_en) data_out <= data_in; else data_out <= data_out;
		end
	 end

endmodule