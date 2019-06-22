// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/16 
// File Name    : sdram_controller.v
// Module Name  : sdram_controller
// Description  : controller for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/16    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module sdram_controller (
	//system signals
	input					ref_clk 		, 
	input					global_reset	,
	//interact signals
	input			[24:0]	local_addr		,
	input			[31:0]	local_wdata		,
	// input			[31:0]	rdata			,
	input					local_rdreq		,
	input					local_wrreq		,
	output					local_ready		,
	output					local_finish	,
	output			[31:0]	local_rdata		,
	//sdram signals
	output					sdram_clk		,
	output					sdram_cs_n		,
	output					sdram_ras_n 	,
	output					sdram_cas_n 	,
	output					sdram_we_n  	,
	output					sdram_cke   	,
	output			[12:0]	sdram_a 		,
	output			[1:0]	sdram_ba		,
	inout			[15:0]	sdram_dq	    ,
	output			[1:0]	sdram_dqm	 
);
	
	wire clk,rst_n,cap_clk;
	wire init_en,init_done;
	wire ref_en,ref_done;
	wire reftime_en,reftime_done;
	wire [`BUS_W-1:0] init_bus,ref_bus,wr_bus,rd_bus,sdram_bus;
	wire [1:0] sel;
	wire wr_en,wr_done;
	wire rd_en,rd_done;
	// wire [15:0] sdram_dq;
	wire [1:0] ba;
	wire [12:0] row;
	wire [9:0] col;
	wire [31:0] wdata;
	wire [31:0] rdata;
	wire [3:0] sdram_cmd;
	//========================================================================\
	// =========== Define Parameter and Internal signals =========== 
	//========================================================================/
	localparam			INIT		=	0 ;
	localparam			REF		    =	1 ;
	localparam			WR		    =	2 ;
	localparam			RD		    =	3 ;
	//=============================================================================
	//****************************     Main Code    *******************************
	//=============================================================================
	sdram_pll sdram_pll(
		.areset(global_reset),
		.inclk0(ref_clk),
		.c0(clk),
		.c1(sdram_clk),
		.c2(cap_clk),
		.locked(rst_n));
	
	sdram_init sdram_init(
		.clk(clk), 
		.rst_n(rst_n),
		.init_en(init_en),
		.init_done(init_done),
		.init_bus(init_bus));
	
	sdram_ref sdram_ref(
		.clk(clk), 
		.rst_n(rst_n),
		.ref_en(ref_en),
		.ref_done(ref_done),
		.ref_bus(ref_bus));

	ref_timer ref_timer(
		.clk(clk), 
		.rst_n(rst_n),
		.reftime_en(reftime_en),
		.reftime_done(reftime_done));

	sdram_fsm_controller sdram_fsm_controller(
		.clk(clk), 
		.rst_n(rst_n),
		.init_done(init_done),
		.ref_done(ref_done),
		.reftime_done(reftime_done),
		.wr_en(wr_en),
		.rd_en(rd_en),
		.sel(sel),
		.init_en(init_en),
		.ref_en(ref_en),
		.reftime_en(reftime_en),
		.wr_done(wr_done),
		.rd_done(rd_done),
		.local_addr(local_addr),
		.local_wdata(local_wdata),
		.rdata(rdata),
		.local_rdreq(local_rdreq),
		.local_wrreq(local_wrreq),
		.local_ready(local_ready),
		.local_finish(local_finish),
		.local_rdata(local_rdata),
		.ba(ba),
		.row(row),
		.col(col),
		.wdata(wdata));

	sdram_write sdram_write(
		.clk(clk), 
		.rst_n(rst_n),
		.wr_en(wr_en),
		.wr_done(wr_done),
		.ba(ba),
		.row(row),
		.col(col),
		.wdata(wdata),
		.wr_bus(wr_bus),
		.sdram_dq(sdram_dq)
	);

	sdram_read sdram_read(
		.clk(clk), 
		.cap_clk(cap_clk),
		.rst_n(rst_n),
		.rd_en(rd_en),
		.ba(ba),
		.row(row),
		.col(col),
		.rd_data(sdram_dq),
		.rdata(rdata),
		.rd_done(rd_done),
		.rd_bus(rd_bus));

	assign sdram_bus = (sel == INIT) ? init_bus : 
					   (sel == REF)  ? ref_bus  :
					   (sel == WR)   ? wr_bus   :
					   rd_bus;
	assign {sdram_cmd,sdram_cke,sdram_a,sdram_ba} = sdram_bus;
	assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd;
endmodule