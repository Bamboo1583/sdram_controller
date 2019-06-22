// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : sdram_write.v
// Module Name  : sdram_write
// Description  : write for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns
`include "sdram_head.v"

module sdram_write (
	input					clk			, 
	input					rst_n		,
	input					wr_en	    ,
	output			reg		wr_done		,
	input			[1:0]	ba			,
	input			[12:0]	row			,
	input			[9:0]	col			,
	input			[31:0]	wdata		,
	output			[19:0]	wr_bus		,
	output			[15:0]	sdram_dq
);

	reg [3:0] wr_cmd;
	reg [12:0] wr_a;
	reg [1:0] wr_ba;
	reg wr_cke ;
	reg dq_en; 
	reg [4:0] count;
	reg [3:0] state;
	reg [15:0] wr_data;
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
		wr_done <= 0;
		wr_cmd <= `NOP;
		wr_a <= 0;
		wr_ba <= 0;
		wr_cke <= 1;
		dq_en <= 0;
		wr_data <= 0;
		count <= 0;
		state <= S0;
	end
	else begin
		case (state) 
			S0:
				if (!wr_en) begin
				    state <= S0;
				end
				else begin
				    wr_cmd <= `ACT;
				    wr_a <= row;
				    wr_ba <= ba;
				    wr_done <= 0;
				    state <= S1;
				end
		    S1:
		        if (count < `TRCD) begin
		            count <= count + 1'b1;
		            wr_cmd <= `NOP;
		            state <= S1;
		        end
		        else begin
		            wr_a[9:0] <= col;
		            // wr_cmd <= `WR;
		            wr_cmd <= 4'b0100;
		            count <= 0;
		            wr_a[10] <= 1;
		            wr_data <= wdata[15:0];
		            dq_en <= 1;
		            state <= S2;
		        end
		    S2:
		    	begin
		    		wr_cmd <= `NOP;
		    		wr_data <= wdata[31:16];
		    		state <= S3;
		    	end
		    S3:
		    	begin
		    		wr_done <= 1;
		    		dq_en <= 0;
		    		state <= S0;
		    	end
		endcase
	end

	assign wr_bus = {wr_cmd,wr_cke,wr_a,wr_ba};
	assign sdram_dq = (dq_en) ? wr_data : 16'dz;

endmodule