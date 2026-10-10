#include "blu.h"
#include "stdio.h"
#include "string.h"
#include "beep.h"
#include "led.h"
#include "motor.h"

uint8_t blueBuff[16] = {0};
uint8_t recvCount = 0;
uint8_t recvflag = 0;
void USART2_IRQHandler(void)
{
	uint8_t data = 0;
	//判断是否是接收完成中断
	if(USART_GetITStatus(USART2, USART_IT_RXNE) == SET)
	{
		blueBuff[recvCount++] = USART2->DR;//接收数据
		recvCount %= 16;
		USART1->DR = USART2->DR;
	}
	if(USART_GetITStatus(USART2, USART_IT_IDLE) == SET)
	{
		data = USART2->DR;//接收数据
		//Blue_Analysis();
		recvflag = 1;
	}
	
}

//AA 55 指令
uint8_t BluValue = 0;
void Blue_Analysis(void)
{
	if(recvflag==1)
	{
		if(recvCount < 3)	goto ERROR;
		if(blueBuff[0] != 0xAA ||  blueBuff[1] != 0x55) goto ERROR;
	//	if(blueBuff[2]>=0 && blueBuff[2]<=9)
	//		BluValue = '0' + blueBuff[2];
		switch(blueBuff[2])
		{
			//解析数据控制设备
			case 0x01:Beep_On();break;
			case 0x02:Beep_Off();break;
			case 0x03:Motor_Front(500);break;
			case 0x04:Motor_Left(500);break;
			case 0x05:Motor_Right(500);break;
			case 0x06:Motor_Back(500);break ;
			case 0x07:Motor_Stop();break ;
			
		}
		ERROR:
		recvCount = 0;
		memset(blueBuff, 0, sizeof(blueBuff));
		recvflag = 0;
	}
}



//初始化蓝牙设备
void Blue_Config(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);
	//1、配置IO  PA2		PA3
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	//速度
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF_PP;		//复用推挽输出
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_2;					//引脚
	GPIO_Init(GPIOA, &GPIO_InitStructure);						//初始化
	
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;//浮空输入
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3;						 //引脚
	GPIO_Init(GPIOA, &GPIO_InitStructure);							 //初始化
	//2、配置USART2
	USART_InitTypeDef USART_InitStruct;
	USART_InitStruct.USART_BaudRate = 9600;							//波特率
	USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;		//发送器 接收器使能
	USART_InitStruct.USART_Parity = USART_Parity_No;		//不开奇偶校验
	USART_InitStruct.USART_StopBits = USART_StopBits_1;	//1个停止位
	USART_InitStruct.USART_WordLength = USART_WordLength_8b;//8个数据位
	USART_Init(USART2, &USART_InitStruct);
	
	//打开串口的接收中断
	USART_ITConfig(USART2, USART_IT_RXNE, ENABLE);//接收中断
	USART_ITConfig(USART2, USART_IT_IDLE, ENABLE);//空闲总线中断
	NVIC_SetPriority(USART2_IRQn, 0);//设置中断优先级
	NVIC_EnableIRQ(USART2_IRQn);//使能NVIC管理

	USART_Cmd(USART2, ENABLE);//串口使能
}







//串口1 发送单个字节数据
void Usart2_SendDate(uint8_t data)
{
	USART_SendData(USART2, data);//库函数发送数据
	//等待发送完成
	while(USART_GetFlagStatus(USART2, USART_FLAG_TXE) == RESET)
	{}
}


//串口1 发送字符串
void Usart2_SendString(char str[])
{
	uint16_t i = 0;//定义了一个下标
	while(str[i] != '\0') 
	{
		Usart2_SendDate(str[i]);
		i++;
	}
}


void Blue_SendCMD(char cmd[])
{
	Usart2_SendString(cmd);
}



void Blue_SetName(char name[])
{
	char buff[32] = {0};
	sprintf(buff,"AT+NAME%s\r\n", name);
	Usart2_SendString(buff);
}