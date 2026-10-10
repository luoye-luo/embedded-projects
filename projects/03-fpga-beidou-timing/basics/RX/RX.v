//串口接收模块
//基于状态机实现异步串口接收功能，波特率9600bps，时钟频率50MHz
//协议：1位起始位(低电平) + 8位数据位(无校验) + 无停止位

module RX (

   input wire sys_clk,       // 系统时钟输入 50MHz
   input wire sys_rst_n,     // 系统复位输入 低电平有效
   input wire data_in,       // 串口接收数据输入

   output reg [7:0] data_rx, //接收完成的8位并行数据
   output reg over           //接收完成标志位，高电平表示数据接收完成
    
);

//状态机状态定义-对应串口接收的不同阶段
reg [3:0] state;
parameter IDLE = 4'd0; // 空闲状态：等待起始位
parameter S1 = 4'd1;   // 接收第1位数据
parameter S2 = 4'd2;   // 接收第2位数据
parameter S3 = 4'd3;   // 接收第3位数据
parameter S4 = 4'd4;   // 接收第4位数据
parameter S5 = 4'd5;   // 接收第5位数据
parameter S6 = 4'd6;   // 接收第6位数据
parameter S7 = 4'd7;   // 接收第7位数据
parameter S8 = 4'd8;   // 接收第8位数据
parameter S9 = 4'd9;   // 预留状态（未使用）

//串口通信参数配置
parameter Bps = 9600;                 // 串口波特率：9600bps (每秒传输9600个码元)
parameter clk_freq = 50_000_000;      // 系统时钟频率：50MHz

parameter cnt_max = clk_freq/Bps;     // 每个码元的时钟周期数：50M/9600 ≈ 5208
parameter cnt_max_mid = cnt_max >> 1; // 码元中间位置：用于稳定采样（2604个时钟周期）

//定义输入信号同步寄存器，用于消除亚稳态和检测边沿
reg data_in_r1;    // 数据输入第1级同步寄存器
reg data_in_r2;    // 数据输入第2级同步寄存器（消除亚稳态）
reg data_in_r3;    // 数据输入第3级寄存器（用于检测r2下降沿）

//延迟信号,消除亚稳态并捕获边沿
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin  // 复位时清空所有同步寄存器
        data_in_r1 <= 1'd0;
        data_in_r2 <= 1'd0;
        data_in_r3 <= 1'd0;
    end
    else begin             // 非复位时，数据逐级打拍
        data_in_r1 <= data_in;    // 第一级同步
        data_in_r2 <= data_in_r1; // 第二级同步（稳定数据）
        data_in_r3 <= data_in_r2; // 第三级同步（用于边沿检测）
    end
end

//起始位检测：检测data_in_r2的下降沿，开始传输数据
//即空闲高电平变为起始位低电平
reg start;   // 起始位检测标志信号
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        start <= 1'd0;
    end
    //条件：1.data_in_r2为低（当前稳定值） 2.data_in_r3为高（上一拍值） 3.处于空闲状态
    else if ((!data_in_r2) && (data_in_r3) && (state == IDLE)) begin
        start <= 1'd1;  //检测到起始位下降沿，置位启动标志
    end
    else
        start <= 1'd0;  //其他情况清空启动标志
end

//波特率计数器：计数每个码元的时钟周期，实现波特率匹配
reg [31:0] cnt_baud;    //波特率计数器（位数足够大，避免溢出）
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        cnt_baud <= 32'd0;  //复位清空计数器
    end
    //特殊条件：接收完第8位数据后，等待到码元中间+200个时钟周期，清空计数器
    else if ((cnt_baud >= cnt_max_mid + 32'd200) && (state == S8)) begin        //数据在cnt_max_mid生成完毕,稳定后即可输出,可多等待一段时间,即 +32'd100
        cnt_baud <= 32'd0;
    end
    // else if ((cnt_baud >= cnt_max) && (state == S8)) begin        //也能用
    //     cnt_baud <= 32'd0;
    // end
    //通用条件：计数器达到最大计数值，重置为1（避免从0开始，保证计数连续性）
    else if (cnt_baud >= cnt_max) begin
        cnt_baud <= 32'd1;
    end
    //检测到起始位，启动计数器（从1开始）
    else if (start) begin
        cnt_baud <= 32'd1;
    end
    //计数器已启动，正常累加
    else if (cnt_baud >= 32'd1) begin
        cnt_baud <= cnt_baud + 32'd1;
    end
end

//状态机跳转逻辑：按接收进度切换状态
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        state <= IDLE;  //复位回到空闲状态
    end
    else
        case (state)
           IDLE : begin  //空闲状态：等待起始位计数完成
            if (cnt_baud >= cnt_max) begin
                state <= S1; //起始位计数完成，进入接收第1位数据状态
            end
            else
                state <= IDLE;
           end
           S1 : begin    //接收第1位数据：计数完成后切换到第2位
            if (cnt_baud >= cnt_max) begin
                state <= S2;
            end
            else
                state <= S1;
           end
           S2 : begin    //接收第2位数据：计数完成后切换到第3位
            if (cnt_baud >= cnt_max) begin
                state <= S3;
            end
            else
                state <= S2;
           end
           S3 : begin    //接收第3位数据：计数完成后切换到第4位
            if (cnt_baud >= cnt_max) begin
                state <= S4;
            end
            else
                state <= S3;
           end
           S4 : begin    //接收第4位数据：计数完成后切换到第5位
            if (cnt_baud >= cnt_max) begin
                state <= S5;
            end
            else
                state <= S4;
           end
           S5 : begin    //接收第5位数据：计数完成后切换到第6位
            if (cnt_baud >= cnt_max) begin
                state <= S6;
            end
            else
                state <= S5;
           end
           S6 : begin    //接收第6位数据：计数完成后切换到第7位
            if (cnt_baud >= cnt_max) begin
                state <= S7;
            end
            else
                state <= S6;
           end
           S7 : begin    //接收第7位数据：计数完成后切换到第8位
            if (cnt_baud >= cnt_max) begin
                state <= S8;
            end
            else
                state <= S7;
           end
           S8 : begin    //接收第8位数据：等待数据稳定后回到空闲状态
            if (cnt_baud >= cnt_max_mid + 32'd200) begin
                state <= IDLE;   //数据稳定后回到空闲
            end
        //   S8 : begin
        //     if (cnt_baud >= cnt_max) begin
        //         state <= IDLE;
        //     end
            else
                state <= S8;
           end
            default: begin      //异常状态：回到空闲
                state <= IDLE;
            end
        endcase
end

//数据拼接：在每个码元中间位置采样数据，拼接成8位并行数据
reg [7:0] data_mid;  //定义接收数据中间寄存器
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        data_mid <= 8'd0;  //复位清空中间数据
        over <= 1'd0;      //复位清空完成标志
    end
    //条件：处于数据接收状态+计数器到达码元中间位置（最佳采样点）
    else if (((state == S1) ||
              (state == S2) || 
              (state == S3) || 
              (state == S4) || 
              (state == S5) || 
              (state == S6) || 
              (state == S7) || 
              (state == S8)) && (cnt_baud == cnt_max_mid)) begin
        //串行数据左移拼接（低位先接收）      
        data_mid <= {data_in_r3,data_mid[7:1]};
    end
    //接收完成：第8位数据稳定后，置位完成标志
    else if ((state == S8) && (cnt_baud == cnt_max_mid + 32'd200)) begin        //数据在cnt_max_mid生成完毕,稳定后即可输出,即 +32'd200
        over <= 1'd1;
    end
    else begin   //其他情况保持数据和标志不变
        data_mid <= data_mid;
        over <= 1'd0;
    end
end

//最终数据输出：接收完成时将中间数据赋值到输出端口
always @(posedge sys_clk) begin
    if (!sys_rst_n) begin
        data_rx <= 8'd0;   //复位清空输出数据
    end
    //接收完成：将稳定的中间数据输出
    else if ((state == S8) && (cnt_baud == cnt_max_mid + 32'd200)) begin        //数据在cnt_max_mid生成完毕,稳定后即可输出,即 +32'd200
        data_rx <= data_mid;
    end
end

endmodule