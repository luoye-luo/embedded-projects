#include "tcrt5000.h"
#include "stdio.h"
#include "delay.h"
#include "motor.h"

void TCRT5000_Config(void)
{
	GPIO_InitTypeDef GPIO_InitStructure = {0};
	RCC_APB2PeriphClockCmd(TCRT1_CLK | TCRT2_CLK | TCRT3_CLK | TCRT4_CLK | TCRT5_CLK, ENABLE);
	
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStructure.GPIO_Pin = TCRT1_PIN;
	GPIO_Init(TCRT1_PORT, &GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin = TCRT2_PIN;
	GPIO_Init(TCRT2_PORT, &GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin = TCRT3_PIN;
	GPIO_Init(TCRT3_PORT, &GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin = TCRT4_PIN;
	GPIO_Init(TCRT4_PORT, &GPIO_InitStructure);
	
	GPIO_InitStructure.GPIO_Pin = TCRT5_PIN;
	GPIO_Init(TCRT5_PORT, &GPIO_InitStructure);
}


//巡线函数
void FindLine(void)
{
	uint8_t tcrtValue = TCRT5000_GetValue();
	//if(tcrtValue == 0x03 || tcrtValue == 0x01 || tcrtValue == 0x18 || tcrtValue == 0x10) {
	//	CarMoveTime = 600;//直角弯的转弯时长
	//}
	//else CarMoveTime = 1;
	
	switch(tcrtValue)
	{
		case 0x1F://全白
		case 0x00://全黑  停止 
			Motor_RightFrontControl(0);
			Motor_RightBackControl(0);
			Motor_LeftFrontControl(0);
			Motor_LeftBackControl(0);
			car.dir = CAR_DIR_STOP; 
		break;
		//左转直角弯
		case 0x03:
		case 0x01:
			Motor_RightFrontControl(550);
			Motor_RightBackControl(550);
			Motor_LeftFrontControl(-300);
			Motor_LeftBackControl(-300);
			car.dir = CAR_DIR_LEFT;
		break;
		//左转大弯
		case 0x0F://01111
		case 0x07://00111
			Motor_RightFrontControl(500);
			Motor_RightBackControl(500);
			Motor_LeftFrontControl(-250);
			Motor_LeftBackControl(-250);
			car.dir = CAR_DIR_LEFT;
		break;
		//左转小弯
		case 0x17://10111		
		case 0x13://10011		
			Motor_RightFrontControl(400);
			Motor_RightBackControl(400);
			Motor_LeftFrontControl(-80);
			Motor_LeftBackControl(-80);		
			car.dir = CAR_DIR_LEFT;
		break;
		
		//右转直角弯
		case 0x18:	//11000
		case 0x10:	//10000
			Motor_RightFrontControl(-300);
			Motor_RightBackControl(-300);
			Motor_LeftFrontControl(550);
			Motor_LeftBackControl(550);
			car.dir = CAR_DIR_RIGHT;
		break;
		//右转大弯
		case 0x1E://11110		
		case 0x1C://11100
			Motor_RightFrontControl(-250);
			Motor_RightBackControl(-250);
			Motor_LeftFrontControl(500);
			Motor_LeftBackControl(500);
			car.dir = CAR_DIR_RIGHT;
		break;
		//右转小湾
		case 0x1D://11101		次小的弯
		case 0x19://11001		最小的弯
			Motor_RightFrontControl(-80);
			Motor_RightBackControl(-80);
			Motor_LeftFrontControl(400);
			Motor_LeftBackControl(400);
			car.dir = CAR_DIR_RIGHT;
		break;
		default: //直行
			Motor_RightFrontControl(500);
			Motor_RightBackControl(500);
			Motor_LeftFrontControl(500);
			Motor_LeftBackControl(500);
			car.dir = CAR_DIR_FRONT;
		break;
	}

}





