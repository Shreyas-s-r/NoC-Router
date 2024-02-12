`timescale 1ns/1ps

import interact::*;

module hpu_latch 
  #(parameter integer GENERATE_REQUEST_DELAY = 0, 
	 parameter integer GENERATE_ACKNOWLEDGE_DELAY =  0,
	 parameter integer PHIT_WIDTH = 35,
	 
	// initial data
	parameter  [PHIT_WIDTH-1 :0]init_data  = {PHIT_WIDTH{1'bX}},  // Forced unknown

	parameter onehot_sel init_sel = 5'b00000,
	// initial state to implement
	
   parameter latch_state init_token = EMPTY_BUBBLE
	// type latch_state is (opaque, transparent);	

	)
	
	(preset,left_in,left_out,right_out, right_in, sel_in, sel_out , lt_enable);
	 

	
    input preset    ;
    input channel_forward left_in   ;
    output channel_backward left_out  ;
    
    output channel_forward right_out ;
    input channel_backward right_in  ;

    input onehot_sel sel_in ;   
    output onehot_sel sel_out  ;
    output lt_enable  ;
 
	wire type_in;
	
reg type_out;
reg [PHIT_WIDTH-1 :0] data;
	
	wire out_req_0, out_req_2;
	wire out_ack;
/*

  attribute buffer_type : string;
  attribute buffer_type of lt_en : signal is "none";
  attribute buffer_type of lt_gated : signal is "none";
  
  //	(* buffer_type = "none" *) lt_en;
*/


// string type for attrivutes or not?
	reg lt_en  /* synthesis maxfan = 10 */;
	reg lt_gated /* synthesis maxfan = 10 */;
	
	
	assign type_in   = left_in.data[PHIT_WIDTH-1];
	//  lt_gated <= lt_en or (not type_out) after delay;
	assign  lt_enable = lt_en;

	assign  right_out.data = { type_out , data };

	latch_controller #(.init_token (init_token)) controller(.preset (preset),.Rin ( left_in.req),
	.Ain ( out_ack),.Rout (out_req_0),. Aout( right_in.ack),.lt_en( lt_en));
	// left_out.ack

// Delay line at the output request
/*
    -- synthesis generates two inverters, ensure the
    -- generation of an actually reasonable delay by the
    -- definition of a synthesis constraint at synthesis
    -- these buffer just provide "handles" for the delay
    -- definition
    -- out_req_2 <= not out_req_1 after 1 ns;
    -- out_req_1 <= not out_req_0 after 1 ns; 
*/
generate
if( GENERATE_REQUEST_DELAY > 0) 	 // req_delay
 matched_delay #(.size (GENERATE_REQUEST_DELAY)) req_delay (.d(out_req_0),.z(out_req_2));
endgenerate


// No delay line
generate
	if( GENERATE_REQUEST_DELAY == 0)
	 assign out_req_2 = out_req_0;
endgenerate

generate
	if (GENERATE_ACKNOWLEDGE_DELAY > 0 ) // ack_delay 
	 matched_delay #(.size (GENERATE_ACKNOWLEDGE_DELAY)) ack_delay  (.d (out_ack),.z (left_out.ack));
endgenerate

	assign right_out.req = out_req_2;

generate
	if (GENERATE_ACKNOWLEDGE_DELAY == 0 )
	 assign left_out.ack = out_ack;
endgenerate

/*

(type_in)	   ____________
valid_in ---> |   Gate     | 
				  | controller | ---> valid_out
	lt_en ---> |____________|


*/



// Gating
generate
	if ( GATING_ENABLED == 1 )
	begin : Gating
//  generate gated enable signal
		assign #0.3 lt_gated = ( lt_en | ~( type_out) ); // after delay;

//Normal transparent latch, cf. figure 6.21 in S&F

	always@(lt_en,type_in,sel_in,preset)	
		begin : type_latch
		
		if (preset == 1'b1) 
			begin
			   type_out = 1'b0;
			   sel_out = init_sel;
			end	
		else if((lt_en == 1'b1) )
			begin
				#2 type_out =  type_in; //after delay
				#2 sel_out =  sel_in; 
			end  //after delay
	   end
	  
	always@(lt_gated,preset,left_in.data)
		begin : data_latch
			if (preset == 1'b1)
				data = init_data; //  Preset overrides the above
			else if (lt_gated == 1'b1) 
				#0.3ns data =  left_in.data[PHIT_WIDTH-1 : 0] ; // after delay;   Transparent
		end

	
	end	
endgenerate

generate

	if( GATING_ENABLED == 0)
	begin : NoGating
  // generate enable signal
		 assign lt_gated = lt_en;
  // Normal transparent latch, cf. figure 6.21 in S&F
     always@(lt_en,type_in,sel_in,preset,left_in.data)
	  begin	
		if (preset == 1'b1)
			begin
				type_out = 1'b0;
				data	 = init_data;		// Preset overrides the above
				sel_out	 = init_sel;   
			end
		else if (lt_en == 1'b1) 
			begin
				#2 type_out =  type_in;			//after delay;
				#2 data	 =  left_in.data[33:0];  // after delay;
				#2 sel_out	 =  sel_in;			//after delay;	
			end
	   end

   end

endgenerate

endmodule