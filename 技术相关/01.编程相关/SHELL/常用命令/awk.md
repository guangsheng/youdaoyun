#### 内置变量
+ ARGC: 命令行参数个数
+ ARGV: 命令行参数排列
+ ENVIRON: 支持队列中系统环境变量的使用
+ FILENAMEawk: 浏览的文件名
+ FNR: 浏览文件的记录数
+ FS: 设置输入域分隔符，等价于命令行-F选项
+ NF: 浏览记录的域个数
+ NR: 已读的记录数
+ OFS: 输出域分隔符
+ ORS: 输出记录分隔符
+ RS: 控制记录分隔符

#### 实例1-下载指定网页的所有img选项
```
for info in $(curl -k -s http://www.eztang.cn/shejituandui/120.html \
             |grep img |grep uploads \
             |awk -F"src=" '{print $2}' |awk -F "\"|'" '{print $2}' 
    );
do
    filename=$(echo -n ${info} |awk -F/ '{print $NF}')
    curl -k -s http://www.eztang.cn${info} > $filename
done
```