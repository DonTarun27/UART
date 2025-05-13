`timescale 1ns/1ps
module uart(clk, rstb, scisel, rw, rxd, addr, dbus, sciirq, txd);
    (input clk, rstb, scisel, rw, rxd,
     input [1:0] addr,
     inout [7:0] dbus,
     output sciirq, txd);

    wire [7:0] rdr, scsr, sccr;
    reg tdre, rdrf, oe, fe, tie, rie;
    reg [1:0] baudsel;
    wire settdre, setrdrf, setoe, setfe, loadtdr, loadsccr;
    wire clrrdrf, bclk, bclkx8, scir, sciw;

    baudgen bg(.clk(clk), .rstb(rstb), .baudsel(baudsel), .bclkx8(bclkx8), .bclk(bclk));
    uart_tx tx(.clk(clk), .rstb(rstb), .bclk(bclk), .tdre(tdre), .loadtdr(loadtdr), .dbus(dbus),
               .settdre(settdre), .txd(txd));
    uart_rx rx(.clk(clk), .rstb(rstb), .bclkx8(bclkx8), .rxd(rxd), .rdrf(rdrf), .rdr(rdr),
               .setrdrf(setrdrf), .setoe(setoe), .setfe(setfe));

    always@(posedge clk or negedge rstb)
    if(!rstb) {oe, fe, tie, rie, rdrf, tdre} <= 6'd1;
    else
    begin
        tdre <= (settdre & ~tdre) | (~loadtdr & tdre);
        rdrf <= (setrdrf & ~rdrf) | (~clrrdrf & rdrf);
        oe <= (setoe & ~oe) | (~clrrdrf & oe);
        fe <= (setfe & ~fe) | (~clrrdrf & fe);
        if(loadsccr) {tie, rie, baudsel} <= {dbus[7:6], dbus[1:0]};
    end

    assign sciirq = ((rie==1'b1 & (rdrf==1'b1 | oe==1'b1)) | (tie==1'b1 & tdre==1'b1))?1'b1:1'b0;
    assign scsr = {tdre, rdrf, 4'd0, oe, fe};
    assign sccr = {tie, rie, 4'd0, baudsel};
    assign scir = (scisel==1'b1 & rw==1'b0)?1'b1:1'b0;
    assign sciw = (scisel==1'b1 & rw==1'b1)?1'b1:1'b0;
    assign clrrdrf = (scir==1'b1 & addr==2'b00)?1'b1:1'b0;
    assign loadtdr = (sciw==1'b1 & addr==2'b00)?1'b1:1'b0;
    assign loadsccr = (sciw==1'b1 & addr==2'b11)?1'b1:1'b0;
    assign dbus = (scir==1'b0)?8'dz:((addr==2'b00)?rdr:((addr==2'b01)?scsr:sccr));
endmodule
