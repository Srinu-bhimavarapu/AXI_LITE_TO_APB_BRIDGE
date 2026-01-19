`timescale 1ns/1ps

module tb_axi_lite_to_apb_bridge;

parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 32;

logic ACLK;
logic ARESETn;

// AXI-Lite signals
logic [ADDR_WIDTH-1:0] AWADDR;
logic AWVALID;
logic AWREADY;

logic [DATA_WIDTH-1:0] WDATA;
logic WVALID;
logic WREADY;

logic [1:0] BRESP;
logic BVALID;
logic BREADY;

logic [ADDR_WIDTH-1:0] ARADDR;
logic ARVALID;
logic ARREADY;

logic [DATA_WIDTH-1:0] RDATA;
logic [1:0] RRESP;
logic RVALID;
logic RREADY;

// APB signals
logic [ADDR_WIDTH-1:0] PADDR;
logic PSEL;
logic PENABLE;
logic PWRITE;
logic [DATA_WIDTH-1:0] PWDATA;
logic [DATA_WIDTH-1:0] PRDATA;
logic PREADY;
logic PSLVERR;

// DUT
axi_lite_to_apb_bridge #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) dut (
    .ACLK(ACLK),
    .ARESETn(ARESETn),
    .AWADDR(AWADDR),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),
    .WDATA(WDATA),
    .WVALID(WVALID),
    .WREADY(WREADY),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY),
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .ARREADY(ARREADY),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RVALID(RVALID),
    .RREADY(RREADY),
    .PADDR(PADDR),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
);

// CLOCK
always #5 ACLK = ~ACLK;

// APB SLAVE MODEL
always_ff @(posedge ACLK) begin
    if (PSEL && PENABLE) begin
        PREADY  <= 1'b1;
        PSLVERR <= 1'b0;
        if (!PWRITE)
            PRDATA <= 32'hDEADBEEF;
    end else begin
        PREADY <= 1'b0;
    end
end

// AXI WRITE TASK
task axi_write(input [31:0] addr, input [31:0] data);
begin
    @(posedge ACLK);
    AWADDR  <= addr;
    WDATA   <= data;
    AWVALID <= 1'b1;
    WVALID  <= 1'b1;

    wait (AWREADY && WREADY);
    @(posedge ACLK);
    AWVALID <= 0;
    WVALID  <= 0;

    BREADY <= 1'b1;
    wait (BVALID);
    @(posedge ACLK);
    BREADY <= 0;

    $display("AXI WRITE DONE: Addr=%h Data=%h", addr, data);
end
endtask

// AXI READ TASK
task axi_read(input [31:0] addr);
begin
    @(posedge ACLK);
    ARADDR  <= addr;
    ARVALID <= 1'b1;

    wait (ARREADY);
    @(posedge ACLK);
    ARVALID <= 0;

    RREADY <= 1'b1;
    wait (RVALID);
    @(posedge ACLK);
    RREADY <= 0;

    $display("AXI READ DONE: Addr=%h Data=%h", addr, RDATA);
end
endtask

// TEST SEQUENCE
initial begin
    // INIT
    ACLK = 0;
    ARESETn = 0;

    AWADDR = 0; AWVALID = 0;
    WDATA  = 0; WVALID  = 0;
    BREADY = 0;

    ARADDR = 0; ARVALID = 0;
    RREADY = 0;

    PRDATA = 0;
    PREADY = 0;
    PSLVERR = 0;

    #20;
    ARESETn = 1;

    // WRITE TEST
    axi_write(32'h1000_0000, 32'hA5A5A5A5);

    // READ TEST
    axi_read(32'h1000_0000);

    #50;
    $finish;
end

endmodule
