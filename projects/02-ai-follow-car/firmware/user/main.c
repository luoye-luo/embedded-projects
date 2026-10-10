#include "main.h"
#include "led.h"
#include "beep.h"
#include "key.h"
#include "usart1.h"
#include "lcd.h"
#include "spi.h"
#include "1.h"
#include "motor.h"
#include "tcrt5000.h"
#include "sr04.h"
#include "blu.h"
#include "wifi.h"

int main(void)
{


	JTAG_SW_Config();
	Systick_Init(72000);
    Led_Config();
	//Beep_Config();
	Key_Config();
	USART1_Config(115200);
	LCD_Init();
	MOTOR_Config();
	TCRT5000_Config();
	Sr04_Init();
	Blue_Config();
	Blue_SetName("XYD4");
	Usart3_Config();
	Steer_Init();
	
	Motor_Front(520);
	Delay_ms(2000);
	Motor_Stop();
	Delay_ms(1000);
	Motor_Back(500);
	Delay_ms(1000);
	
	LCD_Fill(0,0,128,160,WHITE);
//	LCD_ShowPicture(0,0,128,160, gImage_1);
//	LCD_ShowString(16,16,(u8*)"3123026050426",WHITE,BLACK,16,0);
//	LCD_ShowChinese(16,32,(u8*)"µç×ÓËÄ°à",RED,GREEN,16,0);
//	LCD_ShowChinese(16,48,(u8*)"USER",RED,GREEN,16,0);
	
		
//	printf("ºÓÄÏÐÅÏ¢¿Æ¼¼Ñ§Ôº\r\n");
//	printf("REDACTEDUSER\r\n");
//	printf("STUDENT_ID_REDACTED\r\n");
	Beep_Off();
	
    int key;
	int keymode=0;
	int lastkeymode = 0;
	int beepflag =0;
	int wifi =0;
	while (1)
	{ 
		//if(tcrt_time[0]>tcrt_time[1])
		//{
		//	FindLine();
		//	tcrt_time[0] = 0;
		//}	
		//if(sr04_time[0]>sr04_time[1])
		//{
		//	Obstacle_Avoidance();
		//	sr04_time[0] = 0;
			
		//}
//		if(key_time[0]>key_time[1])  
//	 {
//		key = Key_Get_Value();
//		if(key == 1)
//		{
//			Beep_On();
//		}
//		else if(key == 2)
//		{
//                                                                                    
//			Beep_Off();
//		}
//		key_time[0] = 0;
//		 
//		 
//	 }
	//æµæ°´ç¯
	//Led_Flow();
	  
    //èœ‚é¸£å™¨	  
    //Beep_On();
	//Delay_ms(500);
	//Beep_Off();
	//Delay_ms(500);
		Led_Flow();
		if(key_time[0]>key_time[1])
{
    key = Key_Get_Value();
    switch(key)
{
    case 1:
         keymode++;
     if(keymode>4)
        keymode = 1;
     break;//°´¼ü¶Ì°´
    case 2:
          beepflag = !beepflag;
     if(beepflag)Beep_On();
     else Beep_Off();
     break;//°´¼ü³¤°´
     default:break;
}
key_time[0] = 0;
}
	//ÔÚÆÁÄ»ÉÏ½øÐÐÏÔÊ¾
if(keymode != lastkeymode)
{
Motor_Stop();
switch(keymode)
{
case 1:LCD_ShowChinese(30,60,(u8*)"Ñ­¼£Ä£Ê½",WHITE,BLACK,12,0);break;
case 2:LCD_ShowChinese(30,60,(u8*)"±ÜÕÏÄ£Ê½",WHITE,BLACK,12,0);break;
case 3:LCD_ShowChinese(30,60,(u8*)"À¶ÑÀÄ£Ê½",WHITE,BLACK,12,0);break;
case 4:LCD_ShowString(30,60,(u8*)"WIFI",WHITE,BLACK,12,0);
	     LCD_ShowChinese(54,60,(u8*)"Ä£Ê½",WHITE,BLACK,12,0);break;		
default:break;
}
lastkeymode = keymode;
}
//¹¦ÄÜº¯ÊýµÄÊµÏÖ
switch(keymode)
{
case 1:
 if(tcrt_time[0]>tcrt_time[1])
 {
        FindLine();
        tcrt_time[0] = 0;
 }
break;
case 2:
    if(sr04_time[0]>sr04_time[1])
 {
     Obstacle_Avoidance();
     sr04_time[0] = 0;
 }
 break;
 break;
  case 3:
 if(blu_time[0]>blu_time[1])
 {
				Blue_Analysis();
       blu_time[0] = 0;
	     
 }
 break;
 case 4:
 if(wifi_time[0]>wifi_time[1])
 {
				WIFI_Analysis();
	     Steer_Control();
       wifi_time[0] = 0;
	     
 }
 break;
default:keymode = 1;
 break;
}
}


}

	