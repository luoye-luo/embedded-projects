//仿真测试文件

`timescale  1ns/1ps
module     TEST_LEVEL_tb();

//声明变量
     reg    [8:0] A ;
     reg    [8:0] B ;
     reg    [8:0] C ;
     reg    [8:0] D ;
	 wire   [19:0]P ;
	 
//给输入信号产生模拟值
initial
    begin
	    A = 100 ;
		B = 200 ;
		C = 300 ;
		D = 400 ;
	end

//每100ns让A等于一个500以内的随机值
always#100 A = {$random}%501 ;
always#100 B = {$random}%501 ;
always#100 C = {$random}%501 ;
always#100 D = {$random}%501 ;

TEST_LEVEL    TEST_LEVEL_inst(
.A                    (A),
.B                    (B),
.C                    (C),
.D                    (D),
.P                    (P)
);	
	
	 
endmodule
