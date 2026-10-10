#ifndef __MAIN_H
#define __MAIN_H


#include "stm32f10x.h"
#include "delay.h"
#include "led.h"
#include "key.h"
#include "bsp_lcd.h"
#include "mfrc522.h"
#include "usart1.h"
#include "esp8266.h"

inline void JTAG_SW_Config(void)
{
	//关闭JTAG接口，开启SW接口--PA15、PB3、PB4可用
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE);
}		

#endif
