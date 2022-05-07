module stopwatch(input clk, reset, run, 
                 output [3:0] HEX0, HEX1, HEX2, HEX3);

    // 50 MHz * 1s = 50,000,000 times in one second
    logic [3:0] secs, tensSecs, mins, tensMins; 
    logic [31:0] clkCount;
    logic tick;

    always_ff @ (posedge clk or posedge reset)
    begin
        
        if (reset) clkCount <= 0;
        else if (clkCount == 50000000) clkCount <= 0;
        else if (run) clkCount <= clkCount + 1;

    end

    assign tick = clkCount == 50000000 ? 1'b1 : 1'b0;

    always_ff @ (posedge clk or posedge reset) 
    begin

        if (reset) 
        begin
            secs <= 0;
            tensSecs <= 0;
            mins <= 0;
            tensMins <= 0;
        end

        else if (tick) 
        begin
            if(secs == 9) //xxx9 - the ones digit of seconds
            begin  //if_1
                secs <= 0;
                
                if (tensSecs == 5) //xx59 - tens digit of seconds 
                begin  // if_2
                    tensSecs <= 0;

                    if (mins == 9) //x959 - the ones digit of the minutes
                    begin //if_3
                        mins <= 0;
                    
                        if(tensMins == 5) //9959 - the tens digit of the minutes
                            tensMins <= 0;
                        
                        else
                            tensMins <= tensMins + 1;
                    end
                    
                    else //else_3
                        mins <= mins + 1;
                end
                    
                else //else_2
                    tensSecs <= tensSecs + 1;
            end 
            
            else //else_1
                secs <= secs + 1;
        end
    end
    
    assign HEX0 = secs;
    assign HEX1 = tensSecs;
    assign HEX2 = mins;
    assign HEX3 = tensMins;

endmodule