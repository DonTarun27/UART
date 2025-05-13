`timescale 1ns/1ps
module baudgen_tb;
    reg clk, rstb;
    reg [1:0] baudsel;
    wire bclkx8, bclk;
    reg i;

    baudgen dut(.clk(clk), .rstb(rstb), .baudsel(baudsel), .bclkx8(bclkx8), .bclk(bclk));
    initial
    begin {baudsel, clk, rstb} = 4'd1;
          #10 rstb = 1'b0;
          #10 rstb = 1'b1;
    end
    always #5 clk = ~clk;
    always @(negedge bclk) if(rstb) {i, baudsel} <= baudsel + 2'd1;
    always @(posedge clk) if(i) $finish;
endmodule
