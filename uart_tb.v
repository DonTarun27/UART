`timescale 1ns/1ps
module uart_tb;
    reg scisel, rw, clk, rstb;
    reg [1:0] addr;
    reg [7:0] dbusr;
    wire [7:0] dbus;
    wire rxd, sciirq, txd;

    uart dut(.clk(clk), .rstb(rstb), .scisel(scisel), .rw(rw), .rxd(rxd), .addr(addr), .dbus(dbus),
             .sciirq(sciirq), .txd(txd));

    assign dbus = dbusr;
    assign rxd = txd;

    initial
    begin {clk, rstb, scisel} = 3'b011;
        #10 rstb = 1'b0;
        #10 rstb = 1'b1; rw = 1'b1; addr = 2'b11; dbusr = 8'b01000000;
        #10 rw = 1'b0; addr = 2'b01; dbusr = 8'dz;
        #10 rw = 1'b1; addr = 2'b00; dbusr = 8'b01101011;
        #10 rw = 1'b0; addr = 2'b00; dbusr = 8'dz;
        #12000 $finish;
    end

    always #5 clk = ~clk;
endmodule
