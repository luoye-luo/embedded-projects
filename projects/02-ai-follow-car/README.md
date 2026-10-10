# AI 智能识别跟随车

基于 STM32F103RCT6 和 Python 视觉程序的综合实训项目。STM32 负责底盘、传感器、LCD、无线通信和运动控制，上位机负责视频读取、人体检测、目标跟踪和控制指令生成。

## 主要功能

- STM32：GPIO、TIM/PWM、USART、SPI、LCD、循迹、超声波避障、蓝牙/Wi-Fi
- Python：OpenCV 视频流读取、YOLOv8n person 检测、Sort 目标跟踪
- 通信：Socket TCP 下发前进、后退、左转、右转、停止指令
- 视觉决策：按目标框面积和中心横坐标判断远近与左右

## 目录

- `firmware/`：STM32 工程及用户驱动代码
- `vision/`：PyCharm/Python 视觉跟随工程
## 运行

1. STM32 端使用 Keil 打开 `firmware/project/CarProject.uvprojx` 编译下载。
2. Python 端安装 `requirements` 中使用的 OpenCV、Ultralytics、FilterPy、cvzone 等依赖。
3. 根据实际网络修改 `vision/ai_test.py` 中的摄像头地址和 Socket 地址。
4. 运行 `python ai_test.py`。
