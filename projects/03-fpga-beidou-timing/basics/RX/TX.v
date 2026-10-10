//串口发送模块
//基于状态机实现异步串口发送功能，波特率9600bps，时钟频率50MHz
//协议：1位起始位(低电平) + 8位数据位(无校验) + 1位停止位(高电平)

module TX (

    input wire sys_clk,   //系统时钟，频率50MHz
    input wire sys_rst_n, //系统复位，低电平有效

//以下端口被注释，实际通过子模块data关联
//    input wire [7:0] data_in,  //待发送的8位并行数据（由子模块提供）
//    input wire start,          //发送启动信号（由子模块提供）
//
//    output reg [3:0] state,    //状态机状态

    output reg data_tx,   //串口发送数据输出（串行）
    output reg over_tx       //发送完成标志位，高电平表示一帧数据发送完成
);

//串口通信参数配置
parameter Bps = 9600;                   //串口波特率：9600bps (每秒传输9600个码元)
parameter clk_freq = 50_000_000;        //时钟频率

parameter cnt_max = clk_freq/Bps;       //每个码元的时钟周期数：50M/9600 ≈ 5208
                                        //状态机跳转阈值，达到该值表示1位数据发送完成
//内部关联信号定义（由子模块data驱动）                                        
wire start;                             //发送启动信号：高电平触发发送流程
wire [7:0] data_in;                     //需转换成串行数据的并行数据
reg [3:0] state;                        //状态机状态寄存器（4位，支持0~15共16个状态）

//波特率计数器：计数每个码元的时钟周期，实现波特率匹配
reg [31:0] cnt;             //码元周期计数器（位数足够大，避免溢出）

//------------------------ 波特率计数器逻辑 ------------------------
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin   //复位清零计数器
        cnt <= 32'd0;
    end
    else if (start) begin   //检测到发送启动信号，计数器启动（从1开始）
       cnt <= 32'd1; 
    end
    //特殊条件：发送到停止位(S9)且计数器达到最大值，清空计数器（停止位发送完成）
    else if ((cnt >= cnt_max) && (state == 4'd9)) begin
        cnt <= 32'd0;
    end
    //通用条件：计数器达到最大计数值，重置为1（保证计数连续性，进入下一位发送）
    else if (cnt >= cnt_max) begin
        cnt <= 32'd1;
    end
    //计数器已启动，未到最大值则正常累加
    else if (cnt >= 32'd1) begin
        cnt <= cnt + 32'd1;
    end
    else                    //其他情况保持计数器值不变
        cnt <= cnt;
end

//------------------------ 状态机状态定义 ------------------------
//状态对应串口发送的每一位：IDLE(空闲) + S1(起始位) + S2~S9(8位数据位) + S10(停止位)
parameter IDLE = 4'd0,   //空闲状态：等待发送启动信号
          S1 = 4'd1,     //发送起始位（低电平）
          S2 = 4'd2,     //发送数据位第0位（LSB，最低位）
          S3 = 4'd3,     //发送数据位第1位
          S4 = 4'd4,     //发送数据位第2位
          S5 = 4'd5,     //发送数据位第3位
          S6 = 4'd6,     //发送数据位第4位
          S7 = 4'd7,     //发送数据位第5位
          S8 = 4'd8,     //发送数据位第6位
          S9 = 4'd9,     //发送数据位第7位（MSB，最高位）
          S10 = 4'd10;   //发送停止位（高电平）

//------------------------ 状态机跳转逻辑 ------------------------
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin   //复位回到空闲状态
        state <= IDLE;
    end
    else
        case (state)
           IDLE : begin     //空闲状态
            if (cnt == cnt_max) begin  //启动信号触发后，计数器达到码元周期，进入起始位状态
                state <= S1;
            end
            else
                state <= IDLE;         //未满足条件，保持空闲
           end
           S1 : begin       //起始位发送状态
            if (cnt == cnt_max) begin  //起始位发送完成（计数满），进入第0位数据发送
                state <= S2;
            end
            else
                state <= S1;           //保持起始位状态
           end
           S2 : begin      //第0位数据发送状态
            if (cnt == cnt_max) begin  //该位发送完成，进入下一位
                state <= S3;
            end
            else
                state <= S2;
           end
           S3 : begin      //第1位数据发送状态
            if (cnt == cnt_max) begin
                state <= S4;
            end
            else
                state <= S3;
           end
           S4 : begin      //第2位数据发送状态
            if (cnt == cnt_max) begin
                state <= S5;
            end
            else
                state <= S4;
           end
           S5 : begin      //第3位数据发送状态
            if (cnt == cnt_max) begin
                state <= S6;
            end
            else
                state <= S5;
           end
           S6 : begin      //第4位数据发送状态
            if (cnt == cnt_max) begin
                state <= S7;
            end
            else
                state <= S6;
           end
           S7 : begin      //第5位数据发送状态
            if (cnt == cnt_max) begin
                state <= S8;
            end
            else
                state <= S7;
           end
           S8 : begin      //第6位数据发送状态
            if (cnt == cnt_max) begin
                state <= S9;
            end
            else
                state <= S8;
           end
           S9 : begin      //第7位数据发送状态
            if (cnt == cnt_max) begin  //8位数据发送完成，进入停止位状态
                state <= S10;
            end
            else
                state <= S9;
           end
           S10 : begin    //停止位发送状态
                state <= IDLE;         //停止位发送完成，直接回到空闲状态
           end
            default: begin             //异常状态：强制回到空闲
                state <= IDLE;
            end
        endcase
end

//------------------------ 串行数据输出逻辑 ------------------------
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin        //复位初始化
        data_tx <= 1'd1;         //串口空闲状态为高电平
        over_tx <= 1'd0;            //发送完成标志清零
    end
    else if (state == S1) begin  //起始位状态：输出低电平
        data_tx <= 1'd0;
    end
    else if (state == S2) begin  //第0位数据：输出data_in[0]（最低位）
        data_tx <= data_in [0];
    end
    else if (state == S3) begin  //第1位数据：输出data_in[1]
        data_tx <= data_in [1];
    end
    else if (state == S4) begin  //第2位数据：输出data_in[2]
        data_tx <= data_in [2];
    end
    else if (state == S5) begin  //第3位数据：输出data_in[3]
        data_tx <= data_in [3];
    end
    else if (state == S6) begin  //第4位数据：输出data_in[4]
        data_tx <= data_in [4];
    end
    else if (state == S7) begin  //第5位数据：输出data_in[5]
        data_tx <= data_in [5];
    end
    else if (state == S8) begin  //第6位数据：输出data_in[6]
        data_tx <= data_in [6];
    end
    else if (state == S9) begin  //第7位数据：输出data_in[7]（最高位）
        data_tx <= data_in [7];
    end
    else if (state == S10) begin //停止位状态：输出高电平，置位发送完成标志
        data_tx <= 1'd1;
        over_tx <= 1'd1;
    end
    else begin                   //空闲状态：输出高电平，清零完成标志
        data_tx <= 1'd1;
        over_tx <= 1'd0;
    end
end

//------------------------ 子模块例化 ------------------------
//例化data子模块，用于提供发送启动信号(start)和待发送数据(data_in)
//子模块接收系统时钟、复位和当前状态机状态，输出启动信号和数据
data data_0 (

.sys_clk(sys_clk),
.sys_rst_n(sys_rst_n),

.state(state),

.data_in(data_in),
.start(start)
);

endmodule