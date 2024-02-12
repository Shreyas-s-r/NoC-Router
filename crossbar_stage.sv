
`timescale 1ns/1ps

module crossbar_stage(preset,switch_sel,chs_in_f,chs_in_b,latches_out_f,latches_out_b);

	
import interact::*;

	input preset;
	input switch_sel_t switch_sel;
	
	input chs_f chs_in_f;
	output chs_b chs_in_b;
	
	output chs_f latches_out_f;
	input chs_b latches_out_b;

	 chs_f latches_in_f;
	 chs_b latches_in_b;

	crossbar cross_bar (.chs_in_f(chs_in_f),.preset(preset),.switch_sel(switch_sel),.chs_in_b(chs_in_b),
	.chs_out_b(latches_in_b),.chs_out_f(latches_in_f));

	genvar i;
	generate

	for ( i = ( ARITY - 1 ) ; ( i >= 0 ) ; i = ( i - 1 ) )
	begin : latches

		
		channel_forward left_in;
		channel_backward left_out;
		channel_forward right_out;
		channel_backward right_in;

		assign left_in = latches_in_f[i];
		assign latches_in_b[i] = left_out;
		assign right_in = latches_out_b[i];
		assign latches_out_f[i] = right_out;

		channel_latch #(.init_token(EMPTY_TOKEN),.init_data({ 1'b0 }),.GENERATE_REQUEST_DELAY (link_req_delay)) 
		ch_latch (
		.preset(preset),
		.left_in(left_in),
		.left_out(left_out),
		.lt_enable( ),
		.right_in(right_in),
		.right_out(right_out)  );
	end
	
	endgenerate

endmodule