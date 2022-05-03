module  highlight ( input Reset, frame_clk,
					input [7:0] keycode,
               		output [9:0]  highlightX, highlightY);
    
	logic [9:0] HL_X_Pos, HL_Y_Pos;
	logic atLeftEdge, atRightEdge, atTopEdge, atBotEdge;
	logic [7:0] xVel, yVel;
	logic [3:0] edges;
	assign edges = {atLeftEdge, atRightEdge, atTopEdge, atBotEdge};
	logic leftPressed, rightPressed, upPressed, downPressed;

	// assign atLeftEdge = (HL_X_Pos <= HL_X_Min) ? 1'b1 : 1'b0;
	// assign atRightEdge = (HL_X_Pos >= HL_X_Max) ? 1'b1 : 1'b0;
	// assign atTopEdge = (HL_Y_Pos <= HL_Y_Min) ? 1'b1 : 1'b0;
	// assign atBotEdge = (HL_X_Pos >= HL_Y_Max) ? 1'b1 : 1'b0;

	assign rightPressed = (keycode == 8'h4F) ? 1'b1 : 1'b0;
	assign leftPressed = (keycode == 8'h50) ? 1'b1 : 1'b0;
	assign downPressed = (keycode == 8'h51) ? 1'b1 : 1'b0;
	assign upPressed = (keycode == 8'h52) ? 1'b1 : 1'b0;
	 
    parameter [9:0] HL_X_Corner = 4;  
    parameter [9:0] HL_Y_Corner = 80;  
    parameter [9:0] HL_X_Min = 4;      
    parameter [9:0] HL_X_Max = 324;     
    parameter [9:0] HL_Y_Min = 80;       
    parameter [9:0] HL_Y_Max = 400;

	always_ff @ (posedge Reset or 
				 posedge rightPressed or posedge leftPressed or 
				 posedge downPressed or posedge upPressed)
	begin
		if (Reset)  // Asynchronous Reset
        begin
			HL_X_Pos <= HL_X_Corner;
			HL_Y_Pos <= HL_Y_Corner;
        end

		else if (rightPressed)
			begin
			if (!atRightEdge) 
				HL_X_Pos <= HL_X_Pos + 80;
			end

		else if (leftPressed)
			begin
			if (!atLeftEdge)
				HL_X_Pos <= HL_X_Pos - 80;
			end

		else if (downPressed)
			begin
			if (!atBotEdge) 
				HL_Y_Pos <= HL_Y_Pos + 80;
			end

		else if (upPressed)
			begin
			if (!atTopEdge) 
				HL_Y_Pos <= HL_Y_Pos - 80;
			end
	end
		
		
	
    always_ff @ (posedge frame_clk)
    begin: Move_HL

		// if (HL_X_Pos == HL_X_Min) atLeftEdge <= 1;
		// else atLeftEdge <= 0;

		// if (HL_X_Pos == HL_X_Max) atRightEdge <= 1;
		// else atRightEdge <= 0;

		// if (HL_Y_Pos == HL_Y_Min) atTopEdge <= 1;
		// else atTopEdge <= 0;

		// if (HL_Y_Pos == HL_Y_Max) atBotEdge <= 1;
		// else atBotEdge <= 0;

			// case ({keycode, edges})
			// 	// 0000, 0001, 0010, 0011, 1000, 1001, 1010, 1011
			// 	{8'h4F, 4'b0000}, {8'h4F, 4'b0001}, {8'h4F, 4'b0010}, {8'h4F, 4'b0011}, {8'h4F, 4'b1000}, {8'h4F, 4'b1001}, {8'h4F, 4'b1010}, {8'h4F, 4'b1011} : // right
			// 	begin	
			// 		xVel <= 80;
			// 		yVel <= 0;
			// 	end
			// 	// 0000, 0001, 0010, 0011, 0100, 0101, 0110, 0111
			// 	{8'h50, 4'b0000}, {8'h50, 4'b0001}, {8'h50, 4'b0010}, {8'h50, 4'b0011}, {8'h50, 4'b0100}, {8'h50, 4'b0101}, {8'h50, 4'b0110}, {8'h50, 4'b0111} : // left
			// 	begin	
			// 		xVel <= -80;
			// 		yVel <= 0;
			// 	end
			// 	// 0000, 0010, 0100, 0110, 1000, 1010, 1100, 1110
			// 	{8'h51, 4'b0000}, {8'h51, 4'b0010}, {8'h51, 4'b0100}, {8'h51, 4'b0110}, {8'h51, 4'b1000}, {8'h51, 4'b1010}, {8'h51, 4'b1100}, {8'h51, 4'b1110} : // down
			// 	begin	
			// 		xVel <= 0;
			// 		yVel <= 80; 
			// 	end
			// 	// 0000, 0001, 0100, 0101, 1000, 1001, 1100, 1101
			// 	{8'h52, 4'b0000}, {8'h52, 4'b0001}, {8'h52, 4'b0100}, {8'h52, 4'b0101}, {8'h52, 4'b1000}, {8'h52, 4'b1001}, {8'h52, 4'b1100}, {8'h52, 4'b1101} : // up
			// 	begin
			// 		xVel <= 0;
			// 		yVel <= -80;
			// 	default:
			// 	begin
			// 		xVel <= 0;
			// 		yVel <= 0;
			// 	end
			// endcase
			// HL_X_Pos <= HL_X_Pos + xVel;
			// HL_Y_Pos <= HL_Y_Pos + yVel;
		
    end
    
    assign highlightX = HL_X_Pos;
    assign highlightY = HL_Y_Pos;   

endmodule
