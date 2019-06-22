// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : sdram_init_tb.v
// Module Name  : sdram_init_tb
// Description  : sim for sdram_init
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include   "../src/sdram_head.v"

module sdram_init_tb;
	reg					clk			; 
	reg					rst_n		;
	reg					init_en		;
	wire				init_done	;
	wire		[19:0]	init_bus    ;
	wire		[3:0]	sdram_cmd	;
	wire		[12:0]	sdram_a		;
	wire		[1:0]	sdram_ba	;
	wire				sdram_cke	;
	reg         [23:0] 	cmd_monitor ;
	wire sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n;
	
	//clk
	initial clk = 0;
	always #5 clk = ~clk;

	//rst_n & init_en
	initial begin
		rst_n = 0;
		init_en = 0;
		#13;
		rst_n = 1;	
		#13;
		init_en = 1;
		@ (posedge init_done)
			init_en = 0;				
	end

    sdram_init sdram_init(
		.clk			(clk), 
		.rst_n		 	(rst_n),
		.init_en		(init_en),
		.init_done		(init_done),
		.init_bus		(init_bus)	
	);

    assign {sdram_cmd, sdram_cke, sdram_a, sdram_ba} = init_bus;
    assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd;

    always @(*) begin
    	case (sdram_cmd) 
    	    `INH: cmd_monitor = "INH";
    	    `NOP: cmd_monitor = "NOP";
    	    `PRE: cmd_monitor = "PRE";
    	    `REF: cmd_monitor = "REF";
    	    `LMR: cmd_monitor = "LMR";
    	    default: cmd_monitor = "XXX";
    	endcase
    end

    mt48lc32m16a2 SDRAM(
    	.Dq(), 
    	.Addr(sdram_a), 
    	.Ba(sdram_ba), 
    	.Clk(clk), 
    	.Cke(sdram_cke), 
    	.Cs_n(sdram_cs_n), 
    	.Ras_n(sdram_ras_n), 
    	.Cas_n(sdram_cas_n), 
    	.We_n(sdram_we_n), 
    	.Dqm()
    );

endmodule