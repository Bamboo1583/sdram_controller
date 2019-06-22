// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/18 
// File Name    : sdram_read.v
// Module Name  : sdram_read
// Description  : read for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/18    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module sdram_read (
	input					clk			, 
	input					cap_clk		,
	input					rst_n		,
	input					rd_en		,
	input			[1:0]	ba			,
	input			[12:0]	row			,
	input			[9:0]	col			,
	input			[15:0]	rd_data		,
	output			[31:0]	rdata		,
	output					rd_done		,
	output			[19:0]	rd_bus		
);

	wire [15:0] cap_data;
	wire [15:0] syn_data;
	wire load_l,load_h;
	wire [31:0] rdata_reg;
	//=============================================================================
	//****************************     Main Code    *******************************
	//=============================================================================
	cap cap(
		.cap_clk		(cap_clk),
		.rd_data		(rd_data),
		.cap_data		(cap_data)
	);

	sync sync(
		.clk			(clk), 
		.cap_data		(cap_data),
		.syn_data		(syn_data)
	);

	chain chain(
		.clk		    (clk), 
		.rd_en		    (rd_en),
		.load_l		    (load_l),
		.load_h		    (load_h),
		.int_rd		    (syn_data),
		.rdata 		    (rdata_reg)
		// .rdata 		    (rdata)
	);

	read_fsm read_fsm(
		.clk			(clk), 
		.rst_n			(rst_n),
		.row			(row),
		.col 			(col),
		.ba 			(ba),
		.rd_en  		(rd_en),
		.load_h			(load_h),
		.load_l			(load_l),
		.rd_done		(rd_done),
		.rd_bus			(rd_bus)
	);

	assign rdata = (rd_done && rd_en) ? rdata_reg : 32'hzzzzzzzz ;

endmodule