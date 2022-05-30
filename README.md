# FPGA Crossword
Final project for ECE 385 - Digital Systems Laboratory \
Created by Wesley Wu and Karthik Prasad

## High-Level Overview
This project is a fully functional crossword game with 5 levels, each 5x5 letters, with “across” (horizontal) and “down” (vertical) clues which corresponded to each cell displayed based on which cell was currently being highlighted. In addition, we implemented a “check” button which allows the user to check which of the letters they have inputted into the puzzle thus far are correct as well as a “reveal” button which would place all the letters in their respective cells on the screen. Another element we included was the on-screen stopwatch as seen in the NYT version of crosswords.

## Hardware
We ran this game on the MAX10 DE10-Lite FPGA board from Intel by implementing a NIOS-II processor and using peripherals as well as an IP core for the text diaplay. We also implemented hardware highlighting logic to act upon the rising edge of a keypress and a simple state machine which told the VGA controller which screen (menu or crossword) to display based on completeness of the puzzle. We also implemented a hardware timer which would display the time elapsed since opening the puzzle on HEX displays.

Additionally, we wrote a python script to convert the puzzle clues to binary (ASCII) and place those into the on-chip memory using a memory initialization file.

## Software
We used C to write most of our game logic. In our C code, we first read the clues from the pre-initialized memory using pointer arithmetic. After reading the clues, we placed the letters corresponding to the clues in an array indicating the correct cell it belongs in. Then, inside the game loop, we counted the number of correct characters inputted so far and stopped the game and displayed the stopwatch on-screen once the user solved the puzzle (or revealed all of the clues).

## Demo Video

Link to demo video [here](https://drive.google.com/file/d/1genCxBSWYrUkiHsH-gXq6WMDfNf4uDSd/view?usp=sharing)!