module Rx_data_path #(parameter parity_on=1, parameter data_size=8, sampling_cntr_width=4)(input clk,
////// control signals from fsm ////////
input rst, 
input [sampling_cntr_width-1 :0] sampling_end_val, // counter value at which a sample should be taken
input cntr_rst,
input data_flag_rst,
input data_bits_incr, //to enable counter increment after each sample of data is taken 
input data_w_en, // to enable storing sample bit 
input trans_err_en, 
input data_err_en,
input frame_done_en,
input trans_error_in,
input data_err_in,
input frame_done_in,
input Rx,
/////// fsm inputs //////////
output [sampling_cntr_width-1:0] sampling_cntr_out,
output [2: 0] bits_cntr_out,
output trans_error, //detects transmission error (error in stop bit)
output data_error,  // detects data error (in case parity is used)
output frame_done, // indicates that frame processing is done
output [data_size-1 : 0] Rx_out
    );
	 
	 // to count till a specific number of clock cycles is reached to take a sample
	 counter #(.width(sampling_cntr_width)) sampling_cntr (
    .clk(clk), 
	 .hard_rst(rst),
    .soft_rst(cntr_rst), 
    .end_val(sampling_end_val), 
    .cnt_out(sampling_cntr_out)
    );
	 
	 
	 // to keep track of data bits to be stored
	 manual_cntr #(.width(3)) data_bits_cntr (
    .clk(clk), 
	 .hard_rst(rst),
    .soft_rst(cntr_rst),             
    .incr(data_bits_incr), 
    .cnt_out(bits_cntr_out)
    );
	 
	 // to store recieved data
	 Rx_data_reg #(.width(data_size)) Rx_reg (
    .clk(clk), 
	 .hard_rst(rst),
    .soft_rst(data_flag_rst), 
    .w_en(data_w_en), 
    .bit_index(bits_cntr_out), 
    .bit_val(Rx), 
    .data_out(Rx_out)
    );
	 
	 
	 // indicates that frame processing is done
	 flag_reg done_flag (
    .clk(clk), 
	 .hard_rst(rst),
    .soft_rst(data_flag_rst),
	 .w_en(frame_done_en),
    .data_in(frame_done_in), 
    .data_out(frame_done)
    );
	 
	 //detects transmission error (error in stop bit)
	 flag_reg trans_err_flag (
	.clk(clk), 
	.hard_rst(rst),
   .soft_rst(data_flag_rst),
	.w_en(trans_err_en),
	.data_in(trans_error_in), 
	.data_out(trans_error)
	);
	 
	 // detects data error (in case parity is used)
	 if(parity_on) begin
			flag_reg data_err_flag (
			.clk(clk), 
			.hard_rst(rst),
			.soft_rst(data_flag_rst),
			.w_en(data_err_en), 
			.data_in(data_err_in), 
			.data_out(data_error)
			);
	 end


endmodule