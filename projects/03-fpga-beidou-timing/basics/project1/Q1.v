//模块 module
//一个代码就是一个模块 以module开头 endmodule结束
////module  模块名  : 和工程名一致; 见名知意
////()端口列表      : 描述输入/输出信号端口
module    Q1(
    input    wire   A ,  //输入信号A  wire 信号类型 reg
    output   wire   Y    //输出信号Y
);

//描述逻辑功能  逻辑非门
assign    Y=~A ;           //！ ~ 让Y等于A取反

//与 &  &&      或 |  ||   一个按位一个逻辑
endmodule