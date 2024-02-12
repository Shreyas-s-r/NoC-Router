
 `timescale 1ns/1ps

module crossbar(preset,switch_sel,chs_in_f,chs_in_b,chs_out_f,chs_out_b);

import interact::*;

	input preset;
	input switch_sel_t switch_sel; // 5 x 5 

	input chs_f chs_in_f;
	output  chs_b chs_in_b;

	output chs_f chs_out_f;
	input chs_b chs_out_b;

	reg [ARITY-1:0] sync_ack,sync_req;
	
	wire  synced_req,synced_ack;
	wire del_req,del_ack;
	// wire del;

// A C-element for synchronizing the request signal in the router
	c_gate_generic #(.C_INIT(1'b0),.WIDTH( ARITY)) 
	c_sync_req (.preset(preset),.in_put(sync_req),.out_put(synced_req));

// Delay Element for crossbar combinational delay
	matched_delay #(.size(crossbar_sync_req_delay)) 
	delay_req_element (.d(synced_req),.z(del_req));

// A C-element for synchronizing the acknowledge signal in the router
	c_gate_generic #(.C_INIT(1'b0),.WIDTH( ARITY))
	c_sync_ack (.preset(preset),.in_put(sync_ack),.out_put(synced_ack));

	matched_delay #(.size(crossbar_sync_ack_delay)) 
	delay_ack_element (.d(synced_ack),.z(del_ack));
		

// The wires between the request and acknowledge signals and the C-elements
	always @ ( chs_in_f[0].req or chs_out_f[0].data or chs_in_b[0].ack 
				 or chs_in_f[1].req or chs_out_f[1].data or chs_in_b[0].ack
				  or chs_in_f[2].req or chs_out_f[2].data or chs_in_b[0].ack
				   or chs_in_f[3].req or chs_out_f[3].data or chs_in_b[0].ack
					 or chs_in_f[4].req or chs_out_f[4].data or chs_in_b[0].ack  
					  or del_ack or del_req)
				
	begin : wires
	integer i;
	for ( i = ( ARITY - 1 ) ; ( i >= 0 ) ; i = ( i - 1 ) )
	begin
		sync_req[i] = chs_in_f[i].req;
		sync_ack[i] = chs_out_b[i].ack;
		chs_in_b[i].ack = del_ack;  // ack signals 
		chs_out_f[i].req = del_req;
	end
	end

// The crossbar itself
always @  (chs_out_f[0].data or chs_out_f[1].data or chs_out_f[2].data or chs_out_f[3].data or chs_out_f[4].data or 
	switch_sel [0][0] or switch_sel [0][1] or switch_sel [0][2] or switch_sel [0][3] or switch_sel [0][4] or
	switch_sel [1][0] or switch_sel [1][1] or switch_sel [1][2] or switch_sel [1][3] or switch_sel [1][4] or
	switch_sel [2][0] or switch_sel [2][1] or switch_sel [2][2] or switch_sel [2][3] or switch_sel [2][4] or
	switch_sel [3][0] or switch_sel [3][1] or switch_sel [3][2] or switch_sel [3][3] or switch_sel [3][4] or
	switch_sel [4][0] or switch_sel [4][1] or switch_sel [4][2] or switch_sel [4][3] or switch_sel [4][4] or
	synced_req)
	begin : cross_bar
	   bars_t bars; // 5 bit size of(5 x 5)
		typedef link_t demux_out_t[( ARITY - 1 ):0];
		demux_out_t demux_out; // 35 bit size with 5 indices

		integer i;   //Demux
	for ( i = ( ARITY - 1 ) ; ( i >= 0 ) ; i = ( i - 1 ) )
	begin
		integer j;
	for ( j = ( ARITY- 1 ) ; ( j >= 0 ) ; j = ( j - 1 ) )
	begin
		if ( switch_sel[i][j] == 1'b1 )
			bars[i][j] = chs_in_f[i].data;
		else
			bars[i][j] = 0;
	end
	end

// Merge
	for ( i = ( ARITY-1 ) ; ( i >= 0 ) ; i = ( i - 1 ) )
	begin
		integer j;
		demux_out[i] = 0 ;
	    for ( j = ( ARITY-1 ) ; ( j >= 0 ) ; j = ( j - 1 ) )
		begin
		  	demux_out[i] = ( demux_out[i] | bars[j][i] );
		end
	chs_out_f[i].data = demux_out[i];
	 // Don't edit. This must NOT be moved up to the 'wires' process. This is propably a bug in ISim
	end

	end  // end cross

endmodule