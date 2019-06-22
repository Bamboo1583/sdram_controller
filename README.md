# sdram_controller
使用verilog编写sdram控制器

# 文件构成
doc:里面有关于SDRAM的设计资料，包括sdram操作原则，sdram控制器设计报告以及终极内存技术指南，其中sdram控制器设计报告.docx中有sdram控制器的系统框架，模块设计，状态图的设计以及相应模块的仿真验证。
img:里面有sdram控制器各个模块的仿真验证
sim：仿真需要使用的所有文件，包括testbeach，run.do，mt48lc32m16a2.其中mt48lc32m16a2是sdram仿真模型.
src:里面有sdram控制器的所有源文件。

# 使用指南
1.打开doc文件中的sdram控制器设计报告，了解系统整体框架，设计思路，模块设计以及相应的仿真验证。
2.打开modelsim软件，切换到sim/run.do文件的目录下，运行do run.do脚本文件进行仿真。
3.在modelsim软件的Transcript中查看读写流程，读写数据；在modelsim软件的wave中查看仿真波形，其中可以通过cmd_monitor查看相应的命令。

NOTE:
1.在doc/终极内存技术指南.pdf可以让你了解到sdram的结构，工作流程以及设计思路。
2.在doc/sdram操作原则.txt可以让你了解到sdram的操作原则，分别是优先权原则，bank独立原则，总线兼容原则