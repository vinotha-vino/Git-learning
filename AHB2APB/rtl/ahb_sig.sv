//AHB FOR ADDRESS AND DATA PHASE
module ahb_sig(input clk, rst_n,
	       input trans_t HTRANS,
	       input [1:0] HSIZE,
	       input HWRITE,
	       input [`WIDTH-1:0] HADDR,
	       input fsm_error, fsm_ready,
	       output HWRITE_r, PSEL_r,
	       output [`WIDTH-1:0] HADDR_r, 
	       //output [3:0] HSTRB_r,
	       //input [3:0] HSTRB,
	       output HRESP, HREADY);

       //LOCAL FLOP SIGNALS
       reg [`WIDTH-1:0] HADDR_f;
       reg HWRITE_f, HSEL_f;

       //FLOP ADDRESS PHASE
       always @(posedge clk or negedge rst_n) begin
	       if(!rst_n) begin
		       HADDR_f <= 'b0;
		       HWRITE_f <= 'b0;
		       HSEL_f <= 'b0;
		       HWRITE_f <= 'b0;
	       end
	       else begin
		       //ADDRESS PHASE
		       if(HTRANS == NON_SEQ) begin
			       HSEL_f <= 'b1;
			       HWRITE_f <= HWRITE;
			       HADDR_f <= HADDR;
			       //HSTRB_f <= HSTRB;
		       end
		       else begin
			       HSEL_f <= 'b0;
			       HWRITE_f <= 'b0;
			       HADDR_f <= 'b0;
			       //HSTRB_f <= 'b0;
		       end
	       end
       end


       //OUTPUT ASSIGNMENTS
       assign HWRITE_r = HWRITE_f;
       assign PSEL_r = HSEL_f;
       assign HADDR_r = HADDR_f;
       //assign HSTRB_r = HSTRB_f;
       assign HREADY = fsm_ready ? 'b1 : 'b0;
       assign HRESP = fsm_error ? 'b1 : 'b0;

endmodule : ahb_sig
