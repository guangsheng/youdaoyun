gdb /usr/pgsql-9.4/bin/postgres core-postgres-27723-1531912265


输入 bt 或者 where 找到错误发生的位置和相应的堆栈信息
使用 up 或者 down 查看上一条和下一条具体详细信息

GDB下用p看一个字符串的时候默认显示是截断的，可以通过 set print element 0 命令显示完整的字符串。




