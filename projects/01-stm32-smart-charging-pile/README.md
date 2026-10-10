# STM32 智能充电桩

基于 STM32F103RCT6 的智能充电桩课程项目，包含 RFID 读卡、LCD 状态显示、电机/继电器控制、ESP8266 Wi-Fi 通信和微信小程序端状态查询。

## 主要功能

- MFRC522 RFID 卡片识别与用户卡处理
- TTL LCD 状态及余额显示
- ESP8266 连接巴法云，实现云端数据上传与订阅
- 微信小程序查询设备在线状态、余额和充电枪连接状态

## 目录

- `firmware/`：Keil 工程、STM32 标准外设库及用户模块
- `firmware/project/Charging_Pile.uvprojx`：Keil 工程入口

## 构建

1. 使用 Keil uVision5 打开 `firmware/project/Charging_Pile.uvprojx`。
2. 在 `firmware/user/api/esp8266.h` 中填写 Wi-Fi SSID、密码和巴法云 UID。
3. 编译并下载到 STM32F103RCT6。

公开仓库中的 Wi-Fi 和云端密钥均使用占位符，不会连接到原有个人网络或云账号。
