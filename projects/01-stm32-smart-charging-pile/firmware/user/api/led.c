#include "led.h"
#include "stm32f10x.h"

void Led_Init(void)
{
	//开启时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOE,ENABLE);
	//gpio初始化
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;//通用推挽
	GPIO_InitStructure.GPIO_Pin=GPIO_Pin_2|GPIO_Pin_3|GPIO_Pin_4|GPIO_Pin_5;
	GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;
	GPIO_Init(GPIOE,&GPIO_InitStructure);
	
	//关灯
	GPIO_SetBits(GPIOE,GPIO_Pin_2|GPIO_Pin_3|GPIO_Pin_4|GPIO_Pin_5);
}
void Led_Run(void)
{
	static int lcount =0;
    switch(lcount)
	{
		case 0:LED1(1);LED4(0);break;
		case 1:LED2(1);LED1(0);break;
		case 2:LED3(1);LED2(0);break;
		case 3:LED4(1);LED3(0);break;
	}
	lcount++;
	lcount%=4;
}
	