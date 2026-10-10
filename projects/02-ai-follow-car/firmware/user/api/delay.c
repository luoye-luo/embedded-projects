#include "delay.h"
uint32_t key_time[2] = {0,10};
uint32_t led_time[2] = {0,500};
uint32_t tcrt_time[2] = {0,20};
uint32_t sr04_time[2] = {0,20};
uint32_t blu_time[2] = {0,30};
uint32_t wifi_time[2] = {0,30};
//系统滴答定时器的中断函数
//1ms
void SysTick_Handler(void)
{
	key_time[0]++;
	led_time[0]++;
	tcrt_time[0]++;
	sr04_time[0]++;
	blu_time[0]++;
	wifi_time[0]++;

}




//系统定时器初始化
void Systick_Init(uint32_t load)
{
	if(SysTick_Config(load) == 1)
	{
		while(1);
	}
}


void Delay_us(uint32_t time)
{
	while(time--) {
		delay_1us();
	}
}

void Delay_ms(uint32_t time)
{
	uint64_t t = time*1000;
	while(t--) {
		delay_1us();
	}
}






