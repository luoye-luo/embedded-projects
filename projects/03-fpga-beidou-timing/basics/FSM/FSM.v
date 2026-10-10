//状态机实现重复性序列检测
//10010时输出信号拉高

module    FSM(
    input    wire    clk     ,
    input    wire    rst     ,
    input    wire    data_in ,  //数据输入信号 0或1
    output   reg     fsm_out    //状态机输出信号
);
//定义中间变量状态机寄存器
    reg    [5:0]state ;    //6个状态 
    
//独热码 只有一位有效位1
    parameter    START = 6'b000_001 ;  //初始状态
    parameter      S0  = 6'b000_010 ;  //1
    parameter      S1  = 6'b000_100 ;  //10
    parameter      S2  = 6'b001_000 ;  //100
    parameter      S3  = 6'b010_000 ;  //1001
    parameter      S4  = 6'b100_000 ;  //10010

//二段式状态机
//第一部分 描述状态跳转的过程
//state
always@(posedge clk or negedge rst)
    if(rst == 0)  //复位时状态机处于初始状态
        state <= START ;
    else          //不复位时状态正常跳转
        begin
            case(state)   //条件互异
                START : //状态机START初始状态
                      begin
                          if(data_in == 0)
                              state <= START ;//不向后跳转
                            //state <= state ;
                          else  //data_in == 1
                              state <= S0 ; //向后跳转
                      end
                  S0  :
                      begin
                          if(data_in == 0)
                              state <= S1 ; //跳转
                          else
                              state <= S0 ; //不跳转
                      end
                  S1  :
                      begin
                          if(data_in == 0)
                              state <= S2 ; 
                          else
                              state <= S0 ; 
                      end
                  S2  :
                      begin
                          if(data_in == 0)
                              state <= START ; 
                          else
                              state <= S3 ; 
                      end
                  S3  :
                      begin
                          if(data_in == 0)
                              state <= S4 ; 
                          else
                              state <= S0 ; 
                      end
                  S4  :
                      begin
                          if(data_in == 0)
                              state <= S2 ; 
                          else
                              state <= S0 ; 
                      end
              default : state <= START ;
              //当以上条件都不满足(非法输入)回到初始状态
            endcase
        end
    

//第二部分 描述状态机输出
//fsm_out
always@(posedge clk or negedge rst)
    if(rst == 0)
        fsm_out <= 0 ;  //复位时输出信号不拉高
    else if(state == S4)
        fsm_out <= 1 ; //S4状态下检测到10010 输出信号拉高一个周期
    else
        fsm_out <= 0 ; //其他时间不拉高 等待下一次拉高

endmodule

/*     case()
    条件1 :  赋值1  ;
    条件2 :  赋值2  ;
    ...
    default: 赋值n  ;
    endcase */
    





