module Rx_data_reg #(parameter width=8)(input clk,
input hard_rst,
input soft_rst,
input w_en,
input [2:0] bit_index,
input bit_val,
output reg [width-1 : 0] data_out
    );
	 
	always @(posedge clk, posedge hard_rst)begin
		if(hard_rst) begin
			data_out <= 'd0;
		end 
		else if(soft_rst)begin
			data_out <= 'd0;
		end
		else begin
			if(w_en)begin
				data_out [bit_index] <= bit_val;
			end
			else begin
				data_out <= data_out;
			end	
		end
	end


endmodule
