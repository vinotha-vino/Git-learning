//AHB - APB BRIDGE RELATED DEFINES
package ahb2apb_pkg;
	typedef enum logic[1:0] {AHB_IDLE,APB_SETUP,APB_ACCESS,APB_ERROR}states_t;
	typedef enum logic [1:0] {IDLE,BUSY,NON_SEQ,SEQ}trans_t;
	`define WIDTH 12  //FIXME
endpackage : ahb2apb_pkg
