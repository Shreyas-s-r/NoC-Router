`timescale 1ns/1ps

module   matched_delay  #(parameter integer size  = 10) (
        d,
        z
    );

    input d;
    output z;

    wire internal;
    assign internal =  ~( d);
	 // #0.3ns;
    assign #3 z =  ~( internal);  // after 0.3ns*size

endmodule 
