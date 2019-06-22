// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : sdram_controller_tb.v
// Module Name  : sdram_controller_tb
// Description  : sim for sdram_controller
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
// 2019/6/18	YYB			  2.0					  Original	
// *********************************************************************************
`timescale      1ns/1ns
`include "../src/sdram_head.v"

module sdram_controller_tb;
	reg					ref_clk 			; 
	reg					global_reset		;
	reg			[24:0]	local_addr			;
	reg			[31:0]	local_wdata			;
	reg					local_rdreq			;
	reg					local_wrreq			;
	wire				local_ready			;
	wire				local_finish		;
	wire		[31:0]	local_rdata			;
	wire				sdram_clk			;
	wire				sdram_cs_n			;
	wire				sdram_ras_n 		;
	wire				sdram_cas_n 		;
	wire				sdram_we_n  		;
	wire				sdram_cke   		;
	wire		[12:0]	sdram_a 			;
	wire		[1:0]	sdram_ba			;
	wire		[15:0]	sdram_dq	    	;
	wire		[1:0]	sdram_dqm	 		;
	wire 		[3:0]   sdram_cmd  			;
	reg			[23:0]  cmd_monitor			;

	//ref_clk
	initial ref_clk = 0;
	always #10 ref_clk = ~ref_clk;

	//global_reset
	initial begin
		global_reset = 1;
		local_addr = 0;
		local_wdata = 0;
		local_rdreq = 0;
		local_wrreq = 0;
		#13;
		global_reset = 0;
		#250000;
		local_addr = 25'haaaa;
		local_wdata = 32'h11112222;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 1;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 0;
		@(posedge local_finish)
		#120;

		local_addr = 25'haaaa;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 1;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 0;
		#120;

		local_addr = 25'hbbbb;
		local_wdata = 32'h33334444;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 1;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 0;
		@(posedge local_finish)
		#120;

		local_addr = 25'hbbbb;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 1;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 0;	
		#120;

		local_addr = 25'hcccc;
		local_wdata = 32'h55556666;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 1;
		@(posedge sdram_controller.sdram_write.clk)
			local_wrreq = 0;
		@(posedge local_finish)
		#120;

		local_addr = 25'hcccc;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 1;
		@(posedge sdram_controller.sdram_read.clk)
			local_rdreq = 0;	
		#120;
	end

	sdram_controller sdram_controller(
		.ref_clk 		(ref_clk), 
		.global_reset	(global_reset),
		.local_addr		(local_addr),
		.local_wdata	(local_wdata),
		.local_rdreq	(local_rdreq),
		.local_wrreq	(local_wrreq),
		.local_ready	(local_ready),
		.local_finish	(local_finish),
		.local_rdata	(local_rdata),
		.sdram_clk		(sdram_clk),
		.sdram_cs_n		(sdram_cs_n),
		.sdram_ras_n 	(sdram_ras_n),
		.sdram_cas_n 	(sdram_cas_n),
		.sdram_we_n  	(sdram_we_n),
		.sdram_cke   	(sdram_cke),
		.sdram_a 		(sdram_a),
		.sdram_ba		(sdram_ba),
		.sdram_dq	    (sdram_dq),
		.sdram_dqm	 	(sdram_dqm)
	);

	// assign {sdram_cmd,sdram_cke,sdram_a,sdram_ba} = sdram_bus;
	assign sdram_cmd = {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n};

	always @(*) begin
    	case (sdram_cmd) 
    	    `INH: cmd_monitor = "INH";
    	    `NOP: cmd_monitor = "NOP";
    	    `PRE: cmd_monitor = "PRE";
    	    `REF: cmd_monitor = "REF";
    	    `LMR: cmd_monitor = "LMR";
    	    `ACT: cmd_monitor = "ACT";
    	    `RD : cmd_monitor = "RD";
    	    `WR : cmd_monitor = "WR";
    	    4'b0100:cmd_monitor = "WR";
    	    4'b0101:cmd_monitor = "RD";
    	    default: cmd_monitor = "XXX";
    	endcase
    end

    mt48lc32m16a2 SDRAM(
    	.Dq(sdram_dq), 
    	.Addr(sdram_a), 
    	.Ba(sdram_ba), 
    	.Clk(sdram_clk), 
    	.Cke(sdram_cke), 
    	.Cs_n(sdram_cs_n), 
    	.Ras_n(sdram_ras_n), 
    	.Cas_n(sdram_cas_n), 
    	.We_n(sdram_we_n), 
    	.Dqm(0)
    );
    
endmodule