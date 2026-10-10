#ifndef _MAIN_H_
#define _MAIN_H_

#include "stm32f10x.h"
#include "delay.h"


//厂家测试接口
void JTAG_SW_Config(void)
{
	//关闭JTAG接口，开启SW接口--PA15、PB3、PB4可用
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
	GPIO_PinRemapConfig(GPIO_Remap_SWJ_JTAGDisable, ENABLE);
}

#endif
