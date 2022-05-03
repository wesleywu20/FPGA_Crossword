//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper (  input blank, pxl_clk, act_pix,
                        input [3:0] FGD_R, FGD_G, FGD_B,
                        input [9:0]  DrawX, DrawY,
                        output [3:0]  Red, Green, Blue );
	logic [3:0] r, g, b;
    always_ff @ (posedge pxl_clk)
    begin
    // if (RESET == 1'b0)
    // begin
    // 	r <= 0;
    // 	g <= 0;
    // 	b <= 0;
    // end
    if (blank)
    begin
        if ( ((DrawX + 1) >= `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2 && DrawX <= `CROSSWORD_RIGHT_EDGE + `LINE_WIDTH / 2) || // drawing right edge of crossword
             ((480 - (DrawY + 1)) % `HORIZONTAL_DIV == 0 && DrawX < `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2) || // drawing crossword grid horizontal lines)
             ((DrawX - 3) % `VERTICAL_DIV == 0 && DrawX < `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2 && DrawY >= 80) || // drawing crossword grid vertical lines
             (DrawX < 3 && DrawY >= 80)

        ) 
        begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
        else if (act_pix == 1'b1) 
        begin 
            r <= FGD_R;
            g <= FGD_G;
            b <= FGD_B;
        end       
        else // draw background
        begin
            r <= 4'b1111;
            g <= 4'b1111;
            b <= 4'b1111;
        end
    end
    else
    begin
        r <= 0;
        g <= 0;
        b <= 0;
    end
end

assign Red = r;
assign Green = g;
assign Blue = b;
    
endmodule
