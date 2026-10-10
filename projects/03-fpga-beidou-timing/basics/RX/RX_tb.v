//串口接收测试模块
//用于验证RX串口接收模块的功能正确性
//模拟发送8组数据(0~7)，验证接收模块能否正确解析并输出

module RX_tb();

////
//\* Parameter and Internal Signal \//
////

//reg define
reg sys_clk;    //模拟系统时钟（50MHz）
reg sys_rst_n;  //模拟系统复位（低电平有效）
reg data_in;    //模拟串口接收数据输入

//wire define
wire [7:0] data_rx;  //观测接收模块输出的8位数据
wire over;           //观测接收模块的接收完成标志信号

 ////
 //\* Main Code \//
 ////

 //初始化系统时钟、全局复位和输入信号
 initial begin
 sys_clk = 1'b1;    //时钟初始化为高电平
 sys_rst_n <= 1'b0; //初始复位（低电平有效）
 data_in <= 1'b1;   //串口空闲状态为高电平
 #20;
 sys_rst_n <= 1'b1; //20ns后释放复位
 end

 //模拟发送8次数据，分别为0~7
 initial begin
 #200               //延时200ns，等待复位稳定后开始发送数据
 //调用自定义任务发送数据，依次发送8'd0 ~ 8'd7
 data_in_bit(8'd0); //任务的调用，任务名+括号中要传递进任务的参数
 data_in_bit(8'd1); //发送数据1
 data_in_bit(8'd2); //发送数据2
 data_in_bit(8'd3); //发送数据3
 data_in_bit(8'd4); //发送数据4
 data_in_bit(8'd5); //发送数据5
 data_in_bit(8'd6); //发送数据6
 data_in_bit(8'd7); //发送数据7
 end

 //sys_clk:每10ns电平翻转一次，产生一个50MHz的时钟信号
 always #10 sys_clk = ~sys_clk;

 //定义一个名为rx_bit的任务，每次发送的数据有10位
 //data的值分别为0~7由j的值传递进来
 //任务以task开头，后面紧跟着的是任务名，调用时使用
 task data_in_bit(
 //传递到任务中的参数，调用任务的时候从外部传进来一个8位的值
 input [7:0] data
 );
 integer i; //定义整型变量i，用于for循环计数
 //用for循环产生一帧10位的串口数据（0~9位依次对应：起始位、8位数据位、停止位）
 //for括号中最后执行的内容只能写i=i+1，不可以写成C语言i=i++的形式
 
 for(i=0; i<10; i=i+1) begin
 case(i)
 0: data_in <= 1'b0;    //第0位：起始位（低电平）
 1: data_in <= data[0]; //第1位：数据最低位LSB
 2: data_in <= data[1]; //第2位：数据位
 3: data_in <= data[2]; //第3位：数据位
 4: data_in <= data[3]; //第4位：数据位
 5: data_in <= data[4]; //第5位：数据位
 6: data_in <= data[5]; //第6位：数据位
 7: data_in <= data[6]; //第7位：数据位
 8: data_in <= data[7]; //第8位：数据最高位MSB
 9: data_in <= 1'b1;    //第9位：停止位（高电平）
 endcase
 #(5208*20); //每发送1位数据延时5208个时钟周期
 end
 endtask //任务以endtask结束

 ////
 //\* Instantiation \//
 ////

 //------------------------uart_rx_inst------------------------
 RX_1  RX_1_inst(
 .sys_clk (sys_clk ), //input sys_clk
 .sys_rst_n (sys_rst_n ), //input sys_rst_n
 .data_in (data_in ), //input rx

 .data_rx (data_rx ), //output [7:0] po_data
 .over (over ) //output po_flag
 );

 endmodule