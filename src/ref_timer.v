// *********************************************************************************
// Project Name : sdram_controller
// Create Date  : 2019/6/17 
// File Name    : ref_timer.v
// Module Name  : ref_timer
// Description  : refresh timer for SDRAM
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2019/6/17    YYB           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module ref_timer (
	input					clk			, 
	input					rst_n		,
	input					reftime_en  ,
	output					reftime_done
);

	localparam	CNT_MAX		=	 1562  - 1 - 11;

	reg [10:0] count;

	always @ (posedge clk)
    if(rst_n == 1'b0) begin
    	count <= 0;
    end
    else if (!reftime_en) begin
        count <= 0;
    end
    else if(count >= CNT_MAX)
    	count <= 0;
    else begin
     	count <= count + 1'b1;
    end

    assign reftime_done = (count == CNT_MAX) ? 1'b1 : 1'b0;

endmodule
