// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/16 
// File Name    : sdram_init.v
// Module Name  : sdram_init
// Description  : init for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/16    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module sdram_init (
	input					clk			, 
	input					rst_n		,
	input					init_en		,
	output		reg			init_done	,
	output			[19:0]	init_bus	
);
	
	reg sdram_cke;
	reg [3:0] sdram_cmd;
	reg [12:0] sdram_a;
	reg [1:0] sdram_ba; 
	reg [14:0] count;
	reg [6:0] state;
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
		init_done <= 0;
		sdram_cke <= 0;
		sdram_cmd <= `INH;
		sdram_a <= 0;
		sdram_ba <= 0;
		count <= 0;
	end
	else if(!init_en)begin
		init_done <= 0;
		sdram_cke <= 0;
		sdram_cmd <= `INH;
		sdram_a <= 0;
		sdram_ba <= 0;
		count <= 0;
	    state <= S0;
	end
	else begin
		case (state) 
		    S0:
		            if (count < `T200US) begin //之后将T100US改为T200US
		                count <= count + 1'b1;
		                init_done <= 0;
		                state <= S0;
		            end
		            else begin
		                count <= 0;
		                sdram_cke <= 1;
		                sdram_cmd <= `NOP;
		                state <= S1;
		            end
		    S1:
		            begin
		            	sdram_a[10] <= 1;
		            	sdram_cmd <= `PRE;
		            	state <= S2;
		            end
		    S2:
		    		if (count < `TRP) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S2;
		    		end
		    		else begin
		    		    count <= 0;
		    		    sdram_cmd <= `REF;
		    		    state <= S3;
		    		end
		    S3:
		    		if (count < `TRFC - 1) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S3;
		    		end
		    		else begin
		    		    count <= 0;
		    		    sdram_cmd <= `REF;
		    		    state <= S4;
		    		end
		    S4:
		    		if (count < `TRFC - 1) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S4;
		    		end
		    		else begin
		    		    count <= 0;
		    		    sdram_cmd <= `LMR;
		    		    sdram_a <= `CODE;
		    		    sdram_ba <= 0;
		    		    state <= S5;
		    		end
		    S5:
		    		if (count < `TMRD) begin
		    		    count <= count + 1'b1;
		    		    sdram_cmd <= `NOP;
		    		    state <= S5;
		    		end
		    		else begin
		    		    count <= 0;
		    		    init_done <= 1;
		    		    state <= S6;
		    		end
		    S6:
		    		begin
						init_done <= 0;
						state <= S6;		    			
		    		end
		endcase
	end
    
	assign init_bus = {sdram_cmd, sdram_cke, sdram_a, sdram_ba};

endmodule