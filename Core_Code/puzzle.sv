module puzzle(input CLK, input RESET,
              input [12:0] AVL_ADDR,
              input [3:0] AVL_BYTE_EN,
              input AVL_CS,
              input AVL_READ,
              input AVL_WRITE,
              output [31:0] AVL_READDATA,
              input [31:0] AVL_WRITEDATA);

// module test (
// 	address_a,
// 	address_b,
// 	byteena_a,
// 	byteena_b,
// 	clock,
// 	data_a,
// 	data_b,
// 	rden_a,
// 	rden_b,
// 	wren_a,
// 	wren_b,
// 	q_a,
// 	q_b);

// input	[3:0]  byteena_a;
// input	  clock;
// input	[31:0]  data;
// input	[12:0]  rdaddress;
// input	  rden;
// input	[12:0]  wraddress;
// input	  wren;
// output	[31:0]  q;

puzzle_ocm ram(.byteena_a(AVL_BYTE_EN),
               .clock(CLK),
               .data(AVL_WRITEDATA),
               .rdaddress(AVL_ADDR),
               .rden(AVL_READ),
               .wraddress(AVL_ADDR),
               .wren(AVL_WRITE),
               .q(AVL_READDATA));

endmodule