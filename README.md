# 嵌入式项目合集

这是电子信息工程本科阶段完成的嵌入式、单片机、FPGA 与机器视觉项目整理仓库。

## 项目列表

| 项目 | 主要内容 | 技术栈 |
| --- | --- | --- |
| STM32 智能充电桩 | RFID 刷卡、LCD 显示、ESP8266 联网、巴法云通信、微信小程序 | STM32F103RCT6、C、SPI、UART、MFRC522、ESP8266 |
| AI 智能识别跟随车 | 人体检测、目标跟踪、Socket 指令控制、循迹与避障 | STM32F103RCT6、Python、OpenCV、YOLOv8n、Sort |
| FPGA 北斗授时系统 | NMEA-0183 接收、GNRMC 解析、UTC+8 换算、74HC595 动态显示 | Verilog HDL、Quartus II、ModelSim、Cyclone IV |

## 仓库结构

```text
projects/
  01-stm32-smart-charging-pile/
  02-ai-follow-car/
  03-fpga-beidou-timing/
```

各项目目录下均包含独立 README，说明硬件平台、模块功能、目录结构及构建/运行方式。

## 说明

- 仓库排除了编译器输出、临时文件、安装包及与本项目无关的第三方软件。
- 仓库不上传课程报告、证件照或项目图片，仅保留可复现实验所需的源码和工程配置。
- Wi-Fi 账号、密码和云平台 UID 已替换为占位符，实际运行前需在对应配置文件中填写。
