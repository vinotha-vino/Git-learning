//AHB - APB FSM
module ahb2apb_fsm(input clk, rst_n,
		   input trans_t HTRANS,
		   input PWRITE,
		   input [3:0] HSTRB,
		   input [`WIDTH-1:0] HWDATA,
		   input PREADY, PSLVERR,
		   output fsm_error,
		   output fsm_ready);

	   //LOCAL SIGNALS AND STATES
	   states_t st_cur_r, st_nxt_s;
	   
	   reg error_r, fsm_ready_r;

	   reg [`WIDTH-1:0] HWDATA_s, HWDATA_r;
	   reg [3:0] HSTRB_s, HSTRB_r;

	   //NEXT STATE
	   always @(st_cur_r or HTRANS or PREADY or PSLVERR) begin
		   st_nxt_s = AHB_IDLE;
		   //apb_error_r = 'b0;
		   //fsm_ready = 'b1;
		   case(st_cur_r)
			   AHB_IDLE : begin
				   fsm_ready_r= 'b1;
				   error_r = 'b0;
				   HWDATA_s = 'b0;
		   		   HSTRB_s = 'b0;
				   if(HTRANS == NON_SEQ)
					   st_nxt_s = APB_SETUP;
			   end
			   APB_SETUP : begin
				   fsm_ready_r = 'b0;
				   error_r = 'b0;
				   st_nxt_s = APB_ACCESS;
				   if(PWRITE) begin
					   HWDATA_s = HWDATA;
					   HSTRB_s = HSTRB;
				   end
			   end
			   APB_ACCESS : begin
				   if(!PREADY && ((HWDATA == HWDATA_r) && (HSTRB == HSTRB_r))) begin
					   fsm_ready_r = 'b0;
					   st_nxt_s = APB_ACCESS;
					   error_r = 'b0;
				   end
				   else if((PREADY && PSLVERR) || ((HWDATA != HWDATA_r) || (HSTRB != HSTRB_r))) begin
					   fsm_ready_r = 'b0;
					   st_nxt_s = APB_ERROR;
					   error_r = 'b1;
				   end
				   else begin
					   fsm_ready_r = 'b1;
					   st_nxt_s = AHB_IDLE;
					   error_r = 'b0;
				   end
			   end
			   APB_ERROR : begin
				   error_r = 'b1;
				   fsm_ready_r = 'b1;
				   st_nxt_s = AHB_IDLE;
			   end
			  // default : begin
			  // 	fsm_ready_r <= 'b1;
			  // 	apb_error_r <= 'b0;
			  // 	ahb_error_r <= 'b0;
			  // end
		   endcase
	   end

	   //CURRENT STATE UPDATE
	   always @(posedge clk or negedge rst_n) begin
		   if(!rst_n) begin
			   st_cur_r <= AHB_IDLE;
			   fsm_ready_r <= 'b1;
			   error_r <= 'b0;
		   end
		   else begin
			   st_cur_r <= st_nxt_s;
			  // fsm_ready_r <= fsm_ready_s;
			  // apb_error_r <= apb_error_s;
			  // ahb_error_r <= ahb_error_s;
			   HWDATA_r <= HWDATA_s;
			   HSTRB_r <= HSTRB_s;
		   end
	   end 

	   //OUTPUT ASSIGNMENTS
	   assign fsm_ready = fsm_ready_r;
	   assign fsm_error = error_r;

endmodule : ahb2apb_fsm

