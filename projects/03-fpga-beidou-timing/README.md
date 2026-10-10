# FPGA 北斗卫星信号授时系统

基于 Altera Cyclone IV EP4CE6E22C8 的 Verilog HDL 课程设计，接收 GNSS 模块输出的 NMEA-0183 数据，完成 GNRMC 协议解析、UTC+8 换算和数码管动态显示。

## 主要功能

- 50 MHz 系统时钟与 9600 bit/s UART 接收
- GNRMC 帧头识别、字段计数、时间提取和异或校验
- UTC 到北京时间换算及跨天修正
- 74HC595 串并转换与 6 位共阳极数码管动态扫描
- ModelSim Testbench 和 Quartus II 工程文件

## 目录

- `rtl/`：北斗授时系统完整 RTL 与 Quartus II 工程
- `basics/`：UART、状态机、D 触发器、流水灯、加减乘运算等 FPGA 基础练习
## 开发环境

- Quartus II 13.0
- ModelSim 2020.4
- Altera Cyclone IV EP4CE6E22C8
