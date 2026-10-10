
	module GxRMC_decode(
	
		input wire sys_clk,
		input wire sys_rst_n,
		
		input wire [7:0] po_data,
		input wire po_flag,
		
		output reg [3:0] 	hour_H_r,
	   output reg [3:0]  hour_L_r,
	   output reg [3:0] 	min_H_r,
	   output reg [3:0] 	min_L_r,	
	   output reg [3:0] 	second_H_r,	
	   output reg [3:0] 	second_L_r,
		
		
		
		output reg [19:0] final_time
	
	
	);
	localparam FRAME_START = 8'h24;   //ASCII码 $ 的16进制表示
	localparam FRAME_TYPE = 40'h47_50_52_4d_43; //GPRMC
	
	reg [7:0] state;
	parameter IDLE = 8'd0;
	parameter S0 = 8'd1;
	parameter S1 = 8'd2;
	parameter S2 = 8'd3;
	parameter S3 = 8'd4;
	parameter S4 = 8'd5;
	parameter S5 = 8'd6;
	parameter S6 = 8'd7;
	parameter S7 = 8'd8;
	parameter S8 = 8'd9;
	parameter S9 = 8'd10;
	parameter S10 = 8'd11;
	parameter S11 = 8'd12;
	parameter S12 = 8'd13;
	
	
	
	
	reg [39:0] shift_reg = 40'd0;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				shift_reg <= 40'd0;
			end 
		else if(po_flag)
			begin 
				shift_reg <= {shift_reg[31:0], po_data};
			end 
	
	end 
	
	
	
	
	
	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				state <= IDLE;
			end 
		else 	
			begin 
				case(state)
				
					IDLE:
						begin 
							if(shift_reg == FRAME_TYPE)
								begin 
									state <= S5;
								end 
							else 
								begin 
									state <= state;
								end 
						end 
				
				
				
//					IDLE:
//						begin 
//							if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= S0;
//								end 
//							else 
//								begin 
//									state <= IDLE;
//								end 
//						end 
						
//					S0:
//						begin 
//							if(po_flag && (po_data == FRAME_TYPE[39:32]))//G
//								begin 
//									state <= S1;
//								end 
//							else if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= IDLE;
//								end 
//							else 
//								begin 
//									state <= state;
//								end 
//						end 
//					
//					S1:
//						begin 
//							if(po_flag && (po_data == FRAME_TYPE[31:24]))//N
//								begin 
//									state <= S2;
//								end 
//							else if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= IDLE;
//								end 
//							else 
//								begin 
//									state <= state;
//								end 
//						end 
//						
//					S2:
//						begin 
//							if(po_flag && (po_data == FRAME_TYPE[23:16]))//R
//								begin 
//									state <= S3;
//								end 
//							else if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= IDLE;
//								end 
//							else 
//								begin 
//									state <= state;
//								end 
//						end 
//						
//					S3:
//						begin 
//							if(po_flag && (po_data == FRAME_TYPE[15:8]))//M
//								begin 
//									state <= S4;
//								end 
//							else if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= IDLE;
//								end 
//							else 
//								begin 
//									state <= state;
//								end 
//						end 
//						
//					S4:
//						begin 
//							if(po_flag && (po_data == FRAME_TYPE[7:0]))//C
//								begin 
//									state <= S5;
//								end 
//							else if(po_flag && (po_data == FRAME_START))//$
//								begin 
//									state <= IDLE;
//								end 
//							else 
//								begin 
//									state <= state;
//								end 
//						end 	
						
					S5:	
						begin 
							if(po_flag && (po_data == 8'h2a))//*
								begin 
									state <= S6;
								end 
							else if(po_flag && (po_data == FRAME_START))//$
								begin 
									state <= IDLE;
								end 
							else 
								begin 
									state <= state;
								end 
						end 
						
					S6://接收第1个校验值
						begin 
							if(po_flag)
								begin 
									state <= S7;
								end 
							else 
								begin 
									state <= state;
								end 
						end 
					
					S7://接收第2个校验值
						begin 
							if(po_flag)
								begin 
									state <= S8;
								end 
							else 
								begin 
									state <= state;
								end 
						end 
						
					S8:
						begin 
							state <= S9;
						end 
					
					S9:
						begin 
							state <= S10;
						end 
						
					S10:
						begin 
							state <= S11;
						end 
						
					S11:
						begin 
							state <= IDLE;
						end 
				endcase 
			end 
	end 
	
	
	//逗号计数器
	reg [7:0] comma_cnt;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				comma_cnt <= 8'd0;
			end 
		else if(po_flag && (po_data == FRAME_START))
			begin 
				comma_cnt <= 8'd0;
			end 
		else if(po_flag && (po_data == 8'h2c))//逗号
			begin 
				comma_cnt <= comma_cnt + 1'b1;
			end 
	end 
	
	//校验使能信号
	
	reg xor_en;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				xor_en <= 1'b0;
			end 
		else if(po_flag && (po_data == FRAME_START))
			begin 
				xor_en <= 1'b1;
			end 
		else if(po_flag && (po_data == 8'h2a))//*
			begin 
				xor_en <= 1'b0;
			end 
	end 
	
	//程序接收进行的异或校验结果
	reg [7:0] xor_result;
	reg [7:0] xor_result_latch;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				xor_result <= 8'h0;
				xor_result_latch <= 8'd0;
			end 
		else if(po_flag && (po_data == FRAME_START))// $
			begin 
				xor_result <= 8'h0;
			end
		else if(po_flag && (po_data == 8'h2a))//*
			begin 
				xor_result <= xor_result;
				xor_result_latch <= xor_result; 
			end 
		else if(po_flag)
			begin 
				xor_result <= xor_result ^ po_data;
			end 
	end 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	//校验译码
	reg [7:0] ascii_xor1;
	reg [7:0] ascii_xor2;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				ascii_xor1 <= 8'h0;
			end 
		else if(state == IDLE)
			begin 
				ascii_xor1 <= 8'h0;
			end 
		else if(state == S8)
			begin 
				case(xor_result_latch[7:4])
					 4'h0 : ascii_xor1 <= 8'h30;
					  4'h1 : ascii_xor1 <= 8'h31;
					  4'h2 : ascii_xor1 <= 8'h32;
					  4'h3 : ascii_xor1 <= 8'h33;
					  4'h4 : ascii_xor1 <= 8'h34;
					  4'h5 : ascii_xor1 <= 8'h35;
					  4'h6 : ascii_xor1 <= 8'h36;
					  4'h7 : ascii_xor1 <= 8'h37;
					  4'h8 : ascii_xor1 <= 8'h38;
					  4'h9 : ascii_xor1 <= 8'h39;
					  4'ha : ascii_xor1 <= 8'h41;
					  4'hb : ascii_xor1 <= 8'h42;
					  4'hc : ascii_xor1 <= 8'h43;
					  4'hd : ascii_xor1 <= 8'h44;
					  4'he : ascii_xor1 <= 8'h45;
					  4'hf : ascii_xor1 <= 8'h46;
					  default : ascii_xor1 <= 8'h00;
				endcase 
			end 
	end 
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				ascii_xor2 <= 8'h0;
			end 
		else if(state == IDLE)
			begin 
				ascii_xor2 <= 8'h0;
			end 
		else if(state == S8)
			begin 
				case(xor_result_latch[3:0])
					  4'h0 : ascii_xor2 <= 8'h30;
					  4'h1 : ascii_xor2 <= 8'h31;
					  4'h2 : ascii_xor2 <= 8'h32;
					  4'h3 : ascii_xor2 <= 8'h33;
					  4'h4 : ascii_xor2 <= 8'h34;
					  4'h5 : ascii_xor2 <= 8'h35;
					  4'h6 : ascii_xor2 <= 8'h36;
					  4'h7 : ascii_xor2 <= 8'h37;
					  4'h8 : ascii_xor2 <= 8'h38;
					  4'h9 : ascii_xor2 <= 8'h39;
					  4'ha : ascii_xor2 <= 8'h41;
					  4'hb : ascii_xor2 <= 8'h42;
					  4'hc : ascii_xor2 <= 8'h43;
					  4'hd : ascii_xor2 <= 8'h44;
					  4'he : ascii_xor2 <= 8'h45;
					  4'hf : ascii_xor2 <= 8'h46;
					  default : ascii_xor2 <= 8'h00;
				endcase 
			end 
	end 
	
	//校验比对，校验是否正确
	reg xor_right;
	
	//接收2个字节的校验值
	reg[7:0] first_byte_xor;
	reg [7:0] second_byte_xor;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				xor_right <= 1'b0;
			end 
		else if(state == IDLE)
			begin 
				xor_right <= 1'b0;
			end 
		else if((state == S9) && ({first_byte_xor,second_byte_xor} == {ascii_xor1,ascii_xor2}))
			begin 
				xor_right <= 1'b1;
			end 
	end 
	

	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				first_byte_xor <= 8'h0;
			end 
		else if(po_flag && (state == S6))
			begin 
				first_byte_xor <= po_data;
			end 
		else 
			begin 
				first_byte_xor <= first_byte_xor;
			end 
	end 
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				second_byte_xor <= 8'h0;
			end 
		else if(po_flag && (state == S7))
			begin 
				second_byte_xor <= po_data;
			end 
		else 
			begin 
				second_byte_xor <= second_byte_xor; 
			end 
	end 
	
	
	////捕获时间
	reg [47:0] tmp_hms;
	reg [7:0]  tmp_cnt;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				tmp_cnt <= 8'd0;
			end 
		else if(po_flag && (state == S5) && (comma_cnt == 8'd1))
			begin 
				tmp_cnt <= tmp_cnt + 1'b1;
			end 
		else  if(state == IDLE)
			begin 
				tmp_cnt <= 8'd0;
			end 
	end 
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				tmp_hms <= 48'd0;
			end 
		else if(po_flag && (state == S5) && (comma_cnt == 8'd1))
			begin 
				case(tmp_cnt)
					8'd0: tmp_hms[47:40] <= po_data;
					8'd1: tmp_hms[39:32] <= po_data;
					8'd2: tmp_hms[31:24] <= po_data;
					8'd3: tmp_hms[23:16] <= po_data;
					8'd4: tmp_hms[15:8] <= po_data;
					8'd5: tmp_hms[7:0] <= po_data;
					default : tmp_hms <= tmp_hms;
				endcase 
			end 
	end 
	
	
	
	
	
	///捕获定位是否有效
	
	reg [7:0] dingwei_status;
	reg [7:0] dingwei_receive_cnt;
	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				dingwei_receive_cnt <= 8'd0;
			end 
		else if(po_flag && (state == S5) && (comma_cnt == 8'd2))
			begin 
				dingwei_receive_cnt <= dingwei_receive_cnt + 1'b1;
			end 
		else if(state == IDLE)
			begin 
				dingwei_receive_cnt <= 8'd0;
			end 
	end 
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				dingwei_status <= 8'd0;
			end 
		else if(po_flag && (state == S5) && (comma_cnt == 8'd2) && (dingwei_receive_cnt == 8'd0))
			begin 
				dingwei_status <= po_data;
			end 
	end 
	
	
	
	
	
	
	
	
	
	
	
	//如果定位有效且校验正确，则锁定时间信息，准备送往数码管
	//如果定位有效且校验正确，则锁定时间信息，准备送往数码管
	//如果定位有效且校验正确，则锁定时间信息，准备送往数码管
	//如果定位有效且校验正确，则锁定时间信息，准备送往数码管
	
	
	
	reg [47:0] tmp_hms_valid;
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				tmp_hms_valid <= 48'd0;
			end 
	//	else if((state == S10) && xor_right && (dingwei_status == 8'h41))
		else if((state == S10) && (dingwei_status == 8'h41))
			begin 
				tmp_hms_valid <= tmp_hms;
			end 
		else 
			begin 
				tmp_hms_valid <= tmp_hms_valid;
			end 
	end 
	
	reg [7:0] xor_right_dingwei_valid_cnt;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				xor_right_dingwei_valid_cnt <= 1'b0;
			end 
		else if((state == S10) && xor_right && (dingwei_status == 8'h41))
			begin 
				if(xor_right_dingwei_valid_cnt == 8'd2)
					begin 
						xor_right_dingwei_valid_cnt <= xor_right_dingwei_valid_cnt;
					end 
				else 
					begin 
						xor_right_dingwei_valid_cnt <= xor_right_dingwei_valid_cnt + 1'b1;
					end 
			end 
	end 
	
	
	
	
	
	
	
	reg [3:0] miao_gewei;
	reg [3:0] miao_shiwei;
	
	reg [3:0] fen_gewei;
	reg [3:0] fen_shiwei;
	
	reg [3:0] shi_gewei;
	reg [3:0] shi_shiwei;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				miao_gewei <= 4'd0;
				miao_shiwei <= 4'd0;
				fen_gewei <= 4'd0;
				fen_shiwei <= 4'd0;
				shi_gewei <= 4'd0;
				shi_shiwei <= 4'd0;
			end 
		else 
			begin ////ASCII转十进制
				miao_gewei <= tmp_hms_valid[3:0];
				miao_shiwei <= tmp_hms_valid[11:8]; 	
	
				fen_gewei <= tmp_hms_valid[19:16];
				fen_shiwei <= tmp_hms_valid[27:24];
				
				shi_gewei <= tmp_hms_valid[35:32];
				shi_shiwei <= tmp_hms_valid[43:40];
			end 
	end 
	
	

	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				hour_H_r <= 4'd0;
				hour_L_r <= 4'd0;
				min_H_r <= 4'd0;
			   min_L_r <= 4'd0;
			   second_H_r <= 4'd0;
			   second_L_r <= 4'd0;
			end 
		else 
			begin 
				hour_H_r <= shi_shiwei;
				hour_L_r <= shi_gewei;
				min_H_r <= fen_shiwei;
			   min_L_r <= fen_gewei;
			   second_H_r <= miao_shiwei;
			   second_L_r <= miao_gewei;

			end 
	end 
	
	
	
	
	
	
	reg [19:0] miao_gewei_decimal;
	reg [19:0] miao_shiwei_decimal;
	
	reg [19:0] fen_gewei_decimal;
	reg [19:0] fen_shiwei_decimal;
	
	reg [19:0] hour_add8;
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				miao_gewei_decimal <= 20'd0;
				miao_shiwei_decimal <= 20'd0;
				fen_gewei_decimal <= 20'd0;
				fen_shiwei_decimal <= 20'd0;
				hour_add8 <= 20'd0;
				
				final_time <= 20'd0;
			end 
		else if(xor_right_dingwei_valid_cnt == 8'd2)
			begin 
			
				
				hour_add8 <= (((shi_shiwei*10 + shi_gewei) + 8) > 24) ? (((shi_shiwei*10 + shi_gewei) + 8 - 24) * 10000)  : ((shi_shiwei*10 + shi_gewei) + 8) * 10000;
				
				fen_shiwei_decimal <= fen_shiwei * 1000;
				fen_gewei_decimal <= fen_gewei * 100;
				miao_shiwei_decimal <= miao_shiwei * 10;
				miao_gewei_decimal <= miao_gewei * 1;
				
				final_time <= hour_add8 + fen_shiwei_decimal + fen_gewei_decimal + miao_shiwei_decimal + miao_gewei_decimal;
			end 
	end 
	
	
	
	//修正GPS解析出来的时间慢了1秒的情况
	
	reg [19:0] gps_time_hour_xx = 20'd0;
	reg [19:0] gps_time_min_xx = 20'd0;
	reg [19:0] gps_time_sec_xx = 20'd0;
	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				gps_time_hour_xx <= 20'd0;
				gps_time_min_xx <= 20'd0;
				gps_time_sec_xx <= 20'd0;
			end 
		else 
			begin 
				gps_time_hour_xx <= (((shi_shiwei*10 + shi_gewei) + 8) > 24) ? (((shi_shiwei*10 + shi_gewei) + 8 - 24) )  : ((shi_shiwei*10 + shi_gewei) + 8) ;
				gps_time_min_xx <= fen_shiwei_decimal * 10 + fen_gewei_decimal ;
				gps_time_sec_xx <= miao_shiwei_decimal * 10 + miao_gewei_decimal ;
			end 
	end 
	
	
	reg [19:0] gps_time_hour_xx_r1 = 20'd0;
	reg [19:0] gps_time_min_xx_r1 = 20'd0;
	reg [19:0] gps_time_sec_xx_r1 = 20'd0;
	
	
	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin 
		if(~sys_rst_n)
			begin 
				gps_time_hour_xx_r1 <= 20'd0;
				gps_time_min_xx_r1 <= 20'd0;
				gps_time_sec_xx_r1 <= 20'd0;
			end 
		else  if((gps_time_hour_xx >0) && (gps_time_min_xx > 0) && (gps_time_sec_xx > 0))  // 09:32:15
			begin 
				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
				gps_time_min_xx_r1 <= gps_time_min_xx ;
				gps_time_sec_xx_r1 <= gps_time_sec_xx - 1'b1;
			end 
		else  if((gps_time_hour_xx >0) && (gps_time_min_xx > 0) && (gps_time_sec_xx == 0))  // 09:32:00
			begin 
				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
				gps_time_min_xx_r1 <= gps_time_min_xx - 1; 
				gps_time_sec_xx_r1 <= 20'd59;
			end 	
//		else  if((gps_time_hour_xx >0) && (gps_time_min_xx ==  0) && (gps_time_sec_xx > 0))  // 09:00:04
//			begin 
//				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
//				gps_time_min_xx_r1 <= gps_time_min_xx - 1; 
//				gps_time_sec_xx_r1 <= 20'd59;
//			end

//		else  if((gps_time_hour_xx == 0) && (gps_time_min_xx > 0) && (gps_time_sec_xx > 0))  // 00:06:04
//			begin 
//				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
//				gps_time_min_xx_r1 <= gps_time_min_xx - 1; 
//				gps_time_sec_xx_r1 <= 20'd59;
//			end

		else  if((gps_time_hour_xx >0) && (gps_time_min_xx == 0) && (gps_time_sec_xx == 0))  // 09:00:00
			begin 
				gps_time_hour_xx_r1 <= gps_time_hour_xx - 1 ;
				gps_time_min_xx_r1 <= 20'd59; 
				gps_time_sec_xx_r1 <= 20'd59;
			end 	
//		else  if((gps_time_hour_xx == 0) && (gps_time_min_xx == 0) && (gps_time_sec_xx > 0))  // 00:00:34
//			begin 
//				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
//				gps_time_min_xx_r1 <= gps_time_min_xx - 1; 
//				gps_time_sec_xx_r1 <= 20'd59;
//			end 		
			
		else  if((gps_time_hour_xx == 0) && (gps_time_min_xx > 0) && (gps_time_sec_xx == 0))  // 00:34:00
			begin 
				gps_time_hour_xx_r1 <= gps_time_hour_xx  ;
				gps_time_min_xx_r1 <= gps_time_min_xx - 1; 
				gps_time_sec_xx_r1 <= 20'd59;
			end 	
		else  if((gps_time_hour_xx == 0) && (gps_time_min_xx == 0) && (gps_time_sec_xx == 0))  // 00:00:00
			begin 
				gps_time_hour_xx_r1 <= 20'd23  ;
				gps_time_min_xx_r1 <= 20'd59; 
				gps_time_sec_xx_r1 <= 20'd59;
			end 	
		else 
			begin 
				gps_time_hour_xx_r1 <= gps_time_hour_xx ;
				gps_time_min_xx_r1 <= gps_time_min_xx; 
				gps_time_sec_xx_r1 <= gps_time_sec_xx - 1;
			end 
			
	end 
	
	
//	always @ (posedge sys_clk or negedge sys_rst_n)
//	begin 
//		if(~sys_rst_n)
//			begin 
//				final_time <= 20'd0;
//			end 
//		else 
//			begin 
//				final_time <= gps_time_sec_xx_r1 + gps_time_min_xx_r1 * 100 + gps_time_hour_xx_r1 * 10000;
//			end 
//	
//	
//	
//	end 
	
	
	
	
	
	
	
	endmodule 

































