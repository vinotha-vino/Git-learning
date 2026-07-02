`include"../rtl/ahb2apb_bridge.sv"
//`include"../sv/tb.sv"
module tb_top();
	//LOCAL SIGNALS
	logic clk, rst_n;
        trans_t HTRANS;
	logic [1:0] HSIZE;
	logic HWRITE;
	logic [`WIDTH-1:0] HADDR, HWDATA;
	logic [3:0] HSTRB;      //INPUTS FROM AHB SLAVE
	logic PREADY, PSLVERR;
	logic [`WIDTH-1:0] PRDATA;      //INPUTS FROM APB MASTER
	logic PWRITE, PSEL;
	logic [3:0]PSTRB;
	logic [`WIDTH-1:0] PWDATA, PADDR;	//OUTPUTS FOR APB MASTER
	logic HRESP, HREADY;
	logic [`WIDTH-1:0] HRDATA;	//OUTPUTS FOR AHB SLAVE
	
	//DUT INSTANCE
	ahb2apb_bridge i_dut(.clk(clk), .rst_n(rst_n),
			     .HTRANS(HTRANS), .HSIZE(HSIZE),
			     .HADDR(HADDR), .HWRITE(HWRITE), .HWDATA(HWDATA),
			     .HSTRB(HSTRB), .PREADY(PREADY), .PSLVERR(PSLVERR),
			     .PRDATA(PRDATA),
			     .PWRITE(PWRITE), .PSEL(PSEL), .PSTRB(PSTRB),
			     .PWDATA(PWDATA), .PADDR(PADDR),
			     .HRESP(HRESP), .HREADY(HREADY), .HRDATA(HRDATA));


/*	tb i_tb(.clk(clk), .rst_n(rst_n),
			     .HTRANS(HTRANS), .HSIZE(HSIZE),
			     .HADDR(HADDR), .HWRITE(HWRITE), .HWDATA(HWDATA),
			     .HSTRB(HSTRB), .PREADY(PREADY), .PSLVERR(PSLVERR),
			     .PRDATA(PRDATA),
			     .PWRITE(PWRITE), .PSEL(PSEL), .PSTRB(PSTRB),
			     .PWDATA(PWDATA), .PADDR(PADDR),
			     .HRESP(HRESP), .HREADY(HREADY), .HRDATA(HRDATA)); */

	//CLOCK AND RESET GENERATION
	initial begin
		fork
			clock_generation();
		join_none
		reset_generation();
		reset_input_signals();
		//write_without_wait();
		//read_without_wait();
		//apb_slave_error_without_wait();
		//repeat(2) @(posedge clk);
		//ahb_error_without_wait();
		//@(posedge clk);
		//read_with_wait();
		//write_with_wait();
		//apb_slave_error_with_wait();
		//ahb_error_with_wait();
                ahb_write_burst();
	end

	task clock_generation();
		clk = 'b0;
		forever begin
			#5 clk = ~clk;
		end
	endtask : clock_generation

	task reset_generation();
		rst_n = 'b1;
		@(posedge clk);
		rst_n = 0;
		repeat(2) @(posedge clk);
		rst_n = 1;
	endtask : reset_generation

	function void reset_input_signals();
		HTRANS = IDLE;
		HSIZE = 'b0;
		HSTRB = 'b0;
		HADDR = 'b0;
		HWRITE = 'b0;
		PREADY = 'b0;
		PSLVERR = 'b0;
		PRDATA = 'b0;
		HWDATA = 'b0;
	endfunction : reset_input_signals

	//SANITY WRITE TEST
	task write_without_wait();
		repeat(3) @(posedge clk);
		#1;
		HTRANS = NON_SEQ;
		HSIZE = 'd4;  //4 BYTES ARE VALID
		HADDR = 32'h55555555;
		HWRITE = 'b1;
		@(posedge clk);
		#1;
		reset_input_signals();
		HWDATA = 32'haaaaaaaa;
		HSTRB = 'b1111;
		@(posedge clk);
		#1;
		PREADY = 'b1;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : write_without_wait

	//SANITY READ TEST
	task read_without_wait();
		@(posedge clk);
		#1;
		HTRANS = NON_SEQ;
		HWRITE = 'b0;
		HADDR = 32'h55555555;
		@(posedge clk);
		#1;
		reset_input_signals();
		@(posedge clk);
		#1;
		PREADY = 'b1;
		PRDATA = 32'haaaaaaaa;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : read_without_wait

	//APB SLAVE ERROR TEST
	task apb_slave_error_without_wait();
		HTRANS = NON_SEQ;
		HWRITE = 'b1;
		HADDR = 32'habcdef01;
		HSIZE = 3;
		@(posedge clk);
		reset_input_signals();
	       	#1;
		HWDATA = 32'haabbccdd;
		HSTRB = 4'he;
		@(posedge clk);
		#1;
		PREADY = 'b1;
		PSLVERR = 'b1;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : apb_slave_error_without_wait

	//AHB ERROR TEST
	task ahb_error_without_wait();
		HTRANS = NON_SEQ;
		HSIZE = 3;
		HWRITE = 'b1;
		HADDR = 32'hab;
		@(posedge clk);
		reset_input_signals();
		#1;
		HWDATA = 32'h55;
		HSTRB = 'hf;
		@(posedge clk);
		#1;
		PREADY = 'b1;
		HSTRB = 'he;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : ahb_error_without_wait

	//WAIT FOR PREADY
	task read_with_wait();
		@(posedge clk);
		#1;
		HTRANS = NON_SEQ;
		HSIZE = 'd3;
		HWRITE = 'b0;
		HADDR = 32'haa;
		@(posedge clk);
		#1;
		reset_input_signals();
		repeat(5) @(posedge clk);
		#1;
		PREADY = 'b1;
		PRDATA = 32'habcdef;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : read_with_wait

	//WRITE WITH WAIT
	task write_with_wait();
		@(posedge clk) #1;
		HTRANS = NON_SEQ;
		HSIZE = 'd4;
		HADDR = 32'h0756;
		HWRITE = 'b1;
		@(posedge clk);
		#1;
		reset_input_signals();
		HWDATA = 32'h07777;
		HSTRB = 4'hb;
		repeat(7) @(posedge clk);
		#1;
		PREADY = 'b1;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : write_with_wait

	//APB SLAVE ERROR WITH WAIT
	task apb_slave_error_with_wait();
		@(posedge clk);
	       	#1;
		HTRANS = NON_SEQ;
		HSIZE = 'd0;
		HADDR = 32'h5674;
		HWRITE = 'b0;
		@(posedge clk); 
		#1;
		reset_input_signals();
		repeat(8) @(posedge clk);
		#1;
		PREADY = 'b1;
		PSLVERR = 'b1;
		PRDATA = 32'h87543;
		@(posedge clk);
		#1;
		reset_input_signals();
	endtask : apb_slave_error_with_wait

	//AHB ERROR WITH WAIT
	task ahb_error_with_wait();
		@(posedge clk); 
		#1;
		HTRANS = NON_SEQ;
		HSIZE = 'd2;
		HADDR = 32'h67845;
		HWRITE = 'b1;
		@(posedge clk); 
		#1;
		reset_input_signals();
		HWDATA = 32'h876543;
		HSTRB = 4'ha;
		repeat(4) @(posedge clk);
		#1;
		HWDATA = 32'haaaaaa;
		@(posedge clk); 
		#1;
		PREADY = 'b1;
		@(posedge clk); 
		#1;
		reset_input_signals();
	endtask : ahb_error_with_wait

        task ahb_write_burst();
          repeat(3) @(posedge clk);
	  #1;
	  HTRANS = NON_SEQ;
	  HSIZE = 'd4;  //4 BYTES ARE VALID
	  HADDR = 32'h55555555;
	  HWRITE = 'b1;
	  @(posedge clk);
	  #1;
	  HTRANS = SEQ;
	  HSIZE = 'd4;  //4 BYTES ARE VALID
	  HADDR = 32'h01010101;
	  HWDATA = 32'haaaaaaaa;
	  HSTRB = 'b1111;
	  @(posedge clk);
	  #1;
	  PREADY = 'b1;
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  @(posedge clk);
	  #1;
	  reset_input_signals();
        endtask : ahb_write_burst

	initial #1500 $finish; 
endmodule : tb_top

