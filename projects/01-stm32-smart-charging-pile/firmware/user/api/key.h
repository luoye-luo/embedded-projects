#ifndef __KEY_H_
#define __KEY_H_

#include "stm32f10x.h"


#define KEY1() (GPIO_ReadInputDataBit(GPIOA,GPIO_Pin_0)==0)
#define KEY2() (GPIO_ReadInputDataBit(GPIOC,GPIO_Pin_4)==0)
#define KEY3() (GPIO_ReadInputDataBit(GPIOC,GPIO_Pin_5)==0)
#define KEY4() (GPIO_ReadInputDataBit(GPIOC,GPIO_Pin_6)==0)
void Key_Init(void);
int KEY_SCAN(void);


#endif
