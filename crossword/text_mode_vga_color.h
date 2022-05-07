/*
 *  text_mode_vga.h
 *	Minimal driver for text mode VGA support, ECE 385 Summer 2021 Lab 6
 *  You may wish to extend this driver for your final project/extra credit project
 * 
 *  Created on: Jul 17, 2021
 *      Author: zuofu
 */

#ifndef TEXT_MODE_VGA_COLOR_H_
#define TEXT_MODE_VGA_COLOR_H_

#define COLUMNS 80
#define ROWS 30

#define A 4
#define B 5
#define C 6
#define D 7
#define E 8
#define F 9
#define G 10
#define H 11
#define I 12
#define J 13
#define K 14
#define L 15
#define M 16
#define N 17
#define O 18
#define P 19
#define Q 20
#define R 21
#define S 22
#define T 23
#define U 24
#define V 25
#define W 26
#define X 27
#define Y 28
#define Z 29

#define BKSP 42

#define RIGHT 79
#define LEFT 80
#define DOWN 81
#define UP 82

#include <system.h>
#include <alt_types.h>

struct TEXT_VGA_STRUCT {
	alt_u8 VRAM [ROWS*COLUMNS*2]; //Week 2 - extended VRAM
	//modify this by adding const bytes to skip to palette, or manually compute palette
	const alt_u8 reserve[3391];
	alt_u32 palette[8];
};

struct COLOR{
	char name [20];
	alt_u8 red;
	alt_u8 green;
	alt_u8 blue;
};

int letters [5][5];
int highlight [5][5];
// char clues [10][50];
//you may have to change this line depending on your platform designer
static volatile struct TEXT_VGA_STRUCT* vga_ctrl = VGA_TEXT_MODE_CONTROLLER_0_BASE;


struct PUZZLE_MEM_STRUCT {
	alt_u32 CLUES_1 [1000];
	alt_u32 reserve [7192];
};

//CGA colors with names
static struct COLOR colors[]={
    {"black",          0x0, 0x0, 0x0},
	{"blue",           0x0, 0x0, 0xa},
    {"green",          0x0, 0xa, 0x0},
	{"cyan",           0x0, 0xa, 0xa},
    {"red",            0xa, 0x0, 0x0},
	{"magenta",        0xa, 0x0, 0xa},
    {"brown",          0xa, 0x5, 0x0},
	{"light gray",     0xa, 0xa, 0xa},
    {"dark gray",      0x5, 0x5, 0x5},
	{"light blue",     0x5, 0x5, 0xf},
    {"light green",    0x5, 0xf, 0x5},
	{"light cyan",     0x5, 0xf, 0xf},
    {"light red",      0xf, 0x5, 0x5},
	{"light magenta",  0xf, 0x5, 0xf},
    {"yellow",         0xf, 0xf, 0x5},
	{"white",          0xf, 0xf, 0xf}
};


void textVGAColorClr();
void keyToText();
void textVGADrawColorText(char* str, double x, double y, alt_u8 background, alt_u8 foreground);
void setColorPalette (alt_u8 color, alt_u8 red, alt_u8 green, alt_u8 blue); //Fill in this code
void runGame();
void textVGAColorScreenSaver(); //Call this for your demo


#endif /* TEXT_MODE_VGA_COLOR_H_ */
