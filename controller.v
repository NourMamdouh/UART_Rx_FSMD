module controller_fsm #(parameter parity_on=1, parameter data_size=8, parameter sampling_cntr_width=4,
parameter no_of_samples=16,parameter even_parity=1)(
input clk,
input rst, 
input Rx,
input [sampling_cntr_width-1:0] sampling_cntr_out,
input [2 : 0] bits_cntr_out,
input [data_size-1 : 0] Rx_reg,
output reg global_rst, //for flag registers and Rx register
output reg cntr_rst,
output reg [sampling_cntr_width-1 :0] sampling_end_val,
output reg data_bits_incr,
output reg data_w_en,
output reg trans_err_en,
output reg data_err_en,
output reg frame_done_en,     
output reg trans_error,
output reg data_error,
output reg frame_done
    );
	 
	 ///////////////////// state parameters ////////////////////////
	 wire parity;
	 
	 generate 
	 if(parity_on) begin
		assign parity = even_parity? ^Rx_reg : !(^Rx_reg) ;
	 end
	 endgenerate
	 
	 parameter state_reg_width= parity_on?3:2;
	 
	 parameter [state_reg_width-1 : 0] idle=0, start=1, Read=2, parity_ckeck=4,stop=3;
	 reg [state_reg_width-1 : 0] next_state, state ;
	
   //////////////////////// state register /////////////////
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			state <= idle;
		end
		else begin
			state <= next_state;
		end
	end
	
	///////////////////// nextt state and output logic ////////////////////
	always @(*)begin
		global_rst=0;
		cntr_rst=0;
		sampling_end_val=0;
		data_bits_incr=0;
		data_w_en=0;
		trans_err_en=0; 
		data_err_en=0; 
		frame_done_en=0;
		trans_error=0;
		data_error=0;
		frame_done=0;
		next_state =idle;
		
		if(state==idle)begin
			cntr_rst = 1;
			
			if(Rx==0)begin
				next_state = start;
			end
			else begin
				next_state = idle;
			end
		end
		
		if(state == start)begin
			sampling_end_val = (no_of_samples/2)-1;
			
			if(sampling_cntr_out == sampling_end_val) begin
				if(Rx==0)begin
					next_state = Read;
					global_rst = 1;
					
				end
				else begin
					next_state = idle;
				end
			end
			else begin
				next_state = start;
			end		
		end
		
		if(state == Read) begin
			sampling_end_val =no_of_samples-1;
			
			if(sampling_cntr_out == sampling_end_val) begin
				data_bits_incr =1;
				data_w_en =1;				
				if(bits_cntr_out == data_size-1) begin
					if(parity_on) next_state=parity_ckeck; else next_state=stop;
				end
				else begin
					next_state=Read;
				end
			end
			else begin
				next_state=Read;
				data_bits_incr=0;
				data_w_en =0;
			end
		end
		
		if(state == stop)begin
			sampling_end_val=no_of_samples-1;
			if(sampling_cntr_out ==sampling_end_val) begin
				if(Rx==1) trans_error=0; else trans_error=1;
				frame_done = 1;
				trans_err_en=1; 
				frame_done_en=1;
				next_state = idle;
			end
			else begin
				next_state = stop;
			end
		end
		
		if(parity_on)begin
			if(state == parity_ckeck)begin
				sampling_end_val= no_of_samples-1;
				if(sampling_cntr_out ==sampling_end_val) begin
					if(parity == Rx) data_error = 0; else data_error=1;
					next_state = stop;
					data_err_en=1;
				end
				else begin
					next_state = parity_ckeck;
				end
			end	
		end
		
		
	end


endmodule
