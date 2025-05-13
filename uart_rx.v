`timescale 1ns/1ps
module uart_rx
    (input clk, rstb, bclkx8, rxd, rdrf,
     output reg [7:0] rdr,
     output reg setrdrf, setoe, setfe);

    localparam idle = 2'b00, startdt = 2'b01, rdata = 2'b11;
    reg [1:0] cst, nst;
    reg [7:0] rsr;
    reg [2:0] ct1;
    reg [3:0] ct2;
    reg inc1, inc2, clr1, clr2, shftrsr, loadrdr, bclkx8d;

    wire bclkx8r = bclkx8 & (~bclkx8d);

    always@*
    begin {inc1, inc2, clr1, clr2, shftrsr, loadrdr, setrdrf, setoe, setfe} = 9'd0;
        case(cst)
        idle: if(!rxd) nst = startdt; else nst = idle;
        startdt: if(!bclkx8r) nst = startdt;
                 else if(rxd) {clr1, nst} = {1'b1, idle};
                 else if(ct1 == 3'd3) {clr1, nst} = {1'b1, rdata};
                 else {inc1, nst} = {1'b1,startdt};
        rdata: if(!bclkx8r) nst = rdata;
               else
               begin inc1 = 1'b1;
                   if(ct1 != 3'd7) nst = rdata;
                   else if(ct2 != 4'd8) {shftrsr, inc2, clr1, nst} = {3'b111, rdata};
                   else
                   begin {setrdrf, clr1, clr2, nst} = {3'b111, idle};
                       if(rdrf) setoe = 1'b1;
                       else if(!rxd) setfe = 1'b1;
                       else loadrdr = 1'b1;
                   end
               end
        default: nst = idle;
        endcase
    end

    always@(posedge clk or negedge rstb)
    if(!rstb) {bclkx8d, ct1, ct2, cst} <= {8'd0, idle};
    else
    begin
        cst <= nst;
        bclkx8d <= bclkx8;
        if(clr1) ct1 <= 3'd0; else if(inc1) ct1 <= ct1 + 3'd1;
        if(clr2) ct2 <= 4'd0; else if(inc2) ct2 <= ct2 + 4'd1;
        if(shftrsr) rsr <= {rxd, rsr[7:1]};
        if(loadrdr) rdr <= rsr;
    end
endmodule
