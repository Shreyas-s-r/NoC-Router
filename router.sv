`timescale 1ns/1ps
module router( preset,north_in_f, north_in_b,east_in_f,east_in_b, south_in_f,south_in_b,west_in_f,west_in_b, resource_in_f,resource_in_b,
north_out_f,north_out_b,east_out_f,east_out_b,south_out_f,south_out_b,west_out_f,west_out_b,resource_out_f,resource_out_b);

import interact::*;

	input logic preset;
// input ports
	input channel_forward north_in_f,east_in_f,south_in_f,west_in_f,resource_in_f;  // data and req
	output channel_backward north_in_b,east_in_b,south_in_b,west_in_b,resource_in_b;  // ack

// output ports
	output channel_forward north_out_f,east_out_f,south_out_f,west_out_f,resource_out_f;  // data and req
	input channel_backward north_out_b,east_out_b,south_out_b,west_out_b,resource_out_b;  // ack

	 channel_forward north_hpu_f ,south_hpu_f,east_hpu_f,west_hpu_f,resource_hpu_f;   // data and req
	 channel_backward north_hpu_b,south_hpu_b,east_hpu_b,west_hpu_b,resource_hpu_b;   // ack

	 switch_sel_t switch_sel;
	 chs_f chs_in_f;  //data and req
	 chs_b chs_in_b;  //ack

	 chs_f latches_out_f;  //data and req
	 chs_b latches_out_b;  //ack


// input latches, converting from 2-phased LEDR to 2-phased bundled data 

	channel_latch #(.GENERATE_ACKNOWLEDGE_DELAY ( link_ack_delay),.init_token (EMPTY_BUBBLE) )
	north_in_latch  (.preset(preset),.left_in(north_in_f),.left_out( north_in_b),.right_out(north_hpu_f),
	.right_in  (north_hpu_b),.lt_enable ());

	channel_latch #(.GENERATE_ACKNOWLEDGE_DELAY ( link_ack_delay),.init_token (EMPTY_BUBBLE) )
	south_in_latch  (.preset(preset),.left_in(south_in_f),.left_out( south_in_b),.right_out(south_hpu_f),
	.right_in  (south_hpu_b),.lt_enable ());

	channel_latch #(.GENERATE_ACKNOWLEDGE_DELAY ( link_ack_delay),.init_token (EMPTY_BUBBLE) )
	east_in_latch  (.preset(preset),.left_in(east_in_f),.left_out(east_in_b),.right_out(east_hpu_f),
	.right_in  (east_hpu_b),.lt_enable ());

	channel_latch #(.GENERATE_ACKNOWLEDGE_DELAY ( link_ack_delay),.init_token (EMPTY_BUBBLE) )
	west_in_latch  (.preset(preset),.left_in(west_in_f),.left_out( west_in_b),.right_out(west_hpu_f),
	.right_in  (west_hpu_b),.lt_enable ());

	channel_latch #(.GENERATE_ACKNOWLEDGE_DELAY ( link_ack_delay),.init_token (EMPTY_BUBBLE) )
	resource_in_latch  (.preset(preset),.left_in(resource_in_f),.left_out( resource_in_b),
	.right_out(resource_hpu_f),.right_in  (resource_hpu_b),.lt_enable ());




/*
IS_NI is bool i.e false for N,E,S,W and True for local
THIS_PORT is 00 => N , 10 => S , 01 => E , 11 => W , -- => local
*/

// O index => North, 2 index => south , 1 index => East, 3 index => West, -- index => local

hpu #(
.IS_NI(1'b0),
.THIS_PORT(2'b00)
) north_hpu_inst (
.preset(preset),
.chan_in_b(north_hpu_b),
.chan_in_f(north_hpu_f),
.chan_out_b(chs_in_b[0]),
.chan_out_f(chs_in_f[0]),
.sel(switch_sel[0])
);
hpu #(
.IS_NI(1'b0),
.THIS_PORT(2'b10)
) south_hpu_inst (
.preset(preset),
.chan_in_b(south_hpu_b),
.chan_in_f(south_hpu_f),
.chan_out_b(chs_in_b[2]),
.chan_out_f(chs_in_f[2]),
.sel(switch_sel[2])
);
hpu #(
.IS_NI(1'b0),
.THIS_PORT(2'b01)
) east_hpu_inst (
.preset(preset),
.chan_in_b(east_hpu_b),
.chan_in_f(east_hpu_f),
.chan_out_b(chs_in_b[1]),
.chan_out_f(chs_in_f[1]),
.sel(switch_sel[1])
);
hpu #(
.IS_NI(1'b0),
.THIS_PORT(2'b11)
) west_hpu_inst (
.preset(preset),
.chan_in_b(west_hpu_b),
.chan_in_f(west_hpu_f),
.chan_out_b(chs_in_b[3]),
.chan_out_f(chs_in_f[3]),
.sel(switch_sel[3])
);

hpu #(
.IS_NI(1'b1),
.THIS_PORT(2'bxx)
) resource_hpu_inst (
.preset(preset),
.chan_in_b(resource_hpu_b),
.chan_in_f(resource_hpu_f),
.chan_out_b(chs_in_b[4]),
.chan_out_f(chs_in_f[4]),
.sel(switch_sel[4])
);
	

	crossbar_stage xbar_with_latches (.preset( preset),.switch_sel ( switch_sel),.chs_in_f ( chs_in_f),
	.chs_in_b ( chs_in_b),.latches_out_f (latches_out_f),.latches_out_b(latches_out_b) );

 	assign	north_out_f = latches_out_f[0];
 	assign	latches_out_b[0] = north_out_b;

 	assign	south_out_f = latches_out_f[2];
 	assign	latches_out_b[2] = south_out_b;

 	assign	east_out_f = latches_out_f[1];
 	assign	latches_out_b[1] = east_out_b;

 	assign	west_out_f = latches_out_f[3];
 	assign	latches_out_b[3] = west_out_b;

 	assign	resource_out_f = latches_out_f[4];
 	assign	latches_out_b[4] = resource_out_b;

endmodule