`timescale  1ns/1ns


module  uart_rx
#(
    parameter   UART_BPS    =   'd9600,         //串口波特率
    parameter   CLK_FREQ    =   'd50_000_000    //时钟频率
)
(
    input   wire            sys_clk     ,   //系统时钟50MHz
    input   wire            sys_rst_n   ,   //全局复位
    input   wire            rx          ,   //串口接收数据

    output  reg     [7:0]   po_data     ,   //串转并后的8bit数据
    output  reg             po_flag         //串转并后的数据有效标志信号
);



	parameter BIT_CLOCK_CYCLES = CLK_FREQ / UART_BPS;
	parameter HALF_BIT_CLOCK_CYCLES = CLK_FREQ / UART_BPS / 2;
	
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
	
	reg [7:0] state;
		
	reg 	rx_r1 = 1'b0;
	reg 	rx_r2 = 1'b0;
	reg 	rx_r3 = 1'b0;
	reg 	rx_rise_edge = 1'b0;
	
	
	
	
	always @ (posedge sys_clk or negedge sys_rst_n)
	begin  
			if(~sys_rst_n)
				begin 
					rx_r1 <= 1'b0;
					rx_r2 <= 1'b0;
					rx_r3 <= 1'b0;
					rx_rise_edge <= 1'b0;
				end 
			else 
				begin 
					rx_r1 <= rx;
					rx_r2 <= rx_r1;
					rx_r3 <= rx_r2;
					rx_rise_edge <= (~rx_r2) && rx_r3;
				end 
	end 

	reg [7:0] temp_receive_data = 8'd0;
	
	reg [31:0] delay_cnt = 32'd0;

	always @ (posedge sys_clk or negedge sys_rst_n)
	begin  
		if(~sys_rst_n)
			begin 
				state <= IDLE;
				temp_receive_data <= 8'd0;
				delay_cnt <= 32'd0;
				po_data <= 8'd0;
				po_flag <= 1'b0;
			end 
		else 
			begin 
				case(state )
					IDLE:
						begin 
							delay_cnt <= 32'd0;
									po_data <= 8'd0;
										po_flag <= 1'b0;
						
						
							if(rx_rise_edge)
								begin 
									state <= S0;
									
								end 
							else 
								begin 
									state <= state;
								end 
						end 
					
					S0:
						begin 
							if(delay_cnt == (BIT_CLOCK_CYCLES + HALF_BIT_CLOCK_CYCLES))
								begin 
									delay_cnt <= 32'd0;
									state <= S1;
									temp_receive_data[0] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 
						
					S1:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S2;
									temp_receive_data[1] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 	
						
					S2:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S3;
									temp_receive_data[2] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S3:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S4;
									temp_receive_data[3] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S4:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S5;
									temp_receive_data[4] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S5:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S6;
									temp_receive_data[5] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S6:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S7;
									temp_receive_data[6] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S7:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									delay_cnt <= 32'd0;
									state <= S8;
									temp_receive_data[7] <= rx;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S8:
						begin 
							if(delay_cnt == BIT_CLOCK_CYCLES )
								begin 
									state <= S9;
								end 
							else 
								begin 
									delay_cnt <= delay_cnt + 1'b1;
								end 
						end 		
						
					S9:
						begin 
							po_data <= temp_receive_data;
							po_flag <= 1'b1;
							state <= IDLE;
						end 
						
					default :
						begin 
							state <= IDLE;
							delay_cnt <= 0;
						
						end 
			
			
			
			
				endcase 
			end 
	end 

























endmodule
