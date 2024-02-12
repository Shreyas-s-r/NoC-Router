`timescale 1ns/1ps

module c_gate_generic #(parameter C_INIT, parameter integer WIDTH  = 3) (
        preset,
        in_put,
        out_put
    );
 
    input preset;
    input [( WIDTH - 1 ):0]in_put;
    output out_put;

    reg set;
    reg reset;

    always @ (  in_put or  preset)
    begin : set_reset

        reg set_var;
        reg not_reset_var;

        integer i;
        set_var = 1'b1;
        not_reset_var = 1'b0;

        for ( i = ( WIDTH- 1 ) ; ( i >= 0 ) ; i = ( i - 1 ) )
        begin 
            set_var = ( set_var & in_put[i] );
            not_reset_var = ( not_reset_var | in_put[i] );
        end
        set <= set_var;
        reset <=  ~( not_reset_var);

        if ( preset == 1'b1)  // Preset overrides the above
        begin
            if ( C_INIT == 1'b1 ) 
            begin
                set <= 1'b1;
                reset <= 1'b0;
            end
            else
            begin 
                set <= 1'b0;
                reset <= 1'b1;
            end
        end

    end
// 	set   <= a and b;	--   Set when a=1 and b=1
// 	reset <= a nor b;	-- Reset when a=0 and b=0
   
   sr_latch 
         latch (
            .q(out_put),
            .qn( ),
            .r(reset),
            .s(set)
        );
endmodule 