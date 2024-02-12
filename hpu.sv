`timescale 1ns/1ps

module hpu 
#(	parameter IS_NI  , parameter [1:0] THIS_PORT  )
                 //false
(preset,chan_in_f,chan_in_b,chan_out_f,chan_out_b,sel);

	import interact::*;

	input reg preset;

	input channel_forward chan_in_f; 
	output channel_backward  chan_in_b;

	output channel_forward chan_out_f;
	input channel_backward chan_out_b;

	output onehot_sel sel;

	 channel_forward chan_internal_f ;
	 channel_backward chan_internal_b ;
	 
	 onehot_sel sel_internal;

	hpu_comb #(.IS_NI( IS_NI), .THIS_PORT(THIS_PORT) ) hpucomb(.preset(preset), .chan_in_f ( chan_in_f), 
	.chan_in_b (chan_in_b), .chan_out_f ( chan_internal_f), .chan_out_b (chan_internal_b), .sel( sel_internal));

// The pipeline lathes of the HPU stage
generate
	if (IS_NI == 1'b1) //  resource_port
	hpu_latch #(.init_token(EMPTY_TOKEN)) 
	token_latch_1 (.preset(preset),.left_in(chan_internal_f),.left_out (chan_internal_b),
	.right_out(chan_out_f),.right_in ( chan_out_b),.sel_in( sel_internal),.sel_out( sel),.lt_enable ( ));
endgenerate

generate
	if (IS_NI == 1'b0) // other_port
	hpu_latch #(.init_token(VALID_TOKEN)) 
	token_latch_0 (.preset(preset),.left_in(chan_internal_f),.left_out (chan_internal_b),
	.right_out(chan_out_f),.right_in ( chan_out_b),.sel_in( sel_internal),.sel_out( sel),.lt_enable ( ));
endgenerate

endmodule
