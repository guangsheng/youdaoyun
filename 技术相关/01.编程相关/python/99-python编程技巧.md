1. print不换行
```
from __future__ import print_function
print('123123', end='')
```
2.  推导列表
如下两段代码等效  
```
    #方式一
	new_filelist=[]
	for each_t in filelist:
	    new_filelist.append(sanitize(each_t))
    #方式二
	new_filelist = [sanitize(each_t) for each_t in filelist]
```
3. 类属性：把方法看成属性，调用时也类似于使用属性，例如  
```
# 定义  
@property
def top3(self)
    ....
# 调用
     xxx.top3
```