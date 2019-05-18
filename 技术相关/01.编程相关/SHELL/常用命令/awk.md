awk可以认为是一门语言，非常强大。  
awk工作流程是这样的：先执行BEGIN，然后读取文件，读入换行符分割的一条记录，然后将记录按指定的域分隔符划分域，填充域，随后开始执行模式所对应的动作action。接着开始读入第二条记录······直到所有的记录都读完，最后执行END操作。

#### 三种调用方式
awk '{pattern + action}' {filenames}

+ 命令行方式:
```awk [-F  field-separator]  'commands'  input-file(s)```
    其中，commands 是真正awk命令，[-F域分隔符]是可选的。 input-file(s) 是待处理的文件。  
    在awk中，文件的每一行中，由域分隔符分开的每一项称为一个域。通常，在不指名-F域分隔符的情况下，默认的域分隔符是空格。

+ shell脚本方式  
    将所有的awk命令插入一个文件，并使awk程序可执行，然后awk命令解释器作为脚本的首行，一遍通过键入脚本名称来调用。  
    相当于shell脚本首行的：```#!/bin/sh``` 可以换成：```#!/bin/awk```

+ 将所有的awk命令插入一个单独文件，然后调用：```awk -f awk-script-file input-file(s)```; 其中，-f选项加载awk-script-file中的awk脚本，input-file(s)跟上面的是一样的。

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
+ $0变量是指整条记录

#### 流程控制
+ awk中的条件语句是从C语言中借鉴来的
+ 循环语句同样借鉴于C语言，支持while、do/while、for、break、continue，这些关键字的语义和C语言中的语义完全相同。

#### 其他
+ print函数的参数可以是变量、数值或者字符串。字符串必须用双引号引用，参数用逗号分隔。如果没有逗号，参数就串联在一起而无法区分。这里，逗号的作用与输出文件的分隔符的作用是一样的，只是后者是空格而已。  
```print "filename:" FILENAME ",linenumber:" NR ",columns:" NF ",linecontent:"$0```
+ printf函数，其用法和c语言中printf基本相似,可以格式化字符串,输出复杂时，printf更加好用，代码更易懂。
```printf("filename:%10s,linenumber:%s,columns:%s,linecontent:%s\n",FILENAME,NR,NF,$0)```


#### 实例
##### 1-BEGIN和END的使用
```cat /etc/passwd |awk  -F ':'  'BEGIN {print "name,shell"}  {print $1","$7} END {print "blue,/bin/nosh"}'```

##### 2-pattern使用模式-搜索/etc/passwd有root关键字的所有行
```awk -F: '/root/' /etc/passwd```

+ 这种是pattern的使用示例，匹配了pattern(这里是root)的行才会执行action(没有指定action，默认输出每行的内容)。pattern是支持正则的。

##### 3-显示文件file的当前记录号、域数和每一行的第一个和最后一个域。
```awk '{print NR,NF,$1,$NF,}' file```

##### 4-显示第4个域满足条件的行
```df | awk '$4>1000000 '```

##### 5-显示文件中第一个域匹配101的行
```awk '$1 ~ /101/ {print $1}' file```

##### -下载指定网页的所有img选项
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

##### 5.计算
```
cat redis_redis8389.dump.rdb.201712261040.csv.log |grep COPY |grep -v CONTEXT |awk -F' ' '{ sum += $2 } END { print sum }'
ls s07_s06_s05_s04_s03_s02_* |xargs cat > err.log
awk -F',' '{if(NF>=4)sum += $(NF-3)} END { print sum }' err.log

cat xxx.log |head |awk -F" " '{print $8}' |awk -F',' 'BEGIN{
RS="\n+"
}
{
sum+=$0
}
NR==1 {
max=$1;min=$1
next
}
$1>max {
max=$1
}
$1<min {
min=$1
}
END{
printf "max number is:%s\n",max
printf "min number is:%s\n",min
printf "sum number is:%s\n",sum
printf "average is:%.2f\n",sum/NR
}'
```

#### 6.打印自定义内容
cat 1.log |awk -F' ' '{print NR" "$1 $2" nan nan"}'

#### 单引号
awk '{print "'\''"}' 

#### 分类统计
```
$ cat datafile
姓名   类型 金额
张三    1   27.43
李四    2   33.44
张三    2   55.55
丁六    1   66.66
赵七    1  77.77
$ cat datafile |awk -F' ' '{types[$2]+=$3;count[$2]++}END{for(i in types) printf"类型%s 共%d行 合计 %f\n",i,count[i],types[i]}'
类型类型 共1行 合计 0.000000
类型1 共3行 合计 171.860000
类型2 共2行 合计 88.990000
```