module data_reg #(parameter width=8)(input clk,
input rst,
input w_en,
input [2:0] bit_index,
input bit_val,
output reg [width-1 : 0] data_out
    );
	 
	always @(posedge clk, posedge rst)begin
		if(rst) begin
			data_out <= 0;
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