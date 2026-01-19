`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2026 23:38:08
// Design Name: 
// Module Name: axi_lite_to_apb_bridge
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_lite_to_apb_bridge#(
parameter ADDR_WIDTH=32,
parameter DATA_WIDTH=32
)
(
input logic ACLK,
input logic ARESETn,

// .........axi_lite_slave..........
// write address
input logic[ADDR_WIDTH-1:0] AWADDR,
input logic AWVALID,
output logic AWREADY,

//write data
input logic[DATA_WIDTH-1:0] WDATA,
input logic WVALID,
output logic WREADY,

//write responce 
output logic[1:0] BRESP,
output logic BVALID,
input logic BREADY,

// READ ADDRESS
input logic[ADDR_WIDTH-1:0] ARADDR,
input logic ARVALID,
output logic ARREADY,

//read data
output logic[DATA_WIDTH-1:0] RDATA,
output logic [1:0] RRESP,
output logic RVALID,
input logic RREADY,

//...APB MASTER ...
output logic[ADDR_WIDTH-1:0] PADDR,
output logic PSEL,
output logic PENABLE,
output logic PWRITE,
output logic[DATA_WIDTH-1:0] PWDATA,
input logic[DATA_WIDTH-1:0] PRDATA,
input logic PREADY,
input logic PSLVERR
);

typedef enum logic[2:0] {
IDLE,
APB_SETUP,
APB_ENABLE,
AXI_RESP
}state_t;
state_t state,next_state;

logic is_write ;
logic[ADDR_WIDTH-1:0] addr_reg;
logic[DATA_WIDTH-1:0] wdata_reg;

//axi transaction detection
wire axi_write = AWVALID && WVALID;
wire axi_read = ARVALID;

//fsm logic 
always_ff@(posedge ACLK or negedge ARESETn)
begin
if(!ARESETn)
state<= IDLE;
else
state<=next_state;
end

always_comb 
begin
next_state =state;
case(state)
IDLE :
if(axi_write || axi_read)
next_state=APB_SETUP;

APB_SETUP :
    next_state = APB_ENABLE;

APB_ENABLE :
    if (PREADY)
        next_state = AXI_RESP;

AXI_RESP :
if(( is_write && BREADY) || (!is_write && RREADY))
next_state=IDLE;
 endcase
 end
 
always_ff@(posedge ACLK or negedge ARESETn)
 begin
 if(!ARESETn) 
 begin
 addr_reg<='0;
 wdata_reg<='0;
 is_write<=1'b0;
 end
 else 
 if(state==IDLE) 
 begin
 if(axi_write)
 begin
 addr_reg<=AWADDR;
 wdata_reg<=WDATA;
 is_write<=1'b1;
 end 
 else if(axi_read) 
 begin
 addr_reg <= ARADDR;
 is_write<=1'b0;
 end
 end
 end
 
 always_comb
 begin 
 //defaults
 
 PSEL =1'b0;
 PENABLE =1'b0;
 PADDR = addr_reg;
 PWRITE = is_write;
 PWDATA = wdata_reg;
 
 case(state) 
 APB_SETUP :
 begin
 PSEL=1'b1;
 PENABLE=1'b0;
 end
 APB_ENABLE: 
 begin
 PSEL =1'b1;
 PENABLE =1'b1;
 end
 endcase
 end
 
 always_comb
 begin
 //defaults
 AWREADY =1'b0;
 WREADY=1'b0;
 ARREADY=1'b0;
 
 BVALID=1'b0;
 RVALID=1'b0;
 
 BRESP = PSLVERR ? 2'b10 : 2'b00; // SLVERR or OKAY
RRESP = PSLVERR ? 2'b10 : 2'b00;

 RDATA=PRDATA;
  
case(state)
IDLE : 
begin
AWREADY =1'b1;
WREADY=1'b1;
ARREADY=1'b1;
end
AXI_RESP : 
begin
if(is_write)
BVALID=1'b1;
else
RVALID=1'b1;
end
endcase
end
endmodule
 
 
 
 
 
 
 

































