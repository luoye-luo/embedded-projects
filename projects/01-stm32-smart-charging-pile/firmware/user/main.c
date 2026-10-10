#include "main.h"
#include "stm32f10x.h"                  // Device header
#include "led.h"
#include "key.h"
#include "bsp_lcd.h"

//变量定义
uint8_t mode = 0;//1查询，2充值，3充电
uint8_t confirm = 0;//确定变量标志位
char buff[128] = {0};//屏幕显示
//	屏幕刷新函数
#include "string.h"
void ui_show(void)
{
		memset(buff,0,sizeof(buff));
		sprintf(buff,"卡内余额:%4d",money);
		LCD_ShowStringAndHz(100,64,240,16,16,(u8 *)buff,0);
		memset(buff,0,sizeof(buff));
		sprintf(buff,"充值金额:%4d",addmoney);
		LCD_ShowStringAndHz(100,80,240,16,16,(u8 *)buff,0);
		memset(buff,0,sizeof(buff));
		sprintf(buff,"充电金额:%4d",addtime);
		LCD_ShowStringAndHz(100,96,240,16,16,(u8 *)buff,0);
}
//RFID操作函数
void Charge_update(void)
{
		if(confirm == 1)
		{
			if(mode == 1)
			{
				MFRC522_check_IC();//查询
			}
			else if(mode == 2)
			{
				MFRC522_Add_IC();//充值
			}
			else if(mode == 3)
			{
				MFRC522_reduce_IC();//充电
			}
			confirm = 0;
		}
		if(mode == 3)
		{
			charge();
		}
		else
		{
			LCD_ShowStringAndHz(56,180,200,16,16,(u8 *)"                 ",0);
		}	
}
//按键切换函数
void Key_Change(void)
{
		switch(KEY_SCAN())
		{
			case 1:mode++;
						if(mode > 3)
						{
							mode = 1;
						}
						printf("mode :%d\r\n",mode);
						switch(mode)
						{
							case 1:LCD_ShowStringAndHz(88,32,64,16,16,(u8 *)"查询模式",0);break;
							case 2:LCD_ShowStringAndHz(88,32,64,16,16,(u8 *)"充值模式",0);break;
							case 3:LCD_ShowStringAndHz(88,32,64,16,16,(u8 *)"充电模式",0);break;
						}
				break;
			case 2:
						if(mode == 2)
						{
							addmoney += 10;
						}
						else if(mode == 3)
						{
							if(addtime > money)
							{
								addtime = 0;
							}
							else
							{
							addtime += 10;
							}
						}
				break;
			case 3:
						if(mode == 2)
						{
							if(addmoney <= 0)
							{
								addmoney = 0;
							}
							else
							addmoney -= 10;

						}
						else if(mode == 3)
						{
							if(addtime <= 0)
							{
								addtime = 0;
							}
							else
							addtime -= 10;
						}
				
				break;
			case 4:confirm = 1;printf("conform :%d\r\n",confirm);break;
		}
}

extern const unsigned char gImage_img[153600];
extern uint32_t  led_runtime = 0;
extern uint32_t  key_runtime = 0;
uint32_t  Bemfa_runtime = 0;

int main(void)
{
	JTAG_SW_Config();
	Systick_Init(72000);//ms
	Led_Init();//灯初始化
	Key_Init();//按键初始化
	TFTLCD_Init();//屏幕初始化
	Usart1_Config();//串口初始化
	PCD_Init();//RFID初始化
	
	LCD_Fill(0,0,240,320,BLUE);
	LCD_ShowPicture(0,0,240,320,(u8 *)gImage_img);
	LCD_ShowStringAndHz(0,0,240,16,16,(u8 *)"STUDENT_ID_REDACTED",0);
	LCD_ShowStringAndHz(0,16,240,16,16,(u8 *)"智能充电桩卡内余额值查询模式金剩时间",0);
	WIFI_Init();//连接wifi
	Subscribe_Bemfa("charge");//订阅主题
	while(1)
	{
	
      if(led_runtime >=500)
	  {
		  led_runtime=0;
		  Led_Run();
	  }
	  if(key_runtime>=10)
	  {
		  key_runtime=0;
		  Key_Change();
	  }
	  if(LCD_runtime>=500)
	  {
		  LCD_runtime=0;
		  ui_show();
	  }
	  if(Charge_runtime>=1000)
	  {
		  Charge_runtime=0;
		  Charge_update();
	  }
	  
    }
}
