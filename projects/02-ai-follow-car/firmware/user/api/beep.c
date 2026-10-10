#include "stm32f10x.h"                  // Device header

//BEEP---PA15
void Beep_Config(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA,ENABLE);
	//2.配置GPIO口信息
   GPIO_InitTypeDef  GPIO_InitStructure;
   GPIO_InitStructure.GPIO_Mode=GPIO_Mode_Out_PP;
   GPIO_InitStructure.GPIO_Pin=GPIO_Pin_15;
   GPIO_InitStructure.GPIO_Speed=GPIO_Speed_50MHz;
   GPIO_Init(GPIOA,&GPIO_InitStructure);
}

//功能函数
//beep   高电平响  低电平不响
void Beep_On(void)
{
	GPIO_ResetBits(GPIOA,GPIO_Pin_15);
}


void Beep_Off(void)
{
	GPIO_SetBits(GPIOA,GPIO_Pin_15);
	
}