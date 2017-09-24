- 数组使用
```
data[data == u'好'] = 1
data[data != 1] = -1
```
- print不换行
```
from __future__ import print_function
print('123123', end='')
```

-  推导列表
```
# 如下两段代码等效
# 1）
  	new_filelist=[]
	for each_t in filelist:
	    new_filelist.append(sanitize(each_t))
# 2）
	new_filelist = [sanitize(each_t) for each_t in filelist]
```
- 类属性：把方法看成属性，调用时也类似于使用属性，例如
```
#定义
@property
def top3(self)
    ....

调用
     xxx.top3
```

- ```__main()函数```: 包含这个函数的模块在命令行运行时才会调用这个函数
- atexit.register：脚本退出之前调用这个函数
```python
from atexit import register
@register
def _atexit():
    #do something
```
