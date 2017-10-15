##### 数组使用
```
data[data == u'好'] = 1
data[data != 1] = -1
```
##### print不换行
```
from __future__ import print_function
print('123123', end='')
```
##### 推导列表
```
# 如下两段代码等效
# 1）
  	new_filelist=[]
	for each_t in filelist:
	    new_filelist.append(sanitize(each_t))
# 2）
	new_filelist = [sanitize(each_t) for each_t in filelist]
```
##### 类属性：把方法看成属性，调用时也类似于使用属性
```
#定义
@property
def top3(self)
    ....

调用
     xxx.top3
```

##### ```__main()函数```: 包含这个函数的模块在命令行运行时才会调用这个函数

##### atexit.register：脚本退出之前调用这个函数
```python
from atexit import register
@register
def _atexit():
    #do something
```

##### 输入输出控制解决输入提示中文乱码问题
```raw_input(unicode('请输入文字','utf-8').encode('gbk'))```

##### 进度条控制
```
from __future__ import division
import sys,time
j = '#'
for i in range(1,61):
    j += '#'
    sys.stdout.write(str(int((i/60)*100))+'% ||'+j+'->'+"\n")
    sys.stdout.flush()
    time.sleep(0.5)
```

##### 获取当前时间
```
c=time.ctime()
#自定义格式输出
ISOTIMEFORMAT=’%Y-%m-%d %X’
time.strftime( ISOTIMEFORMAT, time.localtime() )
```

##### 查看系统环境变量
```os.environ["PATH"]```

##### 获取当前路径(包括当前py文件名)
```os.path.realpath(__file__)```

##### 当前平台使用的行终止符
```	os.linesep```

##### 字符串倒置
```
a = "codementor"
a[::-1]
```

##### 字符串首字母变大写
```
info = 'ssfef'
print info.capitalize()
print info.title()
```

##### 列表(list)列表去重
```
ids = [1,4,3,3,4,2,3,4,5,6,1]
ids = list(set(ids))
```

##### 将嵌套列表转换成单一列表
```
a = [[1, 2], [3, 4], [5, 6]]
>>> import itertools
>>> list(itertools.chain.from_iterable(a))
[1, 2, 3, 4, 5, 6]
```

##### 产生a-z的字符串列表
```map(chr,range(97,123))```

##### reduce函数函数本次执行的结果传递给下一次
```
>>> def test(a,b):
...     return a+b
...
>>> reduce(test,range(10))
45
>>>
```