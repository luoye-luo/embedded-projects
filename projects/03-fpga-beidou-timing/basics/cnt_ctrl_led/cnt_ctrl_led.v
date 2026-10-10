//运用计数器实现了的亮0.5s 灭0.5s

module    cnt_ctrl_led#(
    parameter  max = 25'd24_999_999
)(
     input   wire   clk,
     input   wire   rst,
     output  reg    [3:0]led_out
);
//定义内部变量计数器cnt
     reg     [24:0]cnt ;   //最大值24_999_999

always@(posedge clk or negedge rst)
	if(rst==0)   //复位时计数器清零
       cnt<=0;
    else if(cnt == max)	 //计数器计到最大值时 清零重新计数
       cnt<=25'd0;
    else                 //其他周期计数器加一
       cnt<=cnt+25'd1;	
always@(posedge clk or negedge rst)	
    if(rst==0)           //复位时led不亮
       led_out<=4'b0000; 
    else if(cnt==max)    //每0.5s led取反一次
        led_out<=~led_out;
    else                 //没到0.5s时 led状态保持不变
        led_out<=led_out;	

endmodule