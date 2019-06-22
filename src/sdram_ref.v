// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : sdram_ref.v
// Module Name  : sdram_ref
// Description  : refresh for SDRAM 
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module sdram_ref (
	input					clk			, 
	input					rst_n		,
	output					ref_en	    ,
	output		reg			ref_done    ,
	output	[`BUS_W-1:0]	ref_bus	
);
	
	reg [3:0] state;
	reg sdram_cke;
	reg [`CMD_W-1:0] sdram_cmd;
	reg [`ADDR_W-1:0] sdram_a;
	reg [`ADDR_BA_W-1:0] sdram_ba; 
	reg [4:0] count;
	//========================================================================\
	// =========== Define Parameter and Internal signals =========== 
	//========================================================================/
	localparam			S0		=	4'b0001 ;
	localparam			S1		=	4'b0010 ;
	localparam			S2		=	4'b0100 ;
	localparam			S3		=	4'b1000 ;
	//=============================================================================
	//****************************     Main Code    *******************************
	//=============================================================================
	always @ (posedge clk)
	if(rst_n == 1'b0) begin
		ref_done <= 0;
		sdram_cke <= 1;
		sdram_cmd <= `NOP;
  		sdram_a <= 0;
  		sdram_ba <= 0;
  		count <= 0;
  		state <= S0;
	end
	else if(!ref_en)begin
	    ref_done <= 0;
		sdram_cke <= 1;
		sdram_cmd <= `NOP;
  		sdram_a <= 0;
  		sdram_ba <= 0;
  		count <= 0;
  		state <= S0; 
	end
	else begin
		case (state) 
		    S0:
		            begin
		     			state <= S1;
		     			count <= 0;
		     			sdram_a[10] <= 1;
		     			sdram_cmd <= `PRE;
		     			ref_done <= 0;	       	
		            end
		    S1:
		    		if (count < `TRP) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S1;
		    		end
		    		else begin
		    		    count <= 0;
		    		    sdram_cmd <= `REF;
		    		    state <= S2;
		    		end
		    S2:
		    		if (count < `TRFC - 1) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S2;
		    		end
		    		else begin
		    		    count <= 0;
		    		    ref_done <= 1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S3;
		    		end
		    S3:
		    		begin
		    			ref_done <= 0;
		    			state <= S3;
		    		end
		endcase
	end

	assign ref_bus = {sdram_cmd,sdram_cke,sdram_a,sdram_ba};

endmodule