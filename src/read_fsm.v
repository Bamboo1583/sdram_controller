// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/18 
// File Name    : read_fsm.v
// Module Name  : read_fsm
// Description  : sub file for sdram_read
//				  cap is d-flip
//				  sync is two-reg
//				  chain is load reg
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/18    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module read_fsm (
	input					clk			, 
	input					rst_n		,
	input			[12:0]	row			,
	input			[9:0]	col 		,
	input			[1:0]	ba 			,
	input					rd_en		,
	output		reg			load_h		,
	output		reg			load_l		,
	output		reg			rd_done		,
	output			[19:0]	rd_bus		
);
	
	reg [6:0] state;
	reg [12:0] rd_a;
	reg [1:0] rd_ba;
	reg [3:0] rd_cmd;
	reg rd_cke ;
	reg [4:0] count;
	//========================================================================\
	// =========== Define Parameter and Internal signals =========== 
	//========================================================================/
	localparam			S0		=	7'b0000001 ;
	localparam			S1		=	7'b0000010 ;
	localparam			S2		=	7'b0000100 ;
	localparam			S3		=	7'b0001000 ;
	localparam			S4		=	7'b0010000 ;
	localparam			S5		=	7'b0100000 ;
	localparam			S6		=	7'b1000000 ;
	//=============================================================================
	//****************************     Main Code    *******************************
	//=============================================================================
	always @ (posedge clk)
	if(rst_n == 1'b0) begin
		rd_a <= 0;
		rd_ba <= 0;
		rd_cmd <= `NOP;
		rd_cke <= 1;
		rd_done <= 0;
		count <= 0;
		load_l <= 0;
		load_h <= 0;
		state <= S0;
	end
	else begin
		case (state) 
		    S0:
		        if (!rd_en) begin
		            state <= S0;
		        end
		        else begin
		            rd_cmd <= `ACT;
		            rd_a <= row;
		            rd_ba <= ba;
		            count <= 0;
		            rd_done <= 0;
		            state <= S1;
		        end
		    S1:
		        begin
		        	rd_cmd <= `NOP;
		        	state <= S2;
		        end
		    S2:
		    	if (count < `TRCD) begin
		    	    count <= count + 1'b1;
		    	    rd_cmd <= `NOP;
		    	    state <= S2;
		    	end
		    	else begin
		    	    // rd_cmd <= `RD;
		    	    rd_cmd <= 4'b0101;
		    	    rd_a[9:0] <= col;
		    	    rd_a[10] <= 1;
		    	    rd_ba <= ba;
		    	    count <= 0;
		    	    state <= S3;
		    	end
		    S3:
		    	if (count < 4-1) begin
		    	    count <= count + 1'b1;
		    	    rd_cmd <= `NOP;
		    	    state <= S3;
		    	end
		    	else begin
		    	    load_l <= 1;
		    	    count <= 0;
		    	    rd_cmd <= `NOP;
		    	    state <= S4;
		    	end
		    S4:
		    	begin
		    		load_l <= 0;
		    		load_h <= 1;
		    		rd_cmd <= `NOP;
		    		state <= S5;
		    	end
		    S5:	
		    	begin
		    		rd_done <= 1;
		    		load_h <= 0;
		    		rd_cmd <= `NOP;
		    		state <= S6;
		    	end
		    S6:
		    	begin
		    		rd_done <= 0;
		    		state <= S0;
		    	end
		endcase
	end

	assign rd_bus = {rd_cmd,rd_cke,rd_a,rd_ba};

endmodule

module cap (
	input					cap_clk			,
	input			[15:0]	rd_data			,
	output	reg		[15:0]	cap_data
);
	
	always @ (posedge cap_clk)
	begin
		cap_data <= rd_data;    
	end
    
endmodule

module sync (
	input					clk			, 
	input			[15:0]	cap_data	,
	output	reg		[15:0]	syn_data	
);

	reg [15:0] syn_data_reg;
	always @ (posedge clk)
	begin
		syn_data_reg <= cap_data;
		syn_data <= syn_data_reg;
	end

endmodule

module chain (
	input					clk			, 
	input					rd_en		,
	input					load_l		,
	input					load_h		,
	input			[15:0]	int_rd		,
	output		reg [31:0]	rdata 		
);

	// reg [31:0] rdata_reg;
	always @ (posedge clk)
	if (!rd_en) begin
	    rdata <= 0;
	end
	else begin 
		if(load_h)
		    rdata[31:16] <= int_rd;
		else if(load_l)
			rdata[15:0] <= int_rd;
	end

endmodule