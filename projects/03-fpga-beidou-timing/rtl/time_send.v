	
	module time_send(
	
		input wire clk,  ////50mhz
		input wire rst_n,
		
		input wire [19:0] gps_decode_hour,
		input wire [19:0] gps_decode_minute,
		input wire [19:0] gps_decode_second,
		
		
		//gps解析出来的UTC时间
		input wire [3:0] 	hour_H_r,
	   input wire [3:0]  hour_L_r,
	   input wire [3:0] 	min_H_r,
	   input wire [3:0] 	min_L_r,	
	   input wire [3:0] 	second_H_r,	
	   input wire [3:0] 	second_L_r,
		
		input wire gps_pps,
		
		//输出IRIG-B串行时间码信号
		
		output wire gpio_out_irig_b_signal,
		
		output reg [19:0] final_display_time  //hh:min:ss
		
	);

	
	///cnt 1.001s if no gps_pps ,use system time.  else use gps_time
	/// clk use 50 Mhz 
	
	//PPS上升沿加载最新的GPS时间，如果GPS信号异常，使用系统管理维护的时间
	
	
	//系统管理维护的时间 北京时间的时分秒
	
	reg  [7:0] hour_system;
	reg  [7:0] minute_system;
	reg  [7:0] second_system;
	
	//将传输过来的时间 直接转成北京时间 小时 分钟 秒
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				hour_system <= 8'd0;
				minute_system <= 8'd0;
				second_system <= 8'd0;
			end 
		else 
			begin 
			//	hour_system <= hour_H_r * 10 + hour_L_r + 8 ;
				
				hour_system <= ((hour_H_r * 10 + hour_L_r + 8) > 24) ? (hour_H_r * 10 + hour_L_r + 8 - 24) : (hour_H_r * 10 + hour_L_r + 8 );
				
				minute_system <= min_H_r *10 + min_L_r ;
				second_system <= second_H_r * 10 + second_L_r;
			end 
	end 
	
	//if gps signal loss , use system time 
	// check pps rise edge 
	
	reg pps_reg1 = 1'b0;
	reg pps_reg2 = 1'b0;
	reg pps_rise_edge = 1'b0;
	
	reg pps_rise_edge_r1 = 1'b0;
	reg pps_rise_edge_r2 = 1'b0;
	reg pps_rise_edge_r3 = 1'b0;
	reg pps_rise_edge_r4 = 1'b0;
	reg pps_rise_edge_r5 = 1'b0;
	reg pps_rise_edge_r6 = 1'b0;
	reg pps_rise_edge_r7 = 1'b0;
	reg pps_rise_edge_r8 = 1'b0;
	
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				pps_reg1 <= 1'b0;
				pps_reg2 <= 1'b0;
				pps_rise_edge <= 1'b0;
			end 
		else 
			begin 
				pps_reg1 <= gps_pps;
				pps_reg2 <= pps_reg1;
				pps_rise_edge <= pps_reg1 && (~pps_reg2);
			end 
	end 
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				pps_rise_edge_r1 <= 1'b0;
				pps_rise_edge_r2 <= 1'b0;
				pps_rise_edge_r3 <= 1'b0;
				pps_rise_edge_r4 <= 1'b0;
				pps_rise_edge_r5 <= 1'b0;
				pps_rise_edge_r6 <= 1'b0;
				pps_rise_edge_r7 <= 1'b0;
				pps_rise_edge_r8 <= 1'b0;
			end 
		else 
			begin 
				pps_rise_edge_r1 <= pps_rise_edge;
				pps_rise_edge_r2 <= pps_rise_edge_r1;
				pps_rise_edge_r3 <= pps_rise_edge_r2;
				pps_rise_edge_r4 <= pps_rise_edge_r3;
				pps_rise_edge_r5 <= pps_rise_edge_r4;
				pps_rise_edge_r6 <= pps_rise_edge_r5;
				pps_rise_edge_r7 <= pps_rise_edge_r6;
				pps_rise_edge_r8 <= pps_rise_edge_r7;
			end 
	end 
	
	
	
	
	reg [7:0] mana_time_hour = 8'd0;
	reg [7:0] mana_time_min = 8'd0;
	reg [7:0] mana_time_sec = 8'd0;
	
	//clk = 50mhz  s = 49_999_999  min = 2_999_999_999 hour = 179_999_999_999
	
	parameter TIME_1S = 64'd49_999_999;
	parameter TIME_1MIN = 64'd2_999_999_999;
	parameter TIME_1HOUR = 64'd179_999_999_999;
	
	reg [63:0] delay_cnt1_hour = 64'd0;
	reg [63:0] delay_cnt1_min = 64'd0;
	reg [63:0] delay_cnt1_sec = 64'd0;
	
	wire no_gps_1s_flag;
	wire no_gps_1min_flag;
	wire no_gps_1hour_flag;
	
	
	///////////////////////////////////////
	
	
always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				delay_cnt1_sec <= 64'd0;
			end 
		else if(pps_rise_edge)
			begin 
				delay_cnt1_sec <= 64'd0;
			end 
		else 
			begin 
				if(delay_cnt1_sec == TIME_1S)
					begin 
						delay_cnt1_sec <= 64'd0;
					end 
				else 
					begin 
						delay_cnt1_sec <= delay_cnt1_sec + 1'b1;
					end 
			end 
	end 
	
	
	
	
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				mana_time_hour <= 8'd0;
				mana_time_min <= 8'd0;
				mana_time_sec <= 8'd0;
			end 
		else if(pps_rise_edge) //如果检测到秒脉冲信号，系统的时间使用gps时间
			begin 
				mana_time_hour <= hour_system ;
				mana_time_min <= minute_system ;
				mana_time_sec <= second_system ;
			end 
		else 
			begin 
			
					
						if(delay_cnt1_sec == TIME_1S)
							begin 
								if(mana_time_sec == 8'd59)
									begin 
										mana_time_sec <= 8'd0;
									end 
								else 
									begin 
										mana_time_sec <= mana_time_sec + 1'b1 ;
									end 
							end 
				
					  if((delay_cnt1_sec == TIME_1S) && (mana_time_sec == 8'd59)) //秒到了最后的时刻，分进行自加1
							begin 
								if(mana_time_min == 8'd59)
									begin 
										mana_time_min <= 8'd0;
									end 
								else 
									begin 
										mana_time_min <= mana_time_min + 1'b1;
									end 
							end 
						
				
					
				
						if(((delay_cnt1_sec == TIME_1S) && (mana_time_sec == 8'd59)) && (mana_time_min == 8'd59))
							begin 
								if(mana_time_hour == 8'd59)
									begin 
										mana_time_hour <= 8'd0;
									end 
								else 
									begin 
										mana_time_hour <= mana_time_hour + 1'b1 ;
									end 
							end 
			end 
	end 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
//	
//	
//	always @ (posedge clk or negedge rst_n)
//	begin 
//		if(~rst_n)
//			begin 
//				delay_cnt1_sec <= 64'd0;
//			end 
//		else if(pps_rise_edge)
//			begin 
//				delay_cnt1_sec <= 64'd0;
//			end 
//		else 
//			begin 
//				if(delay_cnt1_sec == TIME_1S)
//					begin 
//						delay_cnt1_sec <= 64'd0;
//					end 
//				else 
//					begin 
//						delay_cnt1_sec <= delay_cnt1_sec + 1'b1;
//					end 
//			end 
//	end 
//	
//	always @ (posedge clk or negedge rst_n)
//	begin 
//		if(~rst_n)
//			begin 
//				delay_cnt1_min <= 64'd0;
//			end 
//		else if(pps_rise_edge)
//			begin 
//				delay_cnt1_min <= 64'd0;
//			end 
//		else 
//			begin 
//				if(delay_cnt1_min == TIME_1MIN)
//					begin 
//						delay_cnt1_min <= 64'd0;
//					end 
//				else 
//					begin 
//						delay_cnt1_min <= delay_cnt1_min + 1'b1;
//					end 
//			end 
//	end 
//	
//	always @ (posedge clk or negedge rst_n)
//	begin 
//		if(~rst_n)
//			begin 
//				delay_cnt1_hour <= 64'd0;
//			end 
//		else if(pps_rise_edge)
//			begin 
//				delay_cnt1_hour <= 64'd0;
//			end 
//		else 
//			begin 
//				if(delay_cnt1_hour == TIME_1HOUR)
//					begin 
//						delay_cnt1_hour <= 64'd0;
//					end 
//				else 
//					begin 
//						delay_cnt1_hour <= delay_cnt1_hour + 1'b1;
//					end 
//			end 
//	end 
//	
//	
//	
//	//如果GPS信号非常好的情况，使用的是GPS的授时时间，否则使用的是系统自己运行的时间
//	always @ (posedge clk or negedge rst_n)
//	begin 
//		if(~rst_n)
//			begin 
//				mana_time_hour <= 8'd0;
//				mana_time_min <= 8'd0;
//				mana_time_sec <= 8'd0;
//			end 
//		else if(pps_rise_edge) //如果检测到秒脉冲信号，系统的时间使用gps时间
//			begin 
//				mana_time_hour <= hour_system ;
//				mana_time_min <= minute_system ;
//				mana_time_sec <= second_system ;
//			end 
//		else 
//			begin 
//			
//					
//						if(delay_cnt1_sec == TIME_1S)
//							begin 
//								if(mana_time_sec == 8'd59)
//									begin 
//										mana_time_sec <= 8'd0;
//									end 
//								else 
//									begin 
//										mana_time_sec <= mana_time_sec + 1'b1 ;
//									end 
//							end 
//				
//					  if(delay_cnt1_min == TIME_1MIN)
//							begin 
//								if(mana_time_min == 8'd59)
//									begin 
//										mana_time_min <= 8'd0;
//									end 
//								else 
//									begin 
//										mana_time_min <= mana_time_min + 1'b1;
//									end 
//							end 
//						
//				
//					
//				
//						if(mana_time_hour == 8'd23  )
//							begin 
//								mana_time_hour <= 8'd0;
//							end 
//						else if(no_gps_1hour_flag)
//							begin 
//								mana_time_hour <= mana_time_hour + 1'b1 ;
//							end 
//					
//						
//			end 
//	end 
	

	
	
	
////如果GPS信号是正常的，由GPS授时之后的时间，	
	
	
	reg [7:0] mana_time_hour_r1 = 8'd0;
	reg [7:0] mana_time_min_r1 = 8'd0;
	reg [7:0] mana_time_sec_r1 = 8'd0;
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				mana_time_hour_r1 <= 8'd0;
				mana_time_min_r1 <= 8'd0;
				mana_time_sec_r1 <= 8'd0;
			end 
		else 
			begin 
				mana_time_hour_r1 <= mana_time_hour;
				mana_time_min_r1 <= mana_time_min ;
				mana_time_sec_r1 <= mana_time_sec ;
			end 
	end 
	
	
	
	wire [3:0] unit_hour;
	wire [3:0] ten_hour;
	
	wire [3:0] unit_min;
	wire [3:0] ten_min;
	
	wire [3:0] unit_sec;
	wire [3:0] ten_sec;
	
	
	  bcd_8421 bcd_8421_hour
(
    .   sys_clk(clk)     ,   //系统时钟，频率50MHz
    .  sys_rst_n(rst_n)   ,   //复位信号，低电平有效
    .  data(mana_time_hour_r1)        ,   //输入需要转换的数据

    .  unit(unit_hour)        ,   //个位BCD码
    .  ten(ten_hour)         ,   //十位BCD码
    .  hun()         ,   //百位BCD码
    .  tho()         ,   //千位BCD码
    .  t_tho()       ,   //万位BCD码
    . h_hun()           //十万位BCD码
);
	
		  bcd_8421 bcd_8421_min
(
    .   sys_clk(clk)     ,   //系统时钟，频率50MHz
    .  sys_rst_n(rst_n)   ,   //复位信号，低电平有效
    .  data(mana_time_min_r1)        ,   //输入需要转换的数据

    .  unit(unit_min)        ,   //个位BCD码
    .  ten(ten_min)         ,   //十位BCD码
    .  hun()         ,   //百位BCD码
    .  tho()         ,   //千位BCD码
    .  t_tho()       ,   //万位BCD码
    . h_hun()           //十万位BCD码
);
	
			  bcd_8421 bcd_8421_sec
(
    .   sys_clk(clk)     ,   //系统时钟，频率50MHz
    .  sys_rst_n(rst_n)   ,   //复位信号，低电平有效
    .  data(mana_time_sec_r1)        ,   //输入需要转换的数据

    .  unit(unit_sec)        ,   //个位BCD码
    .  ten(ten_sec)         ,   //十位BCD码
    .  hun()         ,   //百位BCD码
    .  tho()         ,   //千位BCD码
    .  t_tho()       ,   //万位BCD码
    . h_hun()           //十万位BCD码
);
	
	
	
	
	wire [7:0] mem [1:100];
	
	assign mem[1] = 8'h70; ////P  B码序列基准
	assign mem[2] = (unit_sec[0] == 1'b0) ? 8'h30:8'h31; ////0  秒个位 P2 - P5   低位在前
	assign mem[3] = (unit_sec[1] == 1'b0) ? 8'h30:8'h31; ////0  秒个位 P2 - P5   低位在前
	assign mem[4] = (unit_sec[2] == 1'b0) ? 8'h30:8'h31; ////0  秒个位 P2 - P5   低位在前
	assign mem[5] = (unit_sec[3] == 1'b0) ? 8'h30:8'h31; ////1  秒个位 P2 - P5   低位在前
	assign mem[6] = 8'h30; ////0 
	assign mem[7] = (ten_sec[0] == 1'b0) ? 8'h30:8'h31; ////0  秒十位 P7 - P9   低位在前
	assign mem[8] = (ten_sec[1] == 1'b0) ? 8'h30:8'h31; ////0  秒十位 P7 - P9   低位在前
	assign mem[9] = (ten_sec[2] == 1'b0) ? 8'h30:8'h31; ////0  秒十位 P7 - P9   低位在前
	
	assign mem[10] = 8'h70; ////P
	assign mem[11] = (unit_min[0] == 1'b0) ? 8'h30:8'h31; ////0 分个位 P11 - P14 低位在前
	assign mem[12] = (unit_min[1] == 1'b0) ? 8'h30:8'h31; ////0 分个位 P11 - P14 低位在前
	assign mem[13] = (unit_min[2] == 1'b0) ? 8'h30:8'h31; ////0 分个位 P11 - P14 低位在前
	assign mem[14] = (unit_min[3] == 1'b0) ? 8'h30:8'h31; ////1 分个位 P11 - P14 低位在前
	assign mem[15] = 8'h30; ////0
	assign mem[16] = (ten_min[0] == 1'b0) ? 8'h30:8'h31; ////0 分十位 P16 - P18 低位在前
	assign mem[17] = (ten_min[1] == 1'b0) ? 8'h30:8'h31; ////0 分十位 P16 - P18 低位在前
	assign mem[18] = (ten_min[2] == 1'b0) ? 8'h30:8'h31; ////1 分十位 P16 - P18 低位在前
	assign mem[19] = 8'h30; ////0
	
	assign mem[20] = 8'h70; ////P
	assign mem[21] = (unit_hour[0] == 1'b0) ? 8'h30:8'h31; ////1 时个位 P21 - P24 低位在前 
	assign mem[22] = (unit_hour[1] == 1'b0) ? 8'h30:8'h31; ////0 时个位 P21 - P24 低位在前
	assign mem[23] = (unit_hour[2] == 1'b0) ? 8'h30:8'h31; ////0 时个位 P21 - P24 低位在前
	assign mem[24] = (unit_hour[3] == 1'b0) ? 8'h30:8'h31; ////0 时个位 P21 - P24 低位在前
	assign mem[25] = 8'h30; ////0
	assign mem[26] = (ten_hour[0] == 1'b0) ? 8'h30:8'h31; ////0 时十位 P26 - P27 低位在前
	assign mem[27] = (ten_hour[1] == 1'b0) ? 8'h30:8'h31; ////0 时十位 P26 - P27 低位在前
	
	
	
	
	
//	assign mem[1] = 8'h70; ////P
//	assign mem[2] = 8'h30; ////0
//	assign mem[3] = 8'h30; ////0
//	assign mem[4] = 8'h30; ////0
//	assign mem[5] = 8'h31; ////1
//	assign mem[6] = 8'h30; ////0
//	assign mem[7] = 8'h30; ////0
//	assign mem[8] = 8'h30; ////0
//	assign mem[9] = 8'h30; ////0
//	
//	assign mem[10] = 8'h70; ////P
//	assign mem[11] = 8'h30; ////0
//	assign mem[12] = 8'h30; ////0
//	assign mem[13] = 8'h30; ////0
//	assign mem[14] = 8'h31; ////1
//	assign mem[15] = 8'h30; ////0
//	assign mem[16] = 8'h30; ////0
//	assign mem[17] = 8'h30; ////0
//	assign mem[18] = 8'h31; ////1
//	assign mem[19] = 8'h30; ////0
//	
//	assign mem[20] = 8'h70; ////P
//	assign mem[21] = 8'h31; ////1
//	assign mem[22] = 8'h30; ////0
//	assign mem[23] = 8'h30; ////0
//	assign mem[24] = 8'h30; ////0
//	assign mem[25] = 8'h30; ////0
//	assign mem[26] = 8'h30; ////0
//	assign mem[27] = 8'h30; ////0
//	assign mem[28] = 8'h30; ////0
//	assign mem[29] = 8'h30; ////0
//	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	assign mem[28] = 8'h30; ////0
	assign mem[29] = 8'h30; ////0
	
	assign mem[30] = 8'h70; ////P
	assign mem[31] = 8'h31; ////1
	assign mem[32] = 8'h30; ////0
	assign mem[33] = 8'h30; ////0
	assign mem[34] = 8'h30; ////0
	assign mem[35] = 8'h30; ////0
	assign mem[36] = 8'h31; ////1
	assign mem[37] = 8'h30; ////0
	assign mem[38] = 8'h31; ////1
	assign mem[39] = 8'h30; ////0
	
	assign mem[40] = 8'h70; ////P
	assign mem[41] = 8'h30; ////0
	assign mem[42] = 8'h31; ////1
	assign mem[43] = 8'h30; ////0
	assign mem[44] = 8'h30; ////0
	assign mem[45] = 8'h30; ////0
	assign mem[46] = 8'h30; ////0
	assign mem[47] = 8'h30; ////0
	assign mem[48] = 8'h30; ////0
	assign mem[49] = 8'h30; ////0
	
	assign mem[50] = 8'h70; ////P
	assign mem[51] = 8'h31; ////1
	assign mem[52] = 8'h30; ////0
	assign mem[53] = 8'h30; ////0
	assign mem[54] = 8'h30; ////0
	assign mem[55] = 8'h30; ////0
	assign mem[56] = 8'h30; ////0
	assign mem[57] = 8'h31; ////1
	assign mem[58] = 8'h30; ////0
	assign mem[59] = 8'h30; ////0
	
	assign mem[60] = 8'h70; ////P
	assign mem[61] = 8'h30; ////0
	assign mem[62] = 8'h30; ////0
	assign mem[63] = 8'h30; ////0
	assign mem[64] = 8'h30; ////0
	assign mem[65] = 8'h30; ////0
	assign mem[66] = 8'h30; ////0
	assign mem[67] = 8'h30; ////0
	assign mem[68] = 8'h30; ////0
	assign mem[69] = 8'h30; ////0
	
	assign mem[70] = 8'h70; ////P
	assign mem[71] = 8'h30; ////0
	assign mem[72] = 8'h30; ////0
	assign mem[73] = 8'h30; ////0
	assign mem[74] = 8'h30; ////0
	assign mem[75] = 8'h30; ////0
	assign mem[76] = 8'h31; ////1
	assign mem[77] = 8'h30; ////0
	assign mem[78] = 8'h30; ////0
	assign mem[79] = 8'h30; ////0
	
	assign mem[80] = 8'h70; ////P
	assign mem[81] = 8'h30; ////0
	assign mem[82] = 8'h30; ////0
	assign mem[83] = 8'h30; ////0
	assign mem[84] = 8'h31; ////1
	assign mem[85] = 8'h31; ////1
	assign mem[86] = 8'h30; ////0
	assign mem[87] = 8'h31; ////1
	assign mem[88] = 8'h30; ////0
	assign mem[89] = 8'h31; ////1
	
	assign mem[90] = 8'h70; ////P
	assign mem[91] = 8'h30; ////0
	assign mem[92] = 8'h30; ////0
	assign mem[93] = 8'h31; ////1
	assign mem[94] = 8'h31; ////1
	assign mem[95] = 8'h30; ////0
	assign mem[96] = 8'h30; ////0
	assign mem[97] = 8'h30; ////0
	assign mem[98] = 8'h30; ////0
	assign mem[99] = 8'h30; ////0
	
	assign mem[100] = 8'h70; ////P
	
	
	

	reg ex_device_b_code;
	
	reg [7:0] state;
	reg [7:0] b_code_read_num;
	reg [31:0] delay_cnt = 32'd0;
	
	parameter  IDLE = 8'd0;
	parameter S0 = 8'd1;
	parameter S1 = 8'd2;
	parameter S2 = 8'd3;
	parameter S3 = 8'd4;
	parameter S4 = 8'd5;
	
	localparam TIME_8MS = 400000;
	localparam TIME_5MS = 250_000;
	localparam TIME_2MS = 100_000;
	localparam TIME_10MS = 500000;
	
	
	always @ (posedge clk or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				ex_device_b_code <= 1'b0;
				state <= IDLE;
				delay_cnt <= 32'd0;
				b_code_read_num <= 8'd1;
			end 
		else 
			begin 
				case(state)
					IDLE:
						begin 
					
								if(mem[b_code_read_num] == 8'h70)
									begin 
										state <= S0;
										delay_cnt <= 32'd0;
									end 
								else if(mem[b_code_read_num] == 8'h30)
									begin 
										state <= S1;
										delay_cnt <= 32'd0;
									end 
								else if(mem[b_code_read_num] == 8'h31)
									begin 
										state <= S2;
										delay_cnt <= 32'd0;
									end 
						end 
						
					S0://///计时10MS    P
						begin 
							if(delay_cnt == TIME_10MS - 2)
								begin 
									delay_cnt <= 32'd0;
									state <= S3;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						
							if(delay_cnt <= TIME_8MS -1)
								begin 
									ex_device_b_code <= 1'b1;
								end 
							else 
								begin 
									ex_device_b_code <= 1'b0;
								end 
						end 
						
						S1://///计时10MS    0
						begin 
							if(delay_cnt == TIME_10MS - 2)
								begin 
									delay_cnt <= 32'd0;
									state <= S3;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						
							if(delay_cnt <= TIME_2MS -1)
								begin 
									ex_device_b_code <= 1'b1;
								end 
							else 
								begin 
									ex_device_b_code <= 1'b0;
								end 
						end 
						
						S2://///计时10MS    1
						begin 
							if(delay_cnt == TIME_10MS - 2)
								begin 
									delay_cnt <= 32'd0;
									state <= S3;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						
							if(delay_cnt <= TIME_5MS -1)
								begin 
									ex_device_b_code <= 1'b1;
								end 
							else 
								begin 
									ex_device_b_code <= 1'b0;
								end 
						end 
						
						S3:
							begin 
								if(b_code_read_num == 100)
									begin 
										b_code_read_num <= 8'd1;
									end 
								else 
									begin 
										b_code_read_num <= b_code_read_num + 1'b1;
									end 
									
								state <= IDLE;
							
							end 
						
				endcase 
			end 
	end 
	
	
	
	
	assign gpio_out_irig_b_signal = ex_device_b_code ;
	
	

	endmodule 




























