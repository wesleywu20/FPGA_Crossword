/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register
`define LINE_WIDTH 3
`define CROSSWORD_RIGHT_EDGE 400
`define HORIZONTAL_DIV 86
`define VERTICAL_DIV 80

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);


// logic [31:0] LOCAL_REG [`NUM_REGS]; // Registers
logic [31:0] PALETTE_REG [8];
//put other local variables here
logic hsync, vsync, pxl_clk, blank, sync;
logic [9:0] drawX, drawY;
logic [7:0] char;
logic [3:0] r, g, b;
logic [7:0] charcode, COLOR;
// logic [11:0] COLOR_DATA_ADDR;
logic [31:0] COLOR_DATA, CHARS;
logic [11:0] ram_addr;




//Declare submodules..e.g. VGA controller, ROMS, etc
// module  vga_controller ( input        Clk,       // 50 MHz clock
//                                       Reset,     // reset signal
//                          output logic hs,        // Horizontal sync pulse.  Active low
// 								              vs,        // Vertical sync pulse.  Active low
// 												  pixel_clk, // 25 MHz pixel clock output
// 												  blank,     // Blanking interval indicator.  Active low.
// 												  sync,      // Composite Sync signal.  Active low.  We don't use it in this lab,
// 												             //   but the video DAC on the DE2 board requires an input for it.
// 								 output [9:0] DrawX,     // horizontal coordinate
// 								              DrawY );   // vertical coordinate
vga_controller ctrl(.Clk(CLK), .Reset(RESET), 
					.hs(hs), .vs(vs), .pixel_clk(pxl_clk), .blank(blank), .sync(sync), 
					.DrawX(drawX), .DrawY(drawY));

johncena ram(.address_a(AVL_ADDR), .address_b(ram_addr),
             .byteena_a(AVL_BYTE_EN), .byteena_b(4'b0000),
             .clock(CLK),
             .data_a(AVL_WRITEDATA), .data_b(),
             .rden_a(AVL_READ), .rden_b(1'b1),
             .wren_a(AVL_WRITE), .wren_b(1'b0),
             .q_a(AVL_READDATA), .q_b(CHARS));
   
// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
// always_ff @(posedge CLK) 
// begin
// 	if (AVL_CS && AVL_WRITE)
// 		begin
// 			if (AVL_BYTE_EN[0]) LOCAL_REG[AVL_ADDR][7:0] = AVL_WRITEDATA[7:0];
// 			if (AVL_BYTE_EN[1]) LOCAL_REG[AVL_ADDR][15:8] = AVL_WRITEDATA[15:8];
// 			if (AVL_BYTE_EN[2]) LOCAL_REG[AVL_ADDR][23:16] = AVL_WRITEDATA[23:16];
// 			if (AVL_BYTE_EN[3]) LOCAL_REG[AVL_ADDR][31:24] = AVL_WRITEDATA[31:24];
// 		end
// 	else
// 		begin
// 		if (AVL_CS && AVL_READ) 
// 			AVL_READDATA <= LOCAL_REG[AVL_ADDR];
// 		end
// end

//handle drawing (may either be combinational or sequential - or both).
//  [character1 | color1 | character2 | color2]
always_ff @ (posedge CLK) 
begin
    // if (AVL_ADDR == `CTRL_REG && AVL_WRITE) COLOR_DATA <= AVL_WRITEDATA;
    if (AVL_ADDR[11] && AVL_WRITE) // if AVL_ADDR[11] is 1, then we're accessing the palette registeres
        PALETTE_REG[AVL_ADDR[2:0]] <= AVL_WRITEDATA;
end

assign ram_addr = drawY[9:4] * 40 + drawX[9:4];

always_comb
begin
    COLOR = CHARS[{drawX[3],4'b0000}+:8];
end

// if (COLOR[4] == 0) // if the index of the first color is even
//     COLOR_DATA[12:1] = PALETTE_REG[COLOR[7:5]][12:1]; // load the 12-bit background color of the palette register whose index is given by color / 2 into the background color 
// else
//     COLOR_DATA[24:13] = PALETTE_REG[COLOR[7:5]][24:13]; // else, load the 12-bit foreground color of the palette register whose index is given by color / 2 into the foreground color
// if (COLOR[0] == 0) // if the index of the second color is even
//     COLOR_DATA[12:1] = PALETTE_REG[COLOR[3:1]][12:1]; // load the 12-bit background color of the palette register whose index is given by color / 2 into the background color  
// else
//     COLOR_DATA[24:13] = PALETTE_REG[COLOR[3:1]][24:13]; // else, load the 12-bit foreground color of the palette register whose index is given by color / 2 into the foreground color



assign charcode = CHARS[{drawX[3], 4'b1000} +: 8];

logic [3:0] FGD_R, FGD_G, FGD_B, BKG_R, BKG_G, BKG_B;
    
assign FGD_R = PALETTE_REG[COLOR[7:5]][COLOR[4] * 12 + 9 +: 4];
assign FGD_G = PALETTE_REG[COLOR[7:5]][COLOR[4] * 12 + 5 +: 4];
assign FGD_B = PALETTE_REG[COLOR[7:5]][COLOR[4] * 12 + 1 +: 4];

assign BKG_R = PALETTE_REG[COLOR[3:1]][COLOR[0] * 12 + 9 +: 4];
assign BKG_G = PALETTE_REG[COLOR[3:1]][COLOR[0] * 12 + 5 +: 4];
assign BKG_B = PALETTE_REG[COLOR[3:1]][COLOR[0] * 12 + 1 +: 4];

logic IVn, orig_pix, act_pix;

// logic [10:0] sprite_addr;
// assign sprite_addr = {keycode[6:0], drawY[3:0]};
logic [7:0] sprite_data;
font_rom fr(.addr({charcode[6:0], drawY[3:0]}), .data(sprite_data));

assign org_pix = sprite_data[7 - drawX[2:0]];
assign IVn = charcode[7];
assign act_pix = org_pix ^ IVn;

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
        if ( ((drawX + 1) >= `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2 && drawX <= `CROSSWORD_RIGHT_EDGE + `LINE_WIDTH / 2) || // drawing right edge of crossword
             ((480 - (drawY + 1)) % `HORIZONTAL_DIV == 0 && drawX < `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2) || // drawing crossword grid horizontal lines)
             ((drawX + 1) % `VERTICAL_DIV == 0 && drawX < `CROSSWORD_RIGHT_EDGE - `LINE_WIDTH / 2 && drawY >= 50) // drawing crossword grid vertical lines
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

assign red = r;
assign green = g;
assign blue = b;

endmodule
