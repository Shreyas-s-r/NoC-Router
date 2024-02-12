/*
		         ____________
     Rin ---> | Latch      | ---> Rout
     Ain <--- | controller | <--- Aout
		        |____________|

				  
*/

`timescale 1ns/1ps

import interact::*;
module latch_controller #(parameter latch_state init_token)
(preset,Rin,Ain,Rout, Aout,lt_en);



input preset;
input Rin ;
output Ain ;

output Rout;
input Aout ;

output lt_en;

// Simple latch controller; cf. figure 2.9 in S&F


reg r_next,req_prev;
wire set;
wire enable; //,preset_del,preset_del2 ;

wire reset,r_prev,r_out;


    assign Rout = r_next;
    assign Ain = r_next;
    assign #1.3 enable =  ~( ( r_next ^ Aout ));
    assign lt_en = enable;
	 
	generate
	 if(resolve_latch_state(init_token)== 1'b1)
		assign  r_prev = ~ Rin;
	 else 
	  assign	r_prev = Rin;

	 if(resolve_latch_state(init_token)== 1'b1)
	 assign r_out = ~ r_next;
	 else 
	 assign r_out = r_next;
	endgenerate

	 assign set = resolve_latch_state(init_token) & preset;
	 assign reset = ~(resolve_latch_state(init_token)) & preset;
	 
	 always @ (preset, enable, r_prev)
	 begin : req_latch
	 if (preset== 1'b1 )
         r_next = 1'b0;
     else if (enable== 1'b1) 
        #1.3  r_next =  r_prev ; // after delay;
	 end
	 /*
always@(enable,Rin,r_next)//,set,reset,req_prev)
begin
	 if(enable == 1'b1)
	   req_prev =  Rin;
	 else 
	   req_prev = r_next;

	// r_next = set | ((~ reset) & req_prev);
end*/
endmodule
