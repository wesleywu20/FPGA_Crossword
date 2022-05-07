module testbench();

    timeunit 10ns;	// Half clock cycle at 50 MHz
				// This is the amount of time represented by #1 
	timeprecision 1ns;

    // module  highlight ( input Reset, frame_clk,
	// 				input [7:0] keycode,
    //            		output [9:0]  highlightX, highlightY);
    logic Reset, frame_clk;
    logic [7:0] keycode;
    logic [9:0] highlightX, highlightY;

    always begin : CLOCK_GENERATION
	#1 frame_clk = ~frame_clk;
	end

	initial begin: CLOCK_INITIALIZATION
		 frame_clk = 0;
	end 

	// Testing begins here
	// The initial block is not synthezable
	// Everything happens sequentially inside an initial block
	// as in a software program

    // assign rightPressed = (keycode == 8'h4F) ? 1'b1 : 1'b0;
	// assign leftPressed = (keycode == 8'h50) ? 1'b1 : 1'b0;
	// assign downPressed = (keycode == 8'h51) ? 1'b1 : 1'b0;
	// assign upPressed = (keycode == 8'h52) ? 1'b1 : 1'b0;

	initial begin: TEST_VECTORS
        Reset = 1;
        keycode = 0;
        
        #2 Reset = 0;

        #2 keycode = 8'h51;
        #2 keycode = 0;

        #2 keycode = 8'h51;
        #2 keycode = 0;

        #2 keycode = 8'h51;
        #2 keycode = 0;

        #2 keycode = 8'h51;
        #2 keycode = 0;

        #2 keycode = 8'h4F;
        #2 keycode = 0;

        #2 keycode = 8'h52;
        #2 keycode = 0;

    end
    
endmodule

