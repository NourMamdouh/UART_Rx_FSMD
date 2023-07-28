module Rx_controller_fsm #(parameter parity_on='d1, parameter data_size='d8, parameter sampling_cntr_width='d4,
parameter no_of_samples='d16,parameter even_parity='d1)(
input clk,
input rst, 
input Rx,
input [sampling_cntr_width-1:0] sampling_cntr_out,
input [2 : 0] bits_cntr_out,
input [data_size-1 : 0] Rx_reg,
output reg cntr_rst,
output reg data_flag_rst,
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
	 	 
	 if(parity_on=='d1)begin
		`define P_on
	 end
	 
	 `ifdef P_on
		wire parity = even_parity? ^Rx_reg : !(^Rx_reg) ;
		parameter state_reg_width = 'd3;
	 `else
		parameter state_reg_width = 'd2;
	`endif
	 
	 parameter [state_reg_width-1 : 0] idle='d0, start='d1, Read='d2, parity_ckeck='d4,stop='d3;
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
	
		cntr_rst='d0;
		data_flag_rst = 'd0;
		sampling_end_val='d0;
		data_bits_incr='d0;
		data_w_en='d0;
		trans_err_en='d0; 
		data_err_en='d0; 
		frame_done_en='d0;
		trans_error='d0;
		data_error='d0;
		frame_done='d0;
		next_state =idle;
		case(state)
			idle:begin
				cntr_rst = 'd1;			
				if(Rx==0)begin
					next_state = start;
				end
				else begin
					next_state = idle;
				end
			end
			start:begin
				sampling_end_val = (no_of_samples/2)-1;
				
				if(sampling_cntr_out == sampling_end_val) begin
					if(Rx==0)begin
						next_state = Read;
						data_flag_rst = 'd1;
					end
					else begin
						next_state = idle;
					end
				end
				else begin
					next_state = start;
				end		
			end
			Read:begin
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
			stop:begin
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
			`ifdef P_on
				parity_ckeck:begin
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
			`endif
			default:begin
				next_state = idle;
			end
		endcase
		
	end


endmodule

