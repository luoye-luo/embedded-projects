`timescale  1ns/1ns
///////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////

module  time_sync
(
    input   wire            sys_clk     ,   //系统时钟，频率50MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
	 
	 input   wire            gps_uart_rx,
	 input   wire            gps_pps,
	 
	 output wire      		 gpio_out_irig_b_signal,
	 input  wire             ex_irig_b_signal,
	 
	 
	  output  wire            stcp_b_code        ,   //输出数据存储寄时钟
    output  wire            shcp_b_code        ,   //移位寄存器的时钟输入
    output  wire            ds_b_code          ,   //串行数据输入
	 

    output  wire            stcp        ,   //输出数据存储寄时钟
    output  wire            shcp        ,   //移位寄存器的时钟输入
    output  wire            ds          ,   //串行数据输入
    output  wire            oe              //输出使能信号
);

//********************************************************************//
//******************** Parameter And Internal Signal *****************//
//********************************************************************//
//wire  define
wire    [19:0]  data    ;   //数码管要显示的值
wire    [5:0]   point   ;   //小数点显示,高电平有效top_seg_595
wire            seg_en  ;   //数码管使能信号，高电平有效
wire            sign    ;   //符号位，高电平显示负号

//********************************************************************//
//**************************** Main Code *****************************//
//********************************************************************//
//-------------data_gen_inst--------------

wire [7:0] po_data;
wire po_flag;

wire [19:0] final_time_r;


	wire pll_clk;
	wire pll_locked;
	wire pll_clk125mhz;

	pll pll(
		.inclk0(sys_clk),
		.c0(pll_clk),
		.c1(pll_clk125mhz),
		.locked(pll_locked)
		);






uart_rx uart_rx

(
    .   sys_clk(pll_clk)     ,   //系统时钟50MHz
    .  sys_rst_n(pll_locked)   ,   //全局复位
    . rx(gps_uart_rx)          ,   //串口接收数据

    .  po_data(po_data)     ,   //串转并后的8bit数据
    .   po_flag(po_flag)         //串转并后的数据有效标志信号
);




	wire [3:0] 	hour_H_r;
	wire [3:0]  hour_L_r;
	wire [3:0] 	min_H_r;
	wire [3:0] 	min_L_r;	
	wire [3:0] 	second_H_r;
	wire [3:0] 	second_L_r;




GxRMC_decode GxRMC_decode(

  . sys_clk(pll_clk),
  . sys_rst_n(pll_locked),
             
  . po_flag(po_flag),     //uart接收数据有效
  . po_data(po_data),        //uart接收数据
  
 . final_time(final_time_r),
 
 . hour_H_r(hour_H_r),
 . hour_L_r(hour_L_r),
 . min_H_r(min_H_r),
 . min_L_r(min_L_r),	
 . second_H_r(second_H_r),	
 . second_L_r(second_L_r)
 
);


	





//-------------seg7_dynamic_inst--------------
seg_595_dynamic    seg_595_dynamic_instl
(
    .sys_clk    (pll_clk   ),   //系统时钟，频率50MHz
    .sys_rst_n  (pll_locked ),   //复位信号，低有效
    .data       (final_time_r      ),   //数码管要显示的值
    .point      (1'b0     ),   //小数点显示,高电平有效
    .seg_en     (1'b1    ),   //数码管使能信号，高电平有效
    .sign       (sign      ),   //符号位，高电平显示负号

    .stcp       (stcp      ),   //输出数据存储寄时钟
    .shcp       (shcp      ),   //移位寄存器的时钟输入
    .ds         (ds        ),   //串行数据输入
    .oe         (oe        )    //输出使能信号
);






time_send time_send(
	
		. clk(pll_clk),  ////50mhz
		. rst_n(pll_locked),
		
		//gps解析出来的UTC时间
		. 	hour_H_r(hour_H_r),
	   .  hour_L_r(hour_L_r),
	   . 	min_H_r(min_H_r),
	   . 	min_L_r(min_L_r),	
	   . 	second_H_r(second_H_r),	
	   . 	second_L_r(second_L_r),
		
		. gps_pps(gps_pps),
		
		//输出IRIG-B串行时间码信号
		
		. gpio_out_irig_b_signal(gpio_out_irig_b_signal),
		
		. final_display_time()  //hh:min:ss
		
	);



		wire [3:0] second_gewei;
		wire [2:0] second_shiwei;
		
		wire [3:0] min_gewei;
		wire [2:0] min_shiwei;
		
		wire [3:0] hour_gewei;
		wire [1:0] hour_shiwei;


	B_CODE B_CODE(
		
			. clk_125mhz(pll_clk),
			. rst_n(pll_locked),
			
			. ex_device_b_code(ex_irig_b_signal),
			
			. second_gewei(second_gewei),
			. second_shiwei(second_shiwei),
			
			. min_gewei(min_gewei),
			. min_shiwei(min_shiwei),
			
			. hour_gewei(hour_gewei),
			. hour_shiwei(hour_shiwei),
			
			. day_gewei(),
			. day_shiwei(),
			. day_baiwei(),
			
			. year_gewei(),
			. year_shiwei()
		
		
		);
		
		
		
		reg [19:0] smg_display_b_code_time;
		
		always @ (posedge pll_clk or negedge pll_locked)
		begin 
			if(~pll_locked)
				begin 
					smg_display_b_code_time <= 20'd0;
				end 
			else 
				begin 
					smg_display_b_code_time <= hour_shiwei * 100000 + hour_gewei*10000 + min_shiwei*1000 + min_gewei*100 + second_shiwei * 10 + second_gewei;
		
				end 
		end 
		
		
		
		
		
		
		




//-------------seg7_dynamic_inst--------------
seg_595_dynamic    seg_595_dynamic_instl_b_code
(
    .sys_clk    (pll_clk   ),   //系统时钟，频率50MHz
    .sys_rst_n  (pll_locked ),   //复位信号，低有效
    .data       (   smg_display_b_code_time   ),   //数码管要显示的值
    .point      (1'b0     ),   //小数点显示,高电平有效
    .seg_en     (1'b1    ),   //数码管使能信号，高电平有效
    .sign       (sign      ),   //符号位，高电平显示负号

    .stcp       (stcp_b_code      ),   //输出数据存储寄时钟
    .shcp       (shcp_b_code      ),   //移位寄存器的时钟输入
    .ds         (ds_b_code        ),   //串行数据输入
    .oe         (        )    //输出使能信号
);







endmodule
