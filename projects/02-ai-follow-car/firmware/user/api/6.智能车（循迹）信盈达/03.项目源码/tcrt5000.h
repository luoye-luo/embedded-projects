#ifndef __TCRT5000_H
#define __TCRT5000_H

#include "stm32f10x.h"

#define TCRT1_CLK		RCC_APB2Periph_GPIOC
#define TCRT1_PORT	GPIOC
#define TCRT1_PIN		GPIO_Pin_7

#define TCRT2_CLK		RCC_APB2Periph_GPIOC
#define TCRT2_PORT	GPIOC
#define TCRT2_PIN		GPIO_Pin_8

#define TCRT3_CLK		RCC_APB2Periph_GPIOC
#define TCRT3_PORT	GPIOC
#define TCRT3_PIN		GPIO_Pin_9

#define TCRT4_CLK		RCC_APB2Periph_GPIOC
#define TCRT4_PORT	GPIOC
#define TCRT4_PIN		GPIO_Pin_10

#define TCRT5_CLK		RCC_APB2Periph_GPIOC
#define TCRT5_PORT	GPIOC
#define TCRT5_PIN		GPIO_Pin_11


//被黑色遮挡 数据为0		无遮挡 数据为1
#define TCRT_OUT1() (GPIO_ReadInputDataBit(TCRT1_PORT, TCRT1_PIN))//最左侧
#define TCRT_OUT2() (GPIO_ReadInputDataBit(TCRT2_PORT, TCRT2_PIN))
#define TCRT_OUT3() (GPIO_ReadInputDataBit(TCRT3_PORT, TCRT3_PIN))
#define TCRT_OUT4() (GPIO_ReadInputDataBit(TCRT4_PORT, TCRT4_PIN))
#define TCRT_OUT5() (GPIO_ReadInputDataBit(TCRT5_PORT, TCRT5_PIN))//最右侧

//低位在右，高位在左
#define TCRT5000_GetValue()	((TCRT_OUT1()<<4)|(TCRT_OUT2()<<3)|(TCRT_OUT3()<<2)|(TCRT_OUT4()<<1)|(TCRT_OUT5()))

void TCRT5000_Config(void);
void FindLine(void);

#endif
