`timescale 1ns/1ps
module uart_if_16bit
    (input clk, rstb, rxd,
     output txd);

    localparam st=2'b01, rx=2'b00, st_tx=2'b10, tx=2'b11;

    reg [15:0] rx_dt;
    wire [15:0] tx_dt;
    wire [7:0] dbus;
    wire sciirq;
    reg [7:0] rx_1d, wdt;
    reg scisel, rw, cnt, inv, uld, ld_tdre, tdre;
    reg [1:0] addr, cst, nst;

    uart u1(.clk(clk), .rstb(rstb), .scisel(scisel), .rw(rw), .rxd(rxd), .addr(addr), .dbus(dbus),
            .sciirq(sciirq), .txd(txd));

    assign dbus=wdt;
    assign tx_dt=rx_dt;

    always@(posedge clk or negedge rstb)
    if(!rstb) {cnt, cst}<={1'b0, st};
    else
    begin
        cst<=nst;
        if(inv) cnt<=~cnt;
        if(uld&!cnt) rx_1d<=dbus;
        if(uld&cnt) rx_dt<={dbus, rx_1d};
        if(ld_tdre) tdre<=dbus[7];
    end

    always@*
    begin {inv, uld, ld_tdre, scisel}=4'b0001; wdt=8'dz;
        case(cst)
        st: begin {addr, rw}=3'b111; wdt=8'b01000000; nst=rx; end
        rx: begin {addr, rw}=3'b000; if(sciirq) if(!cnt) {inv, uld, nst}={2'b11, rx};
            else {inv, uld, nst}={2'b11, st_tx}; else {scisel, nst}={1'b0, rx}; end
        st_tx: begin {addr, rw}=3'b010; {ld_tdre, nst}={1'b1, tx}; end
        tx: begin {addr, rw}=3'b001; if(tdre) if(!cnt) {inv, wdt, nst}={1'b1, tx_dt[7:0], st_tx};
            else {inv, wdt, nst}={1'b1, tx_dt[15:8], rx}; else {scisel, nst}={1'b0, st_tx}; end
        endcase
    end
endmodule
