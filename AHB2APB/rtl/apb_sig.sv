//APB SETUP AND ACCESS STATE
module apb_sig(input clk, rst_n,
	       input PREADY, PSLVERR,
	       input PSEL_f, PWRITE_f,
	       input [`WIDTH-1:0] PADDR_f, PWDATA_f,
	       input [3:0]PSTRB_f,
	       output [`WIDTH-1:0] PADDR, PWDATA,
	       output [3:0] PSTRB,
	       output PSEL, PWRITE,
	       output PENABLE);
       
       //LOCAL FLOP SIGNALS
       reg PSEL_r, PWRITE_r;
       reg PENABLE_r;
       reg [`WIDTH-1:0] PWDATA_r, PADDR_r;
       reg [3:0] PSTRB_r;

       always @(posedge clk or negedge rst_n) begin
	       if(!rst_n) begin
		       PSEL_r <= 'b0;
		       PWRITE_r <= 'b0;
		       PADDR_r <= 'b0;
		       PWDATA_r <= 'b0;
		       PENABLE_r <= 'b0;
		       PSTRB_r <= 'b0;
	       end
	       else begin
		       if(!PENABLE && PSEL_f) begin
			       PSEL_r <= PSEL_f;
			       PWRITE_r <= PWRITE_f;
			       if(PWRITE_f) begin
				       PWDATA_r <= PWDATA_f;
				       PSTRB_r <= PSTRB_f;
			       end
			       PADDR_r <= PADDR_f;
			       PENABLE_r <= 'b1;
		       end
		       else if(PENABLE && !PREADY) begin
			       PSEL_r <= PSEL_r;
			       PWRITE_r <= PWRITE_r;
			       if(PWRITE_r) begin
				       PWDATA_r <= PWDATA_r;
				       PSTRB_r <= PSTRB_r;
			       end
			       PADDR_r <= PADDR_r;
			       PENABLE_r <= PENABLE_r;
		       end
		       else begin
			       PSEL_r <= 'b0;
			       PWRITE_r <= 'b0;
			       PWDATA_r <= 'b0;
			       PSTRB_r <= 'b0;
			       PADDR_r <= 'b0;
			       PENABLE_r <= 'b0;
		       end
	       end
       end 

       //APB OUTPUT ASSIGNMENTS
       assign {PWRITE,PSEL} = (PENABLE) ? {PWRITE_r,PSEL_r} : {PWRITE_f,PSEL_f};
       assign PWDATA = (PENABLE) ? PWDATA_r : PWDATA_f;
       assign PADDR = PENABLE ? PADDR_r : PADDR_f;
       assign PENABLE = PENABLE_r;
       assign PSTRB = (PENABLE) ? PSTRB_r : PSTRB_f;

endmodule : apb_sig
