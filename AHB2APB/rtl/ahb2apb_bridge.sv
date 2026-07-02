`include"ahb2apb_pkg.sv"
import ahb2apb_pkg::*;
`include"ahb_sig.sv"
`include"apb_sig.sv"
`include"ahb2apb_fsm.sv"
//AHB - APB BRIDGE TOP MODULE
module ahb2apb_bridge(input clk, rst_n,
		      input trans_t HTRANS,
		      input [1:0] HSIZE,
		      input HWRITE,
		      input [`WIDTH-1:0] HADDR, HWDATA,
		      input [3:0] HSTRB,      //INPUTS FROM AHB SLAVE
		      input PREADY, PSLVERR,
		      input [`WIDTH-1:0] PRDATA,      //INPUTS FROM APB MASTER
		      output PWRITE, PSEL, PENABLE,
		      output [3:0] PSTRB,
		      output [`WIDTH-1:0] PWDATA, PADDR,	//OUTPUTS FOR APB MASTER
		      output HRESP, HREADY,
		      output [`WIDTH-1:0] HRDATA);	//OUTPUTS FOR AHB SLAVE
	      
	      //AHB ADDRESS PHASE FLOP SIGNALS
	      wire [`WIDTH-1:0] HADDR_r;
	      wire HWRITE_r;
	      //wire [3:0] HSTRB_r;
	      wire PSEL_r;
	      wire fsm_error, fsm_ready;

	      //AHB SIGNAL HANDLING BLOCK INSTANCE
	      ahb_sig i_ahb(.clk(clk), .rst_n(rst_n),
		      	    .HTRANS(HTRANS), .HSIZE(HSIZE),
			    .HWRITE(HWRITE), .HADDR(HADDR), 
			    .HREADY(HREADY), .HRESP(HRESP),
			    .fsm_error(fsm_error), .fsm_ready(fsm_ready),
		    	    .HADDR_r(HADDR_r), .HWRITE_r(HWRITE_r),
		    	    //.HSTRB_r(HSTRB_r), 
			    .PSEL_r(PSEL_r));
	    //LOCAL APB SIGNALS
	    wire [`WIDTH-1:0] PADDR_f, PWDATA_f;
    	    wire [3:0] PSTRB_f;
	    wire PSEL_f, PWRITE_f;	    
	     
	     //APB SIGNAL ASSIGNMENTS	    
	     assign PSEL_f = PSEL_r;
	     assign PSTRB_f = (PSEL && PWRITE) ? HSTRB : 4'b0;
	     assign PWRITE_f = (PSEL) ? HWRITE_r : 'b0;
	     assign PADDR_f = (PSEL) ? HADDR_r : 32'b0;
	     assign PWDATA_f = (PWRITE==1 && PSEL) ? HWDATA : 32'b0;
	     assign HRDATA = (!PWRITE && HREADY && PSEL) ? PRDATA : 32'b0;

	     //APB SIGNAL HANDLING BLOCK INSTANCE
	     apb_sig i_apb(.clk(clk), .rst_n(rst_n),
		     	   .PSEL_f(PSEL_f), 
			   .PSTRB_f(PSTRB_f), 
			   .PWRITE_f(PWRITE_f),
			   .PADDR_f(PADDR_f), .PWDATA_f(PWDATA_f),
		     	   .PREADY(PREADY), .PSLVERR(PSLVERR),
			   .PENABLE(PENABLE), .PADDR(PADDR),
			   .PSTRB(PSTRB),
			   .PWDATA(PWDATA), .PSEL(PSEL), .PWRITE(PWRITE));

	     //FSM BLOCK INSTANCE
	     ahb2apb_fsm i_fsm(.clk(clk), .rst_n(rst_n),
		     	       .HTRANS(HTRANS), .PREADY(PREADY),
			       .PSLVERR(PSLVERR), .fsm_error(fsm_error),
			       .fsm_ready(fsm_ready), .PWRITE(PWRITE),
		       	       .HWDATA(HWDATA), .HSTRB(HSTRB));
endmodule : ahb2apb_bridge	      
