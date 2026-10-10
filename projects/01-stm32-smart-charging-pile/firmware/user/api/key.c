#include "stm32f10x.h"                  // Device header
#include "key.h"


void Key_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA|RCC_APB2Periph_GPIOC,ENABLE);
	
	GPIO_InitTypeDef KEY_GPIO;
	KEY_GPIO.GPIO_Mode=GPIO_Mode_IPD;//下拉
	KEY_GPIO.GPIO_Pin=GPIO_Pin_0;
	KEY_GPIO.GPIO_Speed=GPIO_Speed_50MHz;
	GPIO_Init(GPIOA,&KEY_GPIO);
	
	KEY_GPIO.GPIO_Mode=GPIO_Mode_IPU;//上拉
	KEY_GPIO.GPIO_Pin=GPIO_Pin_4|GPIO_Pin_5|GPIO_Pin_6;
	KEY_GPIO.GPIO_Speed=GPIO_Speed_50MHz;
	GPIO_Init(GPIOC,&KEY_GPIO);
}
int KEY_SCAN(void)
{
	static int kcount[4]={0};
	if(KEY1() == 1)
	{
		kcount[0]++;
	}
	else
	{
		if(kcount[0]>50)
		{
			kcount[0]=0;
			return 11;
		}
		else if(kcount[0]>15)
		{
			kcount[0]=0;
			return 1;
		}
		else
			kcount[0]=0;
	}
	
	if(KEY2()==1)
	{
		kcount[1]++;
	}
	else
	{
		if(kcount[1]>50)
		{
			kcount[1]=0;
			return 22;
		}
		else if(kcount[1]>15)
		{
			kcount[1]=0;
			return 2;
		}
		else
			kcount[1]=0;
	}

	if(KEY3()==1)
	{
		kcount[2]++;
	}
	else
	{
		if(kcount[2]>50)
		{
			kcount[2]=0;
			return 33;
		}
		else if(kcount[2]>15)
		{
			kcount[2]=0;
			return 3;
		}
		else
			kcount[2]=0;
	}
	if(KEY4()==1)
	{
		kcount[3]++;
	}
	else
	{
		if(kcount[3]>50)
		{
			kcount[3]=0;
			return 44;
		}
		else if(kcount[3]>15)
		{
			kcount[3]=0;
			return 4;
		}
		else
			kcount[3]=0;
	}
	return 0;
}
