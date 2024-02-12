`timescale 1ns/1ps

module tb();
import interact::*;

 logic preset;
 channel_forward n_in_f,e_in_f,s_in_f,w_in_f,r_in_f; //i
 channel_backward n_in_b,e_in_b,s_in_b,w_in_b,r_in_b;//o

 channel_forward n_out_f,e_out_f,s_out_f,w_out_f,r_out_f;//o
 channel_backward n_out_b,e_out_b,s_out_b,w_out_b,r_out_b;//i
 
 logic clk;

 
router route ( .preset(preset),
.north_in_f (n_in_f), .east_in_f (e_in_f), .south_in_f (s_in_f), .west_in_f (w_in_f), .resource_in_f(r_in_f),
.north_in_b (n_in_b), .east_in_b (e_in_b), .south_in_b (s_in_b), .west_in_b (w_in_b), .resource_in_b (r_in_b),
.north_out_f (n_out_f), .east_out_f (e_out_f), .south_out_f (s_out_f), .west_out_f (w_out_f), .resource_out_f(r_out_f),
.north_out_b (n_out_b), .east_out_b (e_out_b), .south_out_b (s_out_b), .west_out_b (w_out_b), .resource_out_b (r_out_b));

always #10 clk = ~clk;
initial
	begin
	preset = 1;clk=1;
	n_in_f.req = 0;
	e_in_f.req = 0;
	s_in_f.req = 0;
	w_in_f.req = 0;
	r_in_f.req = 0; 
	
	n_in_f.data = 35'b0;
	e_in_f.data = 35'b0;
	s_in_f.data = 35'b0;
	w_in_f.data = 35'b0;
	r_in_f.data = 35'b0;
	
	n_out_b.ack = 0; 
	e_out_b.ack = 0;
	s_out_b.ack = 0;
	w_out_b.ack = 0;
   r_out_b.ack = 0;

	
	# 4ns
	preset = 0;
/*	
	// NI 1(r) i.e source to NI 2(w)
	r_in_f.req = 1;
	# 1ns
	r_in_f.data = 35'b110_00000_11111_000000_000000_0000_001011;
	#5ns
	w_out_b.ack = 1;
*/

/*	
	// NI 2(e) to NI 3(s)
	e_in_f.req = 1;
	# 1ns
	e_in_f.data = 35'b110_00000_11111_000000_000000_0000_000010;s
	#5ns
	s_out_b.ack = 1;
*/	
	
	
	// NI 3(n) to NI 3(r) i.e destination
	n_in_f.req = 1;
	# 1ns
	n_in_f.data = 35'b110_00000_11111_000000_000000_0000_000000;
	#5ns
	r_out_b.ack = 1;
	
	
end

endmodule