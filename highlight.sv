module  highlight ( input Reset, frame_clk,
					input [7:0] keycode,
               		output [9:0]  highlightX, highlightY);

	parameter [9:0] HL_X_Corner = 4;  
    parameter [9:0] HL_Y_Corner = 80;  
    parameter [9:0] HL_X_Min = 4;      
    parameter [9:0] HL_X_Max = 324;     
    parameter [9:0] HL_Y_Min = 80;       
    parameter [9:0] HL_Y_Max = 400;
    
	logic [9:0] HL_X_Pos, HL_Y_Pos;
	logic atLeftEdge, atRightEdge, atTopEdge, atBotEdge;
	logic leftPressed, rightPressed, upPressed, downPressed, keyPressed;

	assign atLeftEdge = (HL_X_Pos <= HL_X_Min) ? 1'b1 : 1'b0;
	assign atRightEdge = (HL_X_Pos >= HL_X_Max) ? 1'b1 : 1'b0;
	assign atTopEdge = (HL_Y_Pos <= HL_Y_Min) ? 1'b1 : 1'b0;
	assign atBotEdge = (HL_Y_Pos >= HL_Y_Max) ? 1'b1 : 1'b0;

	assign keyPressed = (keycode == 0) ? 1'b0 : 1'b1;

	assign rightPressed = (keycode == 8'h4F) ? 1'b1 : 1'b0;
	assign leftPressed = (keycode == 8'h50) ? 1'b1 : 1'b0;
	assign downPressed = (keycode == 8'h51) ? 1'b1 : 1'b0;
	assign upPressed = (keycode == 8'h52) ? 1'b1 : 1'b0;

	always_ff @ (posedge Reset or posedge keyPressed)
	begin
		if (Reset)  // Asynchronous Reset
        begin
			HL_X_Pos <= HL_X_Corner;
			HL_Y_Pos <= HL_Y_Corner;
        end
		else
		begin
			if (rightPressed)
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
	end
    
    assign highlightX = HL_X_Pos;
    assign highlightY = HL_Y_Pos;   

endmodule
