// import interact::*;

package interact;


	parameter GATING_ENABLED = 1'b1;
	parameter integer ARITY = 5;
	parameter integer LINK_WIDTH = 35;
	parameter integer N = 2;
	parameter integer M = 2;
	

	
	typedef  enum {opaque, transparent} latch_state;
	parameter  latch_state EMPTY_TOKEN  = transparent;
	parameter  latch_state EMPTY_BUBBLE = transparent;
	parameter  latch_state VALID_BUBBLE = transparent;
	parameter  latch_state VALID_TOKEN  = opaque;

	typedef logic [LINK_WIDTH-1 : 0] link_t;
	typedef logic [LINK_WIDTH-1 : 0] bars_t [4:0][4:0] ;	
	typedef logic [ARITY-1 : 0] onehot_sel ; 

	typedef onehot_sel switch_sel_t [ARITY-1:0] ;


	typedef struct {
	  logic req ;
	  logic [LINK_WIDTH-1 : 0] data;
	} channel_forward;

	typedef struct {
	 logic ack;
	} channel_backward;
	
	

	typedef channel_forward   chs_f [ARITY-1:0] ;
	typedef channel_backward   chs_b [ARITY-1:0] ;

	//typedef  channel_forward  link_n_f [N - 1] ;
	//typedef link_n_f link_m_f [M - 1]  ;

	//typedef  channel_backward link_n_b [N - 1] ;
	//typedef  link_n_b link_m_b [M - 1] ;
	


   function resolve_latch_state (input latch_state a) ;
	begin
		if (a == transparent ) 
			 return 0;	// valid-bubbles (and all empties - also empty tokens) are transparent latches
		else	
			return 1;	// Only valid-tokens are opaque latches
	end 
	endfunction

// Delays
	parameter int unsigned inp_req_delay = 1;
	parameter int unsigned inp_ack_delay = 2;
	parameter int unsigned link_req_delay = 1;
	parameter int unsigned link_ack_delay = 2; 	// previous was 5
	parameter int unsigned hpu_ack_delay = 3; 	// 6
	parameter int unsigned hpu_first_req_delay = 6; 	//4
	parameter int unsigned hpu_second_req_delay = 4; 	//2
	parameter int unsigned crossbar_sync_req_delay  = 4;
	parameter int unsigned crossbar_sync_ack_delay  = 2;
	parameter int unsigned input_fifo_req_delay = 1;
	parameter int unsigned input_fifo_ack_delay = 0; 	// Input Fifo size 1 and the ack is ignored by the NI
	parameter int unsigned output_fifo_req_delay = 1;
	parameter int unsigned output_fifo_ack_delay = 2; 	// no less than 2
	
	
endpackage





