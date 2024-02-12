
 `timescale 1ns/1ps

module hpu_comb

	#(parameter IS_NI , parameter [1:0] THIS_PORT )
             // false
	(preset, chan_in_f, chan_in_b, chan_out_f,chan_out_b,sel);
 
	import interact::*;

	input reg preset;

	input channel_forward chan_in_f; 
	output channel_backward chan_in_b;

	output channel_forward chan_out_f;
	input channel_backward chan_out_b;

	output onehot_sel sel;

	onehot_sel sel_internal, sel_current, sel_next;

// VLD_TYPE bit shows type of the phit (phit or void)
// SOP high on start of packet, EOP high on end of packet
wire VLD_TYPE,SOP,EOP;


assign VLD_TYPE = chan_in_f.data[LINK_WIDTH-1];
assign SOP = chan_in_f.data[LINK_WIDTH-2];
assign EOP = chan_in_f.data[LINK_WIDTH-3];

// 16 bits for routing
wire [1:0] DEST_PORT ;
assign DEST_PORT = chan_in_f.data[1:0];
	
wire [13:0] ROUTE_NEXT ; 
assign ROUTE_NEXT = chan_in_f.data[15:2]; 
	
reg [15:0] ROUTE_OUT ;
  
wire IN_REQ,IN_ACK,OUT_REQ,OUT_ACK;
	
reg OUT_REQ_internal;

// handshake signals
assign IN_REQ = chan_in_f.req;
assign IN_ACK = chan_in_b.ack;
assign OUT_REQ = chan_out_f.req;
assign OUT_ACK = chan_out_b.ack;



	wire REQ_INT, OUT_REQ_INT ;

/*
  attribute buffer_type : string;
  attribute buffer_type of sel_latch_en : signal is "none";
*/

	reg sel_latch_en /* synthesis maxfan = 10 */;
	
	
	onehot_sel sel_onehot;
 
always @ *
begin
if (IS_NI == 1'b0)
begin
if(DEST_PORT == THIS_PORT)
 sel_onehot = 5'b10000;      // NI

else if(DEST_PORT == 2'b00)
sel_onehot = 5'b00001;      // North

else if(DEST_PORT == 2'b01)
 sel_onehot = 5'b00010;	    // East

else if(DEST_PORT == 2'b10)
 sel_onehot = 5'b00100;     // South

else
 sel_onehot = 5'b01000;	     // West
end

if (IS_NI == 1)
begin
if(DEST_PORT == 2'b00)
 sel_onehot = 5'b00001;      // North

else if(DEST_PORT == 2'b01)
sel_onehot = 5'b00010;	    // East

else if(DEST_PORT == 2'b10)
 sel_onehot = 5'b00100;     // South

else
sel_onehot = 5'b01000;	     // West
end

 
end

// for empty phits and reset case: zero all select	
		assign sel_internal[0] = ( VLD_TYPE & sel_onehot[0]);
		assign sel_internal[1] = ( VLD_TYPE & sel_onehot[1]);
		assign sel_internal[2] = ( VLD_TYPE & sel_onehot[2]);
		assign sel_internal[3] = ( VLD_TYPE & sel_onehot[3]);
		assign sel_internal[4] = ( VLD_TYPE & sel_onehot[4]);	

// logic gates of the combinational hpu

wire A,B,C;
  assign   A = (VLD_TYPE & SOP);
  assign   B = (A |~( VLD_TYPE));
  assign   C = (REQ_INT ^ OUT_ACK);
  assign   sel_latch_en = ( B & C);
  
// latch 
always @ (  sel_latch_en or  preset or  sel_internal)
begin
if (preset == 1'b1) 
      sel =  { 1'b0 } ;
else if (sel_latch_en == 1'b1) 
      sel = sel_internal;
end

matched_delay  #( .size(hpu_first_req_delay)) in_req_delay ( .d (IN_REQ),.z( REQ_INT));

matched_delay #( .size(hpu_second_req_delay)) out_req_delay ( .d (REQ_INT),.z( OUT_REQ_INT));

matched_delay # ( .size(hpu_ack_delay)) out_ack_delay ( .d (chan_out_b.ack),.z( chan_in_b.ack));


always @ (  chan_in_f.req or chan_in_f.data  or  OUT_REQ_INT or VLD_TYPE or SOP )
// combination chan_in_f, chan_out_b, VLD_TYPE, SOP, OUT_REQ_INT)
begin
// forwarding
// default case: forward everything
//  chan_in_b  <= chan_out_b;
// chan_out_f = chan_in_f;
chan_out_f.req <= chan_in_f.req;
chan_out_f.data <= {chan_in_f.data[34:16],2'b00,chan_in_f.data[15:2]};

// implement delays  (overrides req in assotiation above!)
 OUT_REQ_internal = OUT_REQ_INT;

/*
    This is the header phit, so we shift the addr so the next switch knows where to route the packet.
    This allows one-hot decoding logic to always be driven by bottom 2 LSb's.
    override default: shift route
*/

if ( (VLD_TYPE ==1'b1) & (SOP == 1'b1) ) 
      ROUTE_OUT = {2'b00 , ROUTE_NEXT};
end

assign OUT_REQ = OUT_REQ_internal;

endmodule