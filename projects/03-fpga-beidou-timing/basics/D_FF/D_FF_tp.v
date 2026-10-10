`timescale  1ns/1ps
module D_FF_tb();
   reg   sys_clk;
   reg   rst_n;
   reg   D;
   wire  Q;
   wire  Q_NOT;

initial
begin
    sys_clk <= 0 ; //时钟信号初始状态低电平或高电平
	rst_n <= 0 ;   //复位信号初始状态低电平
	D <= 0 ;
	#100
	rst_n <= 1 ;   //100ns后复位结束拉高
	
end
always#10 sys_clk <= ~sys_clk ; //每10ns clk取反一次
always#13.7 D <= {$random}%2 ;  //每13.7ns让D信号产生一个随机波形

D_FF           D_FF_inst(
.sys_clk       (sys_clk),
.rst_n         (rst_n),
.D             (D),
.Q             (Q),
.Q_NOT         (Q_NOT)

);
endmodule  