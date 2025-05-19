`timescale 1ns/1ps
module uart_if_16bit_dt
    (input clk, rstb, rxd, tx_rd,
     input [15:0] tx_dt,
     output txd,
     output reg tx_dn, rx_rd,
     output reg [15:0] rx_dt);

    localparam st=2'b01, rx=2'b00, st_tx=2'b10, tx=2'b11;

    wire [7:0] dbus;
    reg [7:0] rx_1d, tx_1d, tx_2d, wdt;
    reg tx_st, dn, scisel, rw, cnt1, cnt2, inv1, inv2, ld_tdre, tdre;
    reg [1:0] addr, cst, nst;

    uart u1(.clk(clk), .rstb(rstb), .scisel(scisel), .rw(rw), .rxd(rxd), .addr(addr), .dbus(dbus),
            .sciirq(sciirq), .txd(txd));

    assign dbus=wdt;

    always@(posedge clk or negedge rstb)
    if(!rstb) {cnt1, cnt2, cst}<={2'b00, st};
    else
    begin
        cst<=nst;
        if(inv1)
        begin cnt1<=~cnt1;
            if(!cnt1) rx_1d<=dbus;
            else {rx_rd, rx_dt}<={1'b1, dbus, rx_1d};
        end
        else rx_rd<=1'b0;
        if(inv2) cnt2<=~cnt2;
        if(tx_rd) {tx_st, tx_2d, tx_1d}<={1'b1, tx_dt}; else if(dn) tx_st=1'b0;
        if(dn) tx_dn=1'b1; else if(tx_rd) tx_dn=1'b0;
        if(ld_tdre) tdre<=dbus[7];
    end

    always@*
    begin {inv1, inv2, ld_tdre, dn, scisel}=5'b00001; wdt=8'dz;
        case(cst)
        st: begin {addr, rw}=3'b111; wdt=8'b01000000; nst=rx; end
        rx: begin {addr, rw}=3'b000; nst=st_tx; if(sciirq) inv1=1'b1; else scisel=1'b0; end
        st_tx: begin {addr, rw}=3'b010; if(tx_st) {ld_tdre, nst}={1'b1, tx};
               else {scisel, nst}={1'b0, rx}; end
        tx: begin {addr, rw}=3'b001; nst=rx; if(tdre) begin inv2=1'b1;
            if(!cnt2) wdt=tx_1d; else {dn, wdt}={1'b1, tx_2d}; end else scisel=1'b0; end
        endcase
    end
endmodule
