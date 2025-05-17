`timescale 1ns/1ps
module uart_tx
    (input clk, rstb, bclk, tdre, loadtdr,
     input [7:0] dbus,
     output settdre, txd);

    localparam idle = 2'b00, sync = 2'b01, tdata = 2'b11;
    reg [1:0] cst, nst;
    reg [8:0] tsr;
    reg [7:0] tdr;
    reg [3:0] bct;
    reg inc, clr, loadtsr, shfttsr, start, bclkd;
    assign txd = tsr[0];
    assign settdre = loadtsr;
    wire bclkr = bclk & (~bclkd);

    always@*
    begin {inc, clr, loadtsr, shfttsr, start} = 5'd0;
        case(cst)
        idle: if(!tdre) {loadtsr, nst} = {1'b1, sync}; else {shfttsr, nst} = {1'b1, idle};
        sync: if(bclkr) {start, nst} = {1'b1, tdata}; else nst = sync;
        tdata: if(!bclkr) nst = tdata;
               else if(bct != 4'd8) {shfttsr, inc, nst} = {2'b11, tdata};
               else {clr, nst} = {1'b1, idle};
        default: nst = idle;
        endcase
    end

    always@(posedge clk or negedge rstb)
    if(!rstb) {tsr, cst, bct, bclkd} <= {9'd511, idle, 5'd0};
    else
    begin
        cst <= nst;
        bclkd <= bclk;
        if(clr) bct <= 4'd0; else if(inc) bct <= bct + 4'd1;
        if(loadtdr) tdr <= dbus;
        if(loadtsr) tsr <= {tdr, 1'b1};
        if(start) tsr[0] <= 1'b0;
        if(shfttsr) tsr <= {1'b1, tsr[8:1]};
    end
endmodule
