`timescale 1ns/1ps
module     yihuo_tb();
reg A;
reg B;
wire Y;

yihuo    yihuo_inst(
.A         (A),
.B         (B),
.Y         (Y)
);
initial
     begin
	 A=100;
	 B=200;
end

always#100 A ={$random}%501;
always#100 B ={$random}%501;

endmodule