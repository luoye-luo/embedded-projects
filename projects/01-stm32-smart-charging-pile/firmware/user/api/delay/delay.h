#ifndef __DELAY_H
#define __DELAY_H

#include "stm32f10x.h"

//nop指令会让芯片暂停一个时钟周期
//一个时钟周期多久？
//时钟频率72mhz  
#define delay_1us()	{\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();__NOP();\
__NOP();__NOP();\
}
extern uint32_t led_runtime;
extern uint32_t key_runtime;
extern uint32_t Bemfa_runtime;
extern uint32_t LCD_runtime;
extern uint32_t Charge_runtime;

void Systick_Init(uint32_t load);
void Delay_us(uint32_t time);
void Delay_ms(uint32_t time);
#endif
