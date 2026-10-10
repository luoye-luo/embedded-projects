#include "delay.h"
extern uint32_t led_runtime;
extern uint32_t key_runtime; 
extern uint32_t Bemfa_runtime;
extern uint32_t LCD_runtime=0;
extern uint32_t Charge_runtime=0;



//系统滴答定时器的中断函数
//1ms触发一次
void SysTick_Handler(void)
{
    led_runtime++;
	key_runtime++;
	Bemfa_runtime++;
	LCD_runtime++;
	Charge_runtime++;
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
//1s = 1000ms  1ms=1000us
void Delay_ms(uint32_t time)
{
	uint64_t t = time*1000;
	while(t--) {
		delay_1us();
	}
}






