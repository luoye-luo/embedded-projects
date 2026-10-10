module   led_ctrl(

    //output   wire  led0,
	//output   wire  led1,
    //output   wire  led2,
    //output   wire  led3
//4位宽
	output   wire  [3:0]led0
);
   //assign      led0=1;
   //assign      led1=1;
   //assign	     led2=1;
   //assign      led3=1;
assign        led0=4'b1111 ; //4表示位宽 b表示2进制 1111表示数值
//十进制 d   八进制 o   十六进制 h   ASCAII
		
endmodule