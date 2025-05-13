`timescale 1ns/1ps
module baudgen
    (input clk, rstb,
     input [1:0] baudsel,
     output bclkx8, bclk);

    reg [5:0] temp1;
    reg [3:0] temp2, temp3;

    always@(posedge clk or negedge rstb)
    begin
        if(!rstb) temp1<=6'd0;
        else if(temp1==6'd53) temp1<=6'd0;
        else temp1<=temp1+6'd1;
    end

    always@(posedge clk or negedge rstb)
    begin
        if(!rstb) {temp2, temp3}<=8'd0;
        else if(temp1==6'd53) begin temp2<=temp2+4'd1; temp3<=temp3+4'd1; end
        else if(temp1==6'd6|temp1==6'd13|temp1==6'd20|temp1==6'd26|
                temp1==6'd32|temp1==6'd39|temp1==6'd46) temp2<=temp2+4'd1;
    end

    assign bclkx8=temp2[baudsel];
    assign bclk=temp3[baudsel];
endmodule
