//仿真测试文件 testbench tb

//声明时间尺度
`timescale   1ns/1ps   //时间单位 / 时间精度

module   Q1_tb();

//测试代码不会被综合成电路的

//声明变量   输入信号用reg，输出信号用wire
    reg   A  ;
    wire  Y  ;
	
//模拟产生输入信号A的值
//给A赋初始值0或1
initial
    A = 0 ;
//循环	每100ns产生一个0或1的随机数
always  #100   A = {$random}%2 ;
    
//调用被测试模块
//调用格式:模块名    实例化名
           Q1        Q1_inst(
            .A       (A)      ,
            .Y       (Y)
           );
endmodule    