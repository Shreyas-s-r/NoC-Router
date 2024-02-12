`timescale 1ns/1ps

module sr_latch (
        s,
        r,
        q,
        qn
    );
    
    input s;  // set, active high
    input r;  // reset, active high
    output q;  // q
    output qn;  // q inverted

	 reg q_i,qn_i;
	 
always @(s or r ) 
begin
	q_i = 0;
	qn_i = 0;

if((s == 1) & (r==0))
begin
	q_i = 1;
	qn_i = 0;
end

else if((s==0) & (r == 1))
begin
	q_i = 0;
	qn_i =1;
end

else if((s==1) & (r == 1)) // Set & Reset => invalid
	begin
	q_i <= 1'bX;
	qn_i <= 1'bX;
	end
	
end

assign q = q_i;
assign qn = qn_i;

endmodule

   
 

