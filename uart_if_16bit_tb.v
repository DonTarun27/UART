`timescale 1ns/1ps
module uart_if_16bit_tb;
    reg clk, rstb, rxd;
    wire txd;

    uart_if_16bit dut(clk, rstb, rxd, txd);

    initial
    begin {clk, rstb, rxd} = 3'b011;
        #10 rstb = 1'b0;
        #10 rstb = 1'b1;
        #1085 rxd = 1'b0; //start
        #1085 rxd = 1'b1; //8'b01011001
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1; //stop
        #1085 rxd = 1'b0; //start
        #1085 rxd = 1'b1; //8'b01101011
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1; //stop
        #10000;
        #1085 rxd = 1'b0; //start
        #1085 rxd = 1'b1; //8'b01001101
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1; //stop
        #10000;
        #1085 rxd = 1'b0; //start
        #1085 rxd = 1'b1; //8'b00101011
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b0;
        #1085 rxd = 1'b1; //stop
    end
    always #5 clk = ~clk;
endmodule
