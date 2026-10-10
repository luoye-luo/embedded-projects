

	module B_CODE(
	
		input wire clk_125mhz,
		input wire rst_n,
		
		input wire ex_device_b_code,
		
		output reg [3:0] second_gewei,
		output reg [2:0] second_shiwei,
		
		output reg [3:0] min_gewei,
		output reg [2:0] min_shiwei,
		
		output reg [3:0] hour_gewei,
		output reg [1:0] hour_shiwei,
		
		output reg [3:0] day_gewei,
		output reg [3:0] day_shiwei,
		output reg [1:0] day_baiwei,
		
		output reg [3:0] year_gewei,
		output reg [3:0] year_shiwei
	
	
	);
	
	//////识别b码开始位置， 参数定义
	

	
	//system clock use 50mhz
	localparam TIME_2US = 100;/////误差值
	
	localparam TIME_8MS = 400_000;
	localparam TIME_5MS = 250_000;
	localparam TIME_2MS = 100_000;
	
	
	
	
	
	
	
	
	

	reg ex_device_b_code_r1 = 1'b0;
	reg ex_device_b_code_r2 = 1'b0;
	reg ex_device_b_code_r3 = 1'b0;
	
	reg ex_device_b_code_fall_edge = 1'b0;
	reg ex_device_b_code_fall_edge_r1 = 1'b0;
	reg ex_device_b_code_fall_edge_r2 = 1'b0;
	reg ex_device_b_code_fall_edge_r3 = 1'b0;
	reg ex_device_b_code_fall_edge_r4 = 1'b0;
	reg ex_device_b_code_fall_edge_r5 = 1'b0;
	reg ex_device_b_code_fall_edge_r6 = 1'b0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				ex_device_b_code_r1 <= 1'b0;
				ex_device_b_code_r2 <= 1'b0;
				ex_device_b_code_r3 <= 1'b0;
				
				ex_device_b_code_fall_edge <= 1'b0;
				ex_device_b_code_fall_edge_r1 <= 1'b0;
				ex_device_b_code_fall_edge_r2 <= 1'b0;
				ex_device_b_code_fall_edge_r3 <= 1'b0;
				ex_device_b_code_fall_edge_r4 <= 1'b0;
				ex_device_b_code_fall_edge_r5 <= 1'b0;
				ex_device_b_code_fall_edge_r6 <= 1'b0;
			end 
		else 
			begin 
				ex_device_b_code_r1 <= ex_device_b_code;
				ex_device_b_code_r2 <= ex_device_b_code_r1;
				ex_device_b_code_r3 <= ex_device_b_code_r2;
				
				ex_device_b_code_fall_edge <= (~ex_device_b_code_r2) && ex_device_b_code_r3;
				
				ex_device_b_code_fall_edge_r1 <= ex_device_b_code_fall_edge;
				ex_device_b_code_fall_edge_r2 <= ex_device_b_code_fall_edge_r1;
				ex_device_b_code_fall_edge_r3 <= ex_device_b_code_fall_edge_r2;
				ex_device_b_code_fall_edge_r4 <= ex_device_b_code_fall_edge_r3;
				ex_device_b_code_fall_edge_r5 <= ex_device_b_code_fall_edge_r4;
				ex_device_b_code_fall_edge_r6 <= ex_device_b_code_fall_edge_r5;
			end 
	end 
	
	reg [31:0] b_code_high_cycles_cnt = 32'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				b_code_high_cycles_cnt <= 32'd0;
			end 
		else if(ex_device_b_code_fall_edge_r6)
			begin 
				b_code_high_cycles_cnt <= 32'd0;
			end 
		else if(ex_device_b_code)
			begin 
				b_code_high_cycles_cnt <= b_code_high_cycles_cnt + 1'b1;
			end 
		else 
			begin 
				b_code_high_cycles_cnt <= b_code_high_cycles_cnt;
			end 
	end 
	
	
	//////////latch pre bcode high time 
	
	reg [31:0] previous_b_code_high_time_cnt = 32'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				previous_b_code_high_time_cnt <= 32'd0;
			end 
		else if(ex_device_b_code_fall_edge)
			begin 
				previous_b_code_high_time_cnt <= b_code_high_cycles_cnt;
			end 
	end 
	
	
	
	
	reg b_code_start = 1'b0;
	reg [7:0] b_code_start_fall_edge_num = 8'd0;
	
	
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				b_code_start <= 1'b0;
			end 
		else if(b_code_start_fall_edge_num >= 8'd80)
			begin 
				b_code_start <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge && (previous_b_code_high_time_cnt >= (TIME_8MS - TIME_2US)) && (previous_b_code_high_time_cnt <= (TIME_8MS + TIME_2US))
				  && (b_code_high_cycles_cnt >= (TIME_8MS - TIME_2US)) && (b_code_high_cycles_cnt <= (TIME_8MS + TIME_2US)))
			begin 
				b_code_start <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n)
			begin 
				b_code_start_fall_edge_num <= 8'd0;
			end 
		else if(~b_code_start)
			begin 
				b_code_start_fall_edge_num <= 8'd0;
			end 
		else if(b_code_start && ex_device_b_code_fall_edge)
			begin 
				b_code_start_fall_edge_num <= b_code_start_fall_edge_num + 1'b1;
			end 
	end 
	
	
	///////判决当前码元是0码 1码 P码
	
	reg [1:0] decode_0_1_p = 2'b00;  /////0:2'b00     1:2'b01     P:2'b11
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				decode_0_1_p <= 2'b00;
			end 
		else 
			begin 
				if(ex_device_b_code_fall_edge && (b_code_high_cycles_cnt >= (TIME_8MS - TIME_2US)) && (b_code_high_cycles_cnt <= (TIME_8MS + TIME_2US)))
					begin 
						decode_0_1_p <= 2'b11;/////判决为P码
					end 
				if(ex_device_b_code_fall_edge && (b_code_high_cycles_cnt >= (TIME_5MS - TIME_2US)) && (b_code_high_cycles_cnt <= (TIME_5MS + TIME_2US)))
					begin 
						decode_0_1_p <= 2'b01;/////判决为1码
					end 	
				if(ex_device_b_code_fall_edge && (b_code_high_cycles_cnt >= (TIME_2MS - TIME_2US)) && (b_code_high_cycles_cnt <= (TIME_2MS + TIME_2US)))
					begin 
						decode_0_1_p <= 2'b00;/////判决为0码
					end 	
			end 
	end 
	
	
	
	
	/////////解析结果输出//////////////////////////////////////////////////////////
	
	
///////解析秒个位 输出/////////////////////////////////////////////////////
///////解析秒个位 输出/////////////////////////////////////////////////////
///////解析秒个位 输出/////////////////////////////////////////////////////	
	
	reg [3:0] second_gewei_r = 4'd0;
		
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd1) && (decode_0_1_p == 2'b00))
			begin 
				second_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd1) && (decode_0_1_p == 2'b01))
			begin 
				second_gewei_r[0] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd2) && (decode_0_1_p == 2'b00))
			begin 
				second_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd2) && (decode_0_1_p == 2'b01))
			begin 
				second_gewei_r[1] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd3) && (decode_0_1_p == 2'b00))
			begin 
				second_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd3) && (decode_0_1_p == 2'b01))
			begin 
				second_gewei_r[2] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd4) && (decode_0_1_p == 2'b00))
			begin 
				second_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd4) && (decode_0_1_p == 2'b01))
			begin 
				second_gewei_r[3] <= 1'b1;
			end 
	end 
	
	
	///////解析秒十位 输出/////////////////////////////////////////////////////
	///////解析秒十位 输出/////////////////////////////////////////////////////	
	///////解析秒十位 输出/////////////////////////////////////////////////////	
	
	reg [2:0] second_shiwei_r = 3'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd6) && (decode_0_1_p == 2'b00))
			begin 
				second_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd6) && (decode_0_1_p == 2'b01))
			begin 
				second_shiwei_r[0] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd7) && (decode_0_1_p == 2'b00))
			begin 
				second_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd7) && (decode_0_1_p == 2'b01))
			begin 
				second_shiwei_r[1] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				second_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd8) && (decode_0_1_p == 2'b00))
			begin 
				second_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd8) && (decode_0_1_p == 2'b01))
			begin 
				second_shiwei_r[2] <= 1'b1;
			end 
	end 
	
	
	///////解析分个位 输出/////////////////////////////////////////////////////
	///////解析分个位 输出/////////////////////////////////////////////////////	
	///////解析分个位 输出/////////////////////////////////////////////////////	
	
	reg [3:0] min_gewei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd10) && (decode_0_1_p == 2'b00))
			begin 
				min_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd10) && (decode_0_1_p == 2'b01))
			begin 
				min_gewei_r[0] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd11) && (decode_0_1_p == 2'b00))
			begin 
				min_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd11) && (decode_0_1_p == 2'b01))
			begin 
				min_gewei_r[1] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd12) && (decode_0_1_p == 2'b00))
			begin 
				min_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd12) && (decode_0_1_p == 2'b01))
			begin 
				min_gewei_r[2] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd13) && (decode_0_1_p == 2'b00))
			begin 
				min_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd13) && (decode_0_1_p == 2'b01))
			begin 
				min_gewei_r[3] <= 1'b1;
			end 
	end 
	
	///////解析分十位 输出/////////////////////////////////////////////////////
	///////解析分十位 输出/////////////////////////////////////////////////////	
	///////解析分十位 输出/////////////////////////////////////////////////////	
	
	reg [2:0] min_shiwei_r = 3'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd15) && (decode_0_1_p == 2'b00))
			begin 
				min_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd15) && (decode_0_1_p == 2'b01))
			begin 
				min_shiwei_r[0] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd16) && (decode_0_1_p == 2'b00))
			begin 
				min_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd16) && (decode_0_1_p == 2'b01))
			begin 
				min_shiwei_r[1] <= 1'b1;
			end 
	end 
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				min_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd17) && (decode_0_1_p == 2'b00))
			begin 
				min_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd17) && (decode_0_1_p == 2'b01))
			begin 
				min_shiwei_r[2] <= 1'b1;
			end 
	end 
	
	
	///////解析时个位 输出/////////////////////////////////////////////////////
	///////解析时个位 输出/////////////////////////////////////////////////////	
	///////解析时个位 输出/////////////////////////////////////////////////////
	
	reg [3:0] hour_gewei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd20) && (decode_0_1_p == 2'b00))
			begin 
				hour_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd20) && (decode_0_1_p == 2'b01))
			begin 
				hour_gewei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd21) && (decode_0_1_p == 2'b00))
			begin 
				hour_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd21) && (decode_0_1_p == 2'b01))
			begin 
				hour_gewei_r[1] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd22) && (decode_0_1_p == 2'b00))
			begin 
				hour_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd22) && (decode_0_1_p == 2'b01))
			begin 
				hour_gewei_r[2] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd23) && (decode_0_1_p == 2'b00))
			begin 
				hour_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd23) && (decode_0_1_p == 2'b01))
			begin 
				hour_gewei_r[3] <= 1'b1;
			end 
	end
	
	
	///////解析时十位 输出/////////////////////////////////////////////////////
	///////解析时十位 输出/////////////////////////////////////////////////////	
	///////解析时十位 输出/////////////////////////////////////////////////////
	
	reg [1:0] hour_shiwei_r = 2'b00;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd25) && (decode_0_1_p == 2'b00))
			begin 
				hour_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd25) && (decode_0_1_p == 2'b01))
			begin 
				hour_shiwei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				hour_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd26) && (decode_0_1_p == 2'b00))
			begin 
				hour_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd26) && (decode_0_1_p == 2'b01))
			begin 
				hour_shiwei_r[1] <= 1'b1;
			end 
	end
	
	///////解析天个位 输出/////////////////////////////////////////////////////
	///////解析天个位 输出/////////////////////////////////////////////////////	
	///////解析天个位 输出/////////////////////////////////////////////////////
	
	reg [3:0] day_gewei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd30) && (decode_0_1_p == 2'b00))
			begin 
				day_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd30) && (decode_0_1_p == 2'b01))
			begin 
				day_gewei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd31) && (decode_0_1_p == 2'b00))
			begin 
				day_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd31) && (decode_0_1_p == 2'b01))
			begin 
				day_gewei_r[1] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd32) && (decode_0_1_p == 2'b00))
			begin 
				day_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd32) && (decode_0_1_p == 2'b01))
			begin 
				day_gewei_r[2] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd33) && (decode_0_1_p == 2'b00))
			begin 
				day_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd33) && (decode_0_1_p == 2'b01))
			begin 
				day_gewei_r[3] <= 1'b1;
			end 
	end
	
	///////解析天十位 输出/////////////////////////////////////////////////////
	///////解析天十位 输出/////////////////////////////////////////////////////	
	///////解析天十位 输出/////////////////////////////////////////////////////
	
	reg [3:0] day_shiwei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd35) && (decode_0_1_p == 2'b00))
			begin 
				day_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd35) && (decode_0_1_p == 2'b01))
			begin 
				day_shiwei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd36) && (decode_0_1_p == 2'b00))
			begin 
				day_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd36) && (decode_0_1_p == 2'b01))
			begin 
				day_shiwei_r[1] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd37) && (decode_0_1_p == 2'b00))
			begin 
				day_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd37) && (decode_0_1_p == 2'b01))
			begin 
				day_shiwei_r[2] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_shiwei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd38) && (decode_0_1_p == 2'b00))
			begin 
				day_shiwei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd38) && (decode_0_1_p == 2'b01))
			begin 
				day_shiwei_r[3] <= 1'b1;
			end 
	end
	
	
	///////解析天百位 输出/////////////////////////////////////////////////////
	///////解析天百位 输出/////////////////////////////////////////////////////	
	///////解析天百位 输出/////////////////////////////////////////////////////
	
	reg [1:0] day_baiwei_r = 2'b00;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_baiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd40) && (decode_0_1_p == 2'b00))
			begin 
				day_baiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd40) && (decode_0_1_p == 2'b01))
			begin 
				day_baiwei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				day_baiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd41) && (decode_0_1_p == 2'b00))
			begin 
				day_baiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd41) && (decode_0_1_p == 2'b01))
			begin 
				day_baiwei_r[1] <= 1'b1;
			end 
	end
	
	
	///////解析年个位 输出/////////////////////////////////////////////////////
	///////解析年个位 输出/////////////////////////////////////////////////////	
	///////解析年个位 输出/////////////////////////////////////////////////////
	
	reg [3:0] year_gewei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd50) && (decode_0_1_p == 2'b00))
			begin 
				year_gewei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd50) && (decode_0_1_p == 2'b01))
			begin 
				year_gewei_r[0] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd51) && (decode_0_1_p == 2'b00))
			begin 
				year_gewei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd51) && (decode_0_1_p == 2'b01))
			begin 
				year_gewei_r[1] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd52) && (decode_0_1_p == 2'b00))
			begin 
				year_gewei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd52) && (decode_0_1_p == 2'b01))
			begin 
				year_gewei_r[2] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd53) && (decode_0_1_p == 2'b00))
			begin 
				year_gewei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd53) && (decode_0_1_p == 2'b01))
			begin 
				year_gewei_r[3] <= 1'b1;
			end 
	end
	
	///////解析年十位 输出/////////////////////////////////////////////////////
	///////解析年十位 输出/////////////////////////////////////////////////////	
	///////解析年十位 输出/////////////////////////////////////////////////////
	
	reg [3:0] year_shiwei_r = 4'd0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd55) && (decode_0_1_p == 2'b00))
			begin 
				year_shiwei_r[0] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd55) && (decode_0_1_p == 2'b01))
			begin 
				year_shiwei_r[0] <= 1'b1;
			end 
	end
	
		always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd56) && (decode_0_1_p == 2'b00))
			begin 
				year_shiwei_r[1] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd56) && (decode_0_1_p == 2'b01))
			begin 
				year_shiwei_r[1] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd57) && (decode_0_1_p == 2'b00))
			begin 
				year_shiwei_r[2] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd57) && (decode_0_1_p == 2'b01))
			begin 
				year_shiwei_r[2] <= 1'b1;
			end 
	end
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin
				year_shiwei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd58) && (decode_0_1_p == 2'b00))
			begin 
				year_shiwei_r[3] <= 1'b0;
			end 
		else if(ex_device_b_code_fall_edge_r4 && (b_code_start_fall_edge_num == 8'd58) && (decode_0_1_p == 2'b01))
			begin 
				year_shiwei_r[3] <= 1'b1;
			end 
	end
	
	
	
	
	/////////////解析结束  数据输出/////////////////////////////////////
	/////////////解析结束  数据输出/////////////////////////////////////
	/////////////解析结束  数据输出/////////////////////////////////////
	
	reg  b_code_start_r1 = 1'b0;
	reg  b_code_start_r2 = 1'b0;
	reg  decode_finish = 1'b0;
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin 
				b_code_start_r1 <= 1'b0;
				b_code_start_r2 <= 1'b0;
				decode_finish <= 1'b0;
			end 
		else 
			begin 
				b_code_start_r1 <= b_code_start ;
				b_code_start_r2 <= b_code_start_r1;
				decode_finish <= (~b_code_start_r1) && b_code_start_r2;
			end 
	end 
	
	
	always @ (posedge clk_125mhz or negedge rst_n)
	begin 
		if(~rst_n) 
			begin 
			 second_gewei <= 4'd0;
			 second_shiwei <= 3'd0;
			
			 min_gewei <= 4'd0;
			 min_shiwei <= 3'd0;
			
			 hour_gewei <= 4'd0;
			 hour_shiwei <= 2'd0;
			
			 day_gewei <= 4'd0;
			 day_shiwei <= 4'd0;
			 day_baiwei <= 2'd0;
			
			 year_gewei <= 4'd0;
			 year_shiwei <= 4'd0;
			
			end 
		else if(decode_finish)
			begin 
				 second_gewei <= second_gewei_r;
				 second_shiwei <= second_shiwei_r;
				
				 min_gewei <= min_gewei_r;
				 min_shiwei <= min_shiwei_r;
				
				 hour_gewei <= hour_gewei_r;
				 hour_shiwei <= hour_shiwei_r;
				
				 day_gewei <= day_gewei_r;
				 day_shiwei <= day_shiwei_r;
				 day_baiwei <= day_baiwei_r;
				
				 year_gewei <= year_gewei_r;
				 year_shiwei <= year_shiwei_r;
	
			end 
	end 
	
	





	endmodule 


















