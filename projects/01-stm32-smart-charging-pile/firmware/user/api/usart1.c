#include "usart1.h"

void Usart1_Config(void)
{
	//1.开时钟gpioa和USART1
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA|RCC_APB2Periph_USART1,ENABLE);
	//2.GPIO初始化
	GPIO_InitTypeDef USART1_GPIO = {0};//创建结构体变量
	USART1_GPIO.GPIO_Mode = GPIO_Mode_AF_PP;//复用推挽输出
	USART1_GPIO.GPIO_Pin = GPIO_Pin_9;//PA9
	USART1_GPIO.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA,&USART1_GPIO);
	USART1_GPIO.GPIO_Mode = GPIO_Mode_IN_FLOATING;//浮空输入
	USART1_GPIO.GPIO_Pin = GPIO_Pin_10;//PA9
	GPIO_Init(GPIOA,&USART1_GPIO);
	//串口初始化
	USART_InitTypeDef USART1_Type = {0};//创建串口初始化结构体变量
	USART1_Type.USART_BaudRate = 115200;//波特率-9600
	USART1_Type.USART_HardwareFlowControl = USART_HardwareFlowControl_None;//硬件流失能
	USART1_Type.USART_Mode = USART_Mode_Tx|USART_Mode_Rx;//发送接收使能
	USART1_Type.USART_Parity = USART_Parity_No;//不开启奇偶校验
	USART1_Type.USART_StopBits = USART_StopBits_1;//1位停止位
	USART1_Type.USART_WordLength = USART_WordLength_8b;//8位数据位
//初始化串口
	USART_Init(USART1,&USART1_Type);
	//使能串口
	USART_Cmd(USART1,ENABLE);
	//中断配置
	USART_ITConfig(USART1,USART_IT_RXNE,ENABLE);//数据接收中断--收到数据就会进中断
	USART_ITConfig(USART1,USART_IT_IDLE,ENABLE);//数据接收中断--收到数据就会进中断
	//配置中断结构体变量
	NVIC_InitTypeDef NVIC_InitStruct = {0};
	NVIC_InitStruct.NVIC_IRQChannel = USART1_IRQn;
	NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority = 1;
	NVIC_InitStruct.NVIC_IRQChannelSubPriority = 1;
	NVIC_InitStruct.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStruct);
}

/******
printf函数重定向
********/
int fputc(int ch,FILE *fp)
{
	//等待串口上次数据发送完成
	while(USART_GetFlagStatus(USART1,USART_FLAG_TC) == RESET);
	//发送新的数据
	USART_SendData(USART1,ch);
	return ch;
}

uint8_t USART_RECVDATA(void)
{
	while(USART_GetFlagStatus(USART1, USART_FLAG_RXNE)==0){}		
		//读取接收数据
	uint8_t RxData = 0;
  RxData = USART_ReceiveData(USART1);
	return RxData;
}

void USART1_IRQHandler(void)
{
	uint8_t data = 0;
	//判断中断是否为接收完成中断
	if(USART_GetITStatus(USART1,USART_IT_RXNE) == SET)
	{
		//接收数据
		data = USART_ReceiveData(USART1);
		//使用电脑上的串口助手通过单片机的串口1下发数据控制蜂鸣器的开关
		//清除接收中断
		USART_ClearITPendingBit(USART1,USART_IT_RXNE);
	}
	if(USART_GetITStatus(USART1,USART_IT_IDLE) == SET)
	{
		//清除空闲中断
		data = USART1 ->SR;
		data = USART1 ->DR;
	}
}

