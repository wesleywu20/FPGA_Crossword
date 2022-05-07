module cwsm(input clk, reset, run, win,
            input [7:0] keycode,
            output [1:0] display,
            output game_reset,
            output [3:0] hex);

    enum logic [1:0] {Menu, Level, Win} State, Next_state; 

    always_ff @ (posedge clk)
	begin
		//  if (reset) 
		//  	State <= Menu;
		//  else 
		State <= Next_state;
	end
    always_comb
    begin
		Next_state = State;
        unique case (State)
            Menu:
                if (keycode == 8'h28)
                    Next_state = Level;
            Level:
                if (win)
                    Next_state = Menu;
                else   
                    Next_state = Level;
            // CloseToWin:
            //     if (run)
            //         Next_state = Level;
            default: Next_state = Menu;
		  endcase
        
        case (State) 
            Menu: 
				begin
                display = 2'b00;
                game_reset = 1'b1;
                hex = 4'b1;
				end
            Level:
				begin
                display = 2'b01;
                game_reset = 1'b0;
                hex = 4'b0;

				end
        endcase
    end
endmodule