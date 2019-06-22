//head


//data width & addr width
`define DATA_W 16
`define ADDR_W 13
`define ADDR_BA_W 2
`define CMD_W 4
`define BUS_W `ADDR_W + `ADDR_BA_W + `CMD_W + 1


//timing
`define T100US 14'd9999
`define T200US 19999
`define TRP 1
`define TRFC 3'd7
`define TMRD 1
`define TRCD 1   //15ns,算出时间再-1
`define TREF 10'd760    //781.3

//command table
`define INH 4'b1xxx
`define NOP 4'b0111
`define ACT 4'b0011
`define RD  4'b0101
`define WR  4'b0100
`define TERMINAL 4'b0110
`define PRE 4'b0010
`define REF 4'b0001
`define LMR 4'b0000
`define CODE 13'b0000000100001

//sel
`define INIT 2'b00
`define REF 2'b01
`define RD 2'b10
`define WR 2'b11
