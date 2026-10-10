//验证D触发器

module     D_FF(
  
     input   wire    sys_clk  ,//时钟输入信号
     input   wire    rst_n    ,//复位信号 低电平有效
	 input   wire    D        ,//数据输入信号
	 
	 output  reg     Q        ,//数据输出Q = D
     output  wire    Q_NOT    //   Q_NOT=~Q


);
//组合逻辑下赋值 变量类型wire，assign
//时序逻辑下赋值 reg寄存器类型，always块下赋值

//条件语句中判断用==
//时序逻辑always下赋值用<=
//组合逻辑assign下赋值用=

//异步复位时钟上升沿触发
always@(posedge sys_clk or negedge rst_n)  //敏感变量(时钟上升沿触发,异步复位）
    if(rst_n==0)  //复为低电平有效时 Q清零
	    Q<=0;
//else if()   elif()
	else          //不复位时Q=D
        Q<=D;

assign Q_NOT=~Q;

endmodule