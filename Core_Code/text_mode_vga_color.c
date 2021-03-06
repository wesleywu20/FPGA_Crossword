/*
 * text_mode_vga_color.c
 * Minimal driver for text mode VGA support
 * This is for Week 2, with color support
 *
 *  Created on: Oct 25, 2021
 *      Author: zuofu
 */

#include <system.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alt_types.h>
#include "text_mode_vga_color.h"
#include <stdio.h>
#include "system.h"
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "usb_kb/GenericMacros.h"
#include "usb_kb/GenericTypeDefs.h"
#include "usb_kb/HID.h"
#include "usb_kb/MAX3421E.h"
#include "usb_kb/transfer.h"
#include "usb_kb/usb_ch9.h"
#include "usb_kb/USB.h"
#include "time.h"

void textVGAColorClr() {
	for (int i = 0; i < (ROWS * COLUMNS) * 2; i++) {
		vga_ctrl->VRAM[i] = 0x00;
	}
}

void textVGADrawColorText(char* str, double x, double y, alt_u8 background,
		alt_u8 foreground) {
	int i = 0;
	while (str[i] != 0) {
		vga_ctrl->VRAM[((int) (y) * COLUMNS + (int) (x) + i) * 2] = foreground
				<< 4 | background;
		vga_ctrl->VRAM[((int) (y) * COLUMNS + (int) (x) + i) * 2 + 1] = str[i];
		i++;
	}
}

void setColorPalette(alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue) {
	//fill in this function to set the color palette starting at offset 0x0000 2000 (from base)
	int regIdx = color >> 1;
	int i;
	if (color % 2 == 0) { // setting the right color in a register
		vga_ctrl->palette[regIdx] &= ~(0xFFF << 1);
		for (i = 1; i <= 4; i++) {
			vga_ctrl->palette[regIdx] |= (((blue >> (i - 1)) & 1) << i);
		}
		for (i = 5; i <= 8; i++) {
			vga_ctrl->palette[regIdx] |= (((green >> (i - 5)) & 1) << i);
		}
		for (i = 9; i <= 12; i++) {
			vga_ctrl->palette[regIdx] |= (((red >> (i - 9)) & 1) << i);
		}
	} else {
		vga_ctrl->palette[regIdx] &= ~(0xFFF << 13);
		for (i = 13; i <= 16; i++) {
			vga_ctrl->palette[regIdx] |= (((blue >> (i - 13)) & 1) << i);
		}
		for (i = 17; i <= 20; i++) {
			vga_ctrl->palette[regIdx] |= (((green >> (i - 17)) & 1) << i);
		}
		for (i = 21; i <= 24; i++) {
			vga_ctrl->palette[regIdx] |= (((red >> (i - 21)) & 1) << i);
		}
	}
}

void runGame() 
{

	int prevkeycode = 0;
	printf("initializing MAX3421E...\n");
	MAX3421E_init();
	printf("initializing USB...\n");
	USB_init();

	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++) {
		setColorPalette(i, colors[i].red, colors[i].green, colors[i].blue);
	}
	volatile unsigned int *reset_game = (unsigned int*) RESET_GAME_BASE;
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report
	BOOT_KBD_REPORT kbdbuf;

	BYTE runningdebugflag = 0;//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; //flag once we get an error device so we don't keep dumping out state info
	BYTE device;
	WORD keycode;
	clock_t start, end;
	rcode = kbdPoll(&kbdbuf);
	int kcode = kbdbuf.keycode[0];
	int loopcounter = 0;
	int crossword_select = 0;
	int fg, bg, x, y;
	fg = 0;
	bg = 15;
	int currX = 5;
	int currY = 7;

	IOWR_ALTERA_AVALON_PIO_DATA(SW_RESET_BASE, 1);
	IOWR_ALTERA_AVALON_PIO_DATA(SW_RESET_BASE, 0);


	while(1){
	printf("in limbo \n");
	printf("reset state %d\n", *reset_game);
	printf("keycode %d\n", kcode);
	printf("loopcounter %d\n", loopcounter);
	usleep(18000);
	rcode = kbdPoll(&kbdbuf);
	int kcode = kbdbuf.keycode[0];
	if (*reset_game) {
		printf("keycode %d\n", kcode);
			while(kcode == 0){
				MAX3421E_Task();
				USB_Task();
				printf("Waiting for menu \n");
				rcode = kbdPoll(&kbdbuf);
				kcode = kbdbuf.keycode[0];
				IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, kcode);
				textVGADrawColorText ("Mini Crossword Puzzles on FPGA", 24, 13, fg, bg);
				textVGADrawColorText ("Implementation by Wesley Wu and Karthik Prasad", 16, 14, fg, bg);
				textVGADrawColorText ("Press a number corresponding to which crossword you want, then press enter", 3, 16, fg, bg);
				textVGADrawColorText ("Enter a number from 1-5 only", 25, 17, fg, bg);
				textVGADrawColorText ("To reveal all of the letters, press * on the numpad", 13, 18, fg, bg);
				textVGADrawColorText ("To check the letters you have inputted thus far, press / on the numpad", 4, 19, fg, bg);
				if(kcode != 0)
				crossword_select = kcode-30;
				printf("keycode %d\n", kcode);
			}
			printf("%d\n", crossword_select);
		int memoffset = crossword_select * 1007;
		while(kcode != 40 && loopcounter){
			//printf("In Menu \n");
			MAX3421E_Task();
			USB_Task();
			rcode = kbdPoll(&kbdbuf);
			kcode = kbdbuf.keycode[0];
			IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, kcode);
			textVGADrawColorText ("Mini Crossword Puzzles on FPGA", 24, 13, fg, bg);
			textVGADrawColorText ("Implementation by Wesley Wu and Karthik Prasad", 16, 14, fg, bg);
			textVGADrawColorText ("Press a number corresponding to which crossword you want, then press enter", 3, 16, fg, bg);
			textVGADrawColorText ("Enter a number from 1-5 only", 25, 17, fg, bg);
			textVGADrawColorText ("To reveal all of the letters, press * on the numpad", 13, 18, fg, bg);
			textVGADrawColorText ("To check the letters you have inputted thus far, press / on the numpad", 4, 19, fg, bg);
		}
		textVGAColorClr();
		loopcounter++;

//while(1){
		//char clues [10][50] = {"Wooden strips for a window blind", "Colorful spring bulb", "Bring together", "Story from Aesop", "Like much ballpark food", "Pack in tightly", "Moon-related", "Excuse for a criminal suspect", "Dropdown menu with options like Dr. and Mrs.", "Go 80 in a 55, say"};
		int answers[5][5];

//		{ { 'S', 'L', 'A', 'T', 'S' }, { 'T', 'U', 'L', 'I',
//				'P' }, { 'U', 'N', 'I', 'T', 'E' }, { 'F', 'A', 'B', 'L', 'E' },
//				{ 'F', 'R', 'I', 'E', 'D' } };

		// volatile unsigned int *MOVE_HL_READY = (unsigned int*)MOVE_HL_BASE;
		unsigned int *PUZZLE_MEM = (unsigned int*) PUZZLE_CLUES_MEM_BASE;

		IOWR_ALTERA_AVALON_PIO_DATA(SW_RESET_BASE, 1);
		IOWR_ALTERA_AVALON_PIO_DATA(SW_RESET_BASE, 0);
		int keypressCount = 0;

		int countCorrect = 0;

//	*SW_Start = 1;
		highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 1;
		char clues[10][400];

		int currLine;
		currLine = *(PUZZLE_MEM);
		 //for(int k = 0; k < 10; k++){
//		 for (unsigned int j = 1; j < 1000; j++) {
//		 char curr_string[100];
//		 memset(curr_string, '\0', 100);
//		 int currLine = *(PUZZLE_MEM + j);
//		 printf("%d: %d @ %x\n", j, currLine, PUZZLE_MEM + j);
//		 //	 	printf("%d\n", j);
//		 for (int i = 0; i < 4; i++) {
//		 //if (currLine == 0) break;
//		 int currRead = (currLine & 4278190080) >> 24;
//		 currLine = currLine << 8;
//		 //color_string[(j - 1) * 4 + i] = currRead;
//		 curr_string[i] = currRead;
//
//		 }
//		 printf("%s\n", curr_string);
//		 }

		currLine = *(PUZZLE_MEM);

		for (int k = 0; k < 10; k++) {
			char color_string[400];
			for (unsigned int j = 0; j < 50; j++) {
				char curr_string[400];
				memset(curr_string, '\0', 100);
				//memset(color_string, '\0', 100);
				currLine = *(PUZZLE_MEM + j + 100 * k + memoffset);
				printf("%d: %d @ %x\n", j, currLine, PUZZLE_MEM + j + 100 * k + memoffset);
				for (int i = 0; i < 4; i++) {
				//	printf("%d\n", i);
					int currRead = (currLine & 4278190080) >> 24;
					currLine = currLine << 8;
					color_string[(j - 1) * 4 + i] = currRead;
					curr_string[i] = currRead;

				}
				printf("%s\n", curr_string);

			}
			printf("%s\n", color_string);
			strcpy(clues[k], color_string);

		if(k == 9){
			for (int x = 0; x < 8; x++){
				currLine = *(PUZZLE_MEM + 100 + x + 100 * k + memoffset);
				printf("%d: %d @ %x\n", 2, currLine, PUZZLE_MEM + 100 + x + 100 * k + memoffset);
				if( x > 0)
				for (int i = 0; i < 4; i++) {
					int currRead = (currLine & 4278190080) >> 24;
					currLine = currLine << 8;
					printf("%c", currRead);
					answers[((x-1) * 4 + i) / 5][((x-1) * 4 + i) % 5] = currRead;
					if(currRead == 0) break;

			}
			}
		}
		}
		printf("passed");

		//printf("%s", color_string);
		//}


		 IOWR_ALTERA_AVALON_PIO_DATA(WIN_BASE, 0);
		 for(int i = 0; i < 5; i++){
			 for(int j = 0; j < 5; j++){
				 letters[i][j] = 32;
			 }
		 }
		 int check = 0;

		 while(countCorrect < 25)
		 {
		 countCorrect = 0;
		 //		printf("%d\n", *PUZZLE_MEM);
		 //		printf("%s\n", color_string);

		 MAX3421E_Task();
		 USB_Task();
		 rcode = kbdPoll(&kbdbuf);
		 int kcode = kbdbuf.keycode[0];
		 IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, kcode);
		 printf("keycode: %d\n", kcode);
		 IOWR_ALTERA_AVALON_PIO_DATA(STOPWATCH_BASE, 1);
		 printf("prevkeycode: %d\n", prevkeycode);


	     if(check == 1 && kcode == 84 && prevkeycode != kcode)
	     {
	    	 check = 0;
	     	printf("press to turn off check");
	     }
	     else if(kcode == 84 && prevkeycode != kcode && check == 0){
			check = 1;
			printf("press to turn on check");
		 }

		 printf("%d\n", check);

		 if (kcode == RIGHT && currX < 40 && prevkeycode != kcode) {
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 0;
		 currX += 10;
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 1;
		 prevkeycode = kcode;
		 }
		 else if (kcode == DOWN && currY < 25 && prevkeycode != kcode) {
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 0;
		 currY += 5;
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 1;
		 prevkeycode = kcode;

		 }
		 else if (kcode == LEFT && currX > 5 && prevkeycode != kcode) {
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 0;
		 currX -= 10;
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 1;
		 prevkeycode = kcode;
		 }
		 else if (kcode == UP && currY > 7 && prevkeycode != kcode) {
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 0;
		 currY -= 5;
		 highlight[(currY - 2) / 5 - 1][(currX - 5) / 10] = 1;
		 prevkeycode = kcode;
		 }
		 else
			 prevkeycode = kcode;



		 switch(kcode) {
		 case A:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'A';
		 break;
		 case B:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'B';
		 break;
		 case C:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'C';
		 break;
		 case D:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'D';
		 break;
		 case E:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'E';
		 break;
		 case F:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'F';
		 break;
		 case G:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'G';
		 break;
		 case H:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'H';
		 break;
		 case I:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'I';
		 break;
		 case J:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'J';
		 break;
		 case K:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'K';
		 break;
		 case L:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'L';
		 break;
		 case M:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'M';
		 break;
		 case N:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'N';
		 break;
		 case O:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'O';
		 break;
		 case P:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'P';
		 break;
		 case Q:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'Q';
		 break;
		 case R:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'R';
		 break;
		 case S:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'S';
		 break;
		 case T:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'T';
		 break;
		 case U:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'U';
		 break;
		 case V:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'V';
		 break;
		 case W:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'W';
		 break;
		 case X:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'X';
		 break;
		 case Y:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'Y';
		 break;
		 case Z:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = 'Z';
		 break;
		 case BKSP:
		 letters[((currY - 2) / 5 - 1)][(currX - 5) / 10] = ' ';
		 break;
		 default:
		 prevkeycode = kcode;
		 break;


		 }
		 if(kcode == 85){
			 for(int i = 0; i < 5; i++) {
				 for (int j = 0; j < 5; j++) {
					 letters[i][j] = answers[i][j];
				 }
			 }
		 }


		 for(int i = 0; i < 5; i++) {
			 for (int j = 0; j < 5; j++) {
		 //char character = (char)letters[i][j];
				 if(check == 0)
				 textVGADrawColorText (&letters[i][j], j * 10 + 5, (i + 1) * 5 + 2, bg, fg);
				 if(check == 1){
					 if(letters[i][j] == answers[i][j])
						 textVGADrawColorText (&letters[i][j], j * 10 + 5, (i + 1) * 5 + 2, bg, 10);
					 else
						 textVGADrawColorText (&letters[i][j], j * 10 + 5, (i + 1) * 5 + 2, bg, fg);

				 }
				 printf("%c ", letters[i][j]);
				 //printf("%s ", character);

				 if (highlight[i][j]) {
				//  textVGADrawColorText ("                                               ", 0, 0, bg, fg);
				 textVGADrawColorText ("Across:", 0, 0, bg, fg);
				 textVGADrawColorText (clues[i], 0, 1, bg, fg);
//				 printf("Across: %s\n", clues[i]);
				//  textVGADrawColorText ("                                               ", 0, 2, bg, fg);
				 textVGADrawColorText ("Down:", 0, 3, bg, fg);
				 textVGADrawColorText (clues[j + 5], 0, 4, bg, fg);
//				 printf("Down: %s\n", clues[j + 5]);
				 }
				 if (letters[i][j] == answers[i][j]) countCorrect++;



				 }
			 printf("\n");
			 }
//		 printf("countCorrect: %d\n", countCorrect);
		 if(countCorrect == 24)
			textVGADrawColorText ("One letter off!", 51, 8, bg, fg);
		 else
			 textVGADrawColorText ("                 ", 51, 8, bg, fg);



		 //		usleep(18000);
		 }
		 IOWR_ALTERA_AVALON_PIO_DATA(STOPWATCH_BASE, 0);
		 printf("win\n");
		volatile unsigned int *timer = (unsigned int*) SW_DIGITS_BASE;
		 int minsTens = (*timer & 61440) >> 12;
		 int minsOnes = (*timer & 3840) >> 8;
		 int secsTens = (*timer & 240) >> 4;
		 int secsOnes = (*timer & 15);
		 char time_str [30];
		 printf("minutes: %d%d\n", minsTens, minsOnes);
		 printf("seconds: %d\%dn", secsTens, secsOnes);
		 sprintf(time_str, "Solved crossword in: %d%d:%d%d", minsTens, minsOnes, secsTens, secsOnes % 10);
		 textVGADrawColorText ("Press Enter to return to menu", 51, 5, bg, fg);
		 textVGADrawColorText (time_str, 51, 8, bg, fg);

		 rcode = kbdPoll(&kbdbuf);
		 int kcode = kbdbuf.keycode[0];
		 IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, kcode);
		 while(kcode != 40){
		 rcode = kbdPoll(&kbdbuf);
		 kcode = kbdbuf.keycode[0];
		 IOWR_ALTERA_AVALON_PIO_DATA(KEYCODE_BASE, kcode);
		 }
		 printf("done");
		 IOWR_ALTERA_AVALON_PIO_DATA(WIN_BASE, 1);
		 textVGAColorClr();;
		 }
		 }
}
		 //}
		 //}
		 //	for(int i = 0; i < 5; i++) {
		 //		for (int j = 0; j < 5; j++) {
		 //			char character [2] = {(char)letters[i][j], ' '};
		 //			textVGADrawColorText (character, j * 10 + 5, (i + 1) * 5 + 2, bg, fg);
		 //			printf("%c ", letters[i][j]);
		 //			if (highlight[i][j]) {
		 //						textVGADrawColorText ("                                               ", 0, 0, bg, fg);
		 //				textVGADrawColorText (clues[i], 0, 0, bg, fg);
		 //						textVGADrawColorText ("                                               ", 0, 2, bg, fg);
		 //				textVGADrawColorText (clues[j + 5], 0, 2, bg, fg);
		 //			}
		 //			if (letters[i][j] == answers[i][j]) countCorrect++;
		 //		}
		 //		printf("\n");

void keyToText() {
	char guess[5];
	int fg, bg, x, y;
	textVGAColorClr();
	//initialize palette
	for (int i = 0; i < 16; i++) {
		setColorPalette(i, colors[i].red, colors[i].green, colors[i].blue);
		//printf("Palette %d : %x\n", i, vga_ctrl->palette[i>>1]>>1);
	}

	while (1) {
		printf("Hello\n");
		char one_char[2] = "A";
		x = 25;
		y = 65;
		fg = 0;
		bg = 15;
		textVGADrawColorText(one_char, x, y, bg, fg);
		usleep(100000);
	}
}

