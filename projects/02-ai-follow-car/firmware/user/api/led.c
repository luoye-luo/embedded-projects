#include "stm32f10x.h"                  // Device header
#include "delay.h"

//LED1---pc0
//LED2---pc1
//LED3---pc2
//定义初始化函数，用于打开对应的io口，以及配置基本的io口信息
void Led_Config(void)
{
   //1.开启时钟
   RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC,ENABLE);
	
   //2.配置GPIO口信息
   GPIO_InitTypeDef  GPIO_InitStructure;
   GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;
   GPIO_InitStructure.GPIO_Pin=GPIO_Pin_0|GPIO_Pin_1|GPIO_Pin_2;
   GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;
   GPIO_Init(GPIOC,&GPIO_InitStructure);
}

//功能函数
void Led_On(void)
{
	GPIO_ResetBits(GPIOC,GPIO_Pin_0);
	GPIO_ResetBits(GPIOC,GPIO_Pin_1);
	GPIO_ResetBits(GPIOC,GPIO_Pin_2);
}

void Led_Off(void)
{
	GPIO_SetBits(GPIOC,GPIO_Pin_0);
	GPIO_SetBits(GPIOC,GPIO_Pin_1);
	GPIO_SetBits(GPIOC,GPIO_Pin_2);
}

void Led_Flow(void)
{
	static uint8_t step = 0;

	if(led_time[0] < led_time[1]) return;
	led_time[0] = 0;

	switch(step)
	{
		case 0:
			GPIO_ResetBits(GPIOC,GPIO_Pin_0);
			GPIO_SetBits(GPIOC,GPIO_Pin_1);
			GPIO_SetBits(GPIOC,GPIO_Pin_2);
			break;
		case 1:
			GPIO_ResetBits(GPIOC,GPIO_Pin_1);
			GPIO_SetBits(GPIOC,GPIO_Pin_0);
			GPIO_SetBits(GPIOC,GPIO_Pin_2);
			break;
		default:
			GPIO_ResetBits(GPIOC,GPIO_Pin_2);
			GPIO_SetBits(GPIOC,GPIO_Pin_0);
			GPIO_SetBits(GPIOC,GPIO_Pin_1);
			break;
	}

	step++;
	if(step > 2) step = 0;
}
