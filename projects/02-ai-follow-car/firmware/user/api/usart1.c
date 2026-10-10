#include "usart1.h"

//brr -- 波特率
void USART1_Config(u32 brr)
{
	GPIO_InitTypeDef GPIO_InitStruct={0};
	//1.打开端口时钟A
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA,ENABLE);
	//2.配置PA10
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN_FLOATING;//浮空输入
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_10;//10管脚
	
	GPIO_Init(GPIOA,&GPIO_InitStruct);
	//3.配置PA9
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF_PP;//复用推挽输出
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_9;//10管脚
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA,&GPIO_InitStruct);
	
	//USART1 1+8+0+1 9600
	USART_InitTypeDef USART_InitSturct = {0};
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1,ENABLE);
	
	USART_InitSturct.USART_BaudRate = brr;//波特率
	USART_InitSturct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;//硬件流
	USART_InitSturct.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;//全双工
	USART_InitSturct.USART_Parity = USART_Parity_No;//不使用奇偶校验位
	USART_InitSturct.USART_StopBits = USART_StopBits_1;//停止位为1
	USART_InitSturct.USART_WordLength = USART_WordLength_8b;//数据位为8
	
	USART_Init(USART1,&USART_InitSturct);
	
		
	USART_ITConfig(USART1,USART_IT_RXNE,ENABLE);	//串口接收中断
	USART_ITConfig(USART1,USART_IT_IDLE,ENABLE);	//串口空闲中断
	
	NVIC_InitTypeDef NVIC_InitStructure = {0};
	NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;	//中断向量
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	//数字越小，优先级越高
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;	//抢占优先级
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;	//相应优先级
	NVIC_Init(&NVIC_InitStructure);
	

	USART_Cmd(USART1,ENABLE);
}


int fputc(int ch,FILE *fp)
{
	//等待串口上次数据发送完成
	while(USART_GetFlagStatus(USART1,USART_FLAG_TC) == RESET);
	//发送新的数据
	USART_SendData(USART1,ch);
	
	return ch;
}

struct RECV_INFO{
	uint8_t buff[128];
	uint32_t cnt;
	uint8_t flag;
};
struct RECV_INFO usart1_data = {0};

void USART1_IRQHandler(void)
{
	static uint8_t data = 0;
	if(USART_GetITStatus(USART1,USART_IT_RXNE) == SET)
	{
		//接收中断 --- 证明有数据需要接收
		USART_ClearITPendingBit(USART1,USART_IT_RXNE);
		data = USART1->DR;
		usart1_data.buff[usart1_data.cnt++] = data;

	}
	else if(USART_GetITStatus(USART1,USART_IT_IDLE) == SET)
	{
		//空闲中断 --- 数据接收完成
		//空闲中断的清除方法比较特殊 --- 需要去读数据寄存器
		data = USART1->DR;
		data = USART1->DR;
		usart1_data.flag = 1;	//表示接收完成
	}
	
}


