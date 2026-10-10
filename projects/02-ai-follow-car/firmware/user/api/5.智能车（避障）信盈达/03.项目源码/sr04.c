#include "sr04.h"
#include "delay.h"
#include "motor.h"
#include "stdio.h"
#include "lcd.h"
//超声波初始化函数
void Sr04_Init(void)
{
	Sr04_Config();
	Tim2Sr04_Config();
}

//初始化SR04的IO口，以及对应的外部中断的配置
void Sr04_Config(void)
{
	GPIO_InitTypeDef GPIO_InitStructure;
	EXTI_InitTypeDef EXTI_InitStructure;
	NVIC_InitTypeDef NVIC_InitStructure;
	
	//配置GPIO口
	  
	//TRIG---PB14---推挽输出
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Pin = SR04_TRIG_PIN;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(SR04_TRIG_PORT,&GPIO_InitStructure);
	
	//ECHO---PC6---浮空输入
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	GPIO_InitStructure.GPIO_Pin = SR04_ECHO_PIN;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(SR04_ECHO_PORT,&GPIO_InitStructure);
	
	//                GPIOB         GPIO_Pin_14
	GPIO_ResetBits(SR04_TRIG_PORT,SR04_TRIG_PIN);//trig设置为低电平，防止上电误触发送超声波
	
	//配置中断
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO,ENABLE);
	GPIO_EXTILineConfig(SR04_ECHO_PinSourcePort,SR04_ECHO_PinSource);
	
	EXTI_InitStructure.EXTI_Line = SR04_ECHO_EXTI_Line;
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Rising_Falling;
	EXTI_InitStructure.EXTI_LineCmd  = ENABLE;
	EXTI_Init(&EXTI_InitStructure);
	
	NVIC_InitStructure.NVIC_IRQChannel = SR04_ECHO_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x0F;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x0F;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&NVIC_InitStructure);
}

__SR04_TypeDef sr04 = {0};

//周期发送  10us 调用一次
//发送10us高59990us低   周期60000us  60ms
void Sr04_SendTTL(void) 
{
	sr04.sendCount++; //123   0->1  10us                GPIOB           GPIO_Pin_14
	if(sr04.sendCount == 1 && GPIO_ReadOutputDataBit(SR04_TRIG_PORT, SR04_TRIG_PIN) == Bit_RESET) {
		GPIO_SetBits(SR04_TRIG_PORT, SR04_TRIG_PIN);//拉高为高电平_触发信号开始
	}
	//                 10us       30us   TRIG低电平
	else if(sr04.sendCount == 3 && GPIO_ReadOutputDataBit(SR04_TRIG_PORT, SR04_TRIG_PIN) == Bit_SET) {
		GPIO_ResetBits(SR04_TRIG_PORT, SR04_TRIG_PIN);//触发信号结束
	}
	else if(sr04.sendCount > 6000){
		sr04.sendCount = 0;
		GPIO_ResetBits(SR04_TRIG_PORT, SR04_TRIG_PIN);
	}
}

//IO的EXTI中断服务函数
//只要检测到边沿就会触发
void SR04_ECHO_IRQHandler(void)
{
  if(EXTI_GetITStatus(SR04_ECHO_EXTI_Line) != RESET)
  {
    if(GPIO_ReadInputDataBit(SR04_ECHO_PORT, SR04_ECHO_PIN) == Bit_SET) {
			//改变开始开始计数标志  置1
			sr04.recvCount = 0;
			sr04.recvCountFlag = 1;
		}
		else {
			//计数完成
			sr04.recvCountFlag = 0;
		}
    EXTI_ClearITPendingBit(SR04_ECHO_EXTI_Line);
  }
}


//增加计数
//10us调用一次，用来计数
void Sr04_CountInc(void)
{
	if(sr04.recvCountFlag == 1)//高电平期间计数
		sr04.recvCount++;
}

//获取SR04数据,获取频率越快，计算越快
float Sr04_GetLength(void)
{
	if(sr04.recvCountFlag == 0)
		sr04.leng = sr04.recvCount*34/200.0;//距离单位：cm/10us
	if(sr04.leng > 400)	sr04.leng = 380;
	return sr04.leng;
}

//10us一次的定时器中断
void TIM2_IRQHandler(void)
{
	if(TIM_GetITStatus(TIM2, TIM_IT_Update) == SET) {
		Sr04_SendTTL();//发送脉冲波  10us发送一次
		Sr04_CountInc();//计数
		TIM_ClearFlag(TIM2, TIM_IT_Update);
	}
}

//定时器2的初始化，实现了10us进入一次中断
void Tim2Sr04_Config(void)
{
	NVIC_InitTypeDef   NVIC_InitStructure;
	//10us一次的中断   定时器2初始化
	TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;
  RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);
  TIM_TimeBaseStructure.TIM_Prescaler = 36-1;
  TIM_TimeBaseStructure.TIM_CounterMode = TIM_CounterMode_Up;
  TIM_TimeBaseStructure.TIM_Period = 20-1;//20-1;
  TIM_TimeBaseStructure.TIM_ClockDivision = 0;
  TIM_TimeBaseInit(TIM2, &TIM_TimeBaseStructure);
	
	TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);
	
  NVIC_InitStructure.NVIC_IRQChannel = TIM2_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x01;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x00;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);
	TIM_Cmd(TIM2, ENABLE);
	
	TIM_CtrlPWMOutputs(TIM2, DISABLE);
}


/***********************************
  * @brief  避障函数
  * @param  None
  * @retval None
  ***********************************/
void Obstacle_Avoidance(void)
{
	char buf[30] = "\0";
	float length = 0;
	length = Sr04_GetLength();
	printf("length = %.2f\r\n",length);
	sprintf(buf,"length = %6.2f",length);
	LCD_ShowString(0,10,(u8*)buf,BLACK,PINK,16,0);
	if(length > 40)
		Motor_Front(500);
	else
		Motor_Right(500);
}

