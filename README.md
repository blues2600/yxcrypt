# asm

#### 介绍


- 这是一个简单的文件加密程序，可以对文件加密和解密
- 程序使用 C 和 x86 MASM32 汇编语言混合的方式编写
- C代码主要用来接收命令行参数，并调用相关汇编过程
- 汇编代码实现程序的功能，其中，加密使用ROR指令移位来实现，文件操作使用win32 api
- 代码中调用了很多Irvine32汇编过程用来方便输出，下载相关库文件请访问 http://www.asmirvine.com/
- 从main.c开始阅读




#### 使用说明


- 命令 : 程序名称  加密选项  文件名   
- 加密： test   e   notepad.exe
- 解密： test   d   notepad.exe


#### 编译和链接


1. 我用的visual studio 2019 
1. 首先，汇编asmMain.asm，但不进行链接，生成asmMain.obj
1. 将asmMain.obj添加到C++项目
1. 构建并运行项目
1. 如果修改了asmMain.asm，则运行前，需要再一次汇编



