module UART_top_Rx #(parameter data_size=8,
parameter parity_on=1, 
parameter even_parity=1,
parameter no_of_samples=16,
parameter sampling_cntr_width=4,
parameter BAUD_RATE=1000,
parameter SYS_CLK_FREQ=no_of_samples*1000)(input sys_clk,
input rst,
input Rx,
output trans_error,
output data_error,
output frame_done,
output [data_size-1 : 0] data_out
    );
	 
	 wire cntr_rst,data_flag_rst;
	 wire [sampling_cntr_width-1:0] sampling_end_val;
	 wire data_bits_incr, data_w_en, trans_error_in, data_error_in,frame_done_in;
	 wire [sampling_cntr_width-1:0] sampling_cntr_out;
	 wire [2:0] bits_cntr_out;
	 wire trans_err_en,data_err_en,frame_done_en;

	 
	 Rx_data_path #(.parity_on(parity_on),.data_size(data_size),.sampling_cntr_width(sampling_cntr_width))UART_Rx_DataPath(
    .clk(sys_clk), 
    .rst(rst), 
    .cntr_rst(cntr_rst),
	 .data_flag_rst(data_flag_rst), 
    .sampling_end_val(sampling_end_val), 
    .data_bits_incr(data_bits_incr), 
    .data_w_en(data_w_en),
	 .trans_err_en(trans_err_en),
	 .data_err_en(data_err_en),
	 .frame_done_en(frame_done_en),
    .trans_error_in(trans_error_in), 
    .data_err_in(data_error_in), 
    .frame_done_in(frame_done_in), 
    .Rx(Rx), 
    .sampling_cntr_out(sampling_cntr_out), 
    .bits_cntr_out(bits_cntr_out), 
    .trans_error(trans_error), 
    .data_error(data_error), 
    .frame_done(frame_done), 
    .Rx_out(data_out)
    );
	 
	 Rx_controller_fsm #(.parity_on(parity_on), .data_size(data_size),.sampling_cntr_width(sampling_cntr_width),.even_parity(even_parity),
	 .no_of_samples(no_of_samples))UART_Rx_Controller (
    .clk(sys_clk), 
    .rst(rst), 
    .Rx(Rx), 
    .sampling_cntr_out(sampling_cntr_out), 
    .bits_cntr_out(bits_cntr_out), 
    .Rx_reg(data_out), 
    .cntr_rst(cntr_rst), 
	 .data_flag_rst(data_flag_rst),
    .sampling_end_val(sampling_end_val), 
    .data_bits_incr(data_bits_incr), 
    .data_w_en(data_w_en),
	 .trans_err_en(trans_err_en),
	 .data_err_en(data_err_en),
	 .frame_done_en(frame_done_en),	 
    .trans_error(trans_error_in), 
    .data_error(data_error_in), 
    .frame_done(frame_done_in)
    );


endmodule
