module flag_reg(input clk,
input hard_rst,
input soft_rst,
input w_en,
input data_in,
output reg data_out
    );
	 
	 always @(posedge clk, posedge hard_rst) begin
		if(hard_rst) begin
			data_out <= 'd0;
		end
		else if(soft_rst)begin
			data_out <= 'd0;
		end
		else begin
			if(w_en) data_out <= data_in; else data_out <= data_out;
		end
	 end

endmodule