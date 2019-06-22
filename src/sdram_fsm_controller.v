// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : sdram_fsm_controller.v
// Module Name  : sdram_fsm_controller
// Description  : controller for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
// 2019/6/18	YYB			  2.0					  Original 
// *********************************************************************************
`timescale      1ns/1ns

module sdram_fsm_controller (
	input					clk			, 
	input					rst_n		,
	input					init_done   ,
	input					ref_done	,
	input					reftime_done,
	input					wr_done		,
	input					rd_done		,
	output		reg	[1:0]	sel			,
	output		reg			init_en		,
	output		reg			ref_en		,
	output		reg			reftime_en  ,
	output		reg			wr_en		,
	output		reg			rd_en		,
	input			[24:0]	local_addr	,
	input			[31:0]	local_wdata	,
	input					local_rdreq	,
	input					local_wrreq	,
	output		reg			local_ready	,
	output		reg			local_finish,
	output			[31:0]	local_rdata	,
	output			[1:0]	ba			,
	output			[12:0]	row			,
	output			[9:0]	col 		,
	input			[31:0]	rdata		,
	output			[31:0]	wdata
);
	
	reg [4:0] state;
	//========================================================================\
	// =========== Define Parameter and Internal signals =========== 
	//========================================================================/
	localparam			S0		=	5'b00001 ;
	localparam			S1		=	5'b00010 ;
	localparam			S2		=	5'b00100 ;
	localparam			S3		=	5'b01000 ;
	localparam			S4		=	5'b10000 ;
	localparam			INIT	=	0 ;
	localparam			REF		=	1 ;
	localparam			WR		=	2 ;
	localparam			RD		=	3 ;
	//=============================================================================
	//****************************     Main Code    *******************************
	//=============================================================================
	//ba,row,col are part of local_addr
	assign {ba,row,col} = local_addr;
	assign wdata = local_wdata;
	assign local_rdata = rdata;

	always @ (posedge clk)
	if(rst_n == 1'b0) begin
		init_en <= 0;
		ref_en <= 0;
        reftime_en <= 0;
        wr_en <= 0;
        rd_en <= 0;
        sel <= INIT;
        local_ready <= 0;
        local_finish <= 0;
        state <= S0;
	end
	else begin
	   case (state) 
	        S0:
	        	if (!init_done) begin
	        	    init_en <= 1;
	        	    sel <= INIT;
	        	    state <= S0;
	        	end
	        	else begin
	        	    init_en <= 0;
	        	    reftime_en <= 1;
	        	    sel <= REF;
	        	    state <= S1;
	        	end
	        S1:
	        	if (!reftime_done && !local_wrreq && !local_rdreq) begin
	        	    reftime_en <= 1;
	        	    state <= S1;
	        	end
	        	else if(reftime_done) begin
	        	    ref_en <= 1;
	        	    reftime_en <= 0;
	        	    sel <= REF;
	        	    state <= S2;		
	        	end
	        	else if(local_wrreq && !reftime_done) begin
	        		sel <= WR;
	        		local_ready <= 0;
	        		local_finish <= 0;
	        		reftime_en <= 1;
	        		wr_en <= 1;
	        		state <= S3;
	        	end
	        	else if(local_rdreq && !reftime_done) begin
	        		sel <= RD;
	        		local_finish <= 0;
	        		local_ready <= 0;
	        		reftime_en <= 1;
	        		rd_en <= 1;
	        		state <= S4;
	        	end
	        S2:
	        	if (!ref_done) begin
	        	    ref_en <= 1;
	        	    state <= S2;
	        	end
	        	else begin
	        	    reftime_en <= 1;
	        	    ref_en <= 0;
	        	    state <= S1;
	        	end
	        S3:
	        	if (!wr_done) begin
	        	    // wr_en <= 1;
	        	    wr_en <= 0;
	        	    state <= S3;
	        	end
	        	else begin
	        	    local_ready <= 1;
	        	    local_finish <= 1;
	        	    wr_en <= 0;
	        	    state <= S1;
	        	end
	        S4:
	        	if (!rd_done) begin
	        	    rd_en <= 1;
	        	    // rd_en <= 0;
	        	    state <= S4;
	        	end
	        	else begin
	        	    local_ready <= 1;
	        	    local_finish <= 1;
	        	    rd_en <= 0;
	        	    state <= S1;
	        	end
	    endcase 
	end
    
endmodule
