#### Python的包搜索路径
Python会在以下路径中搜索它想要寻找的模块：
1. 程序所在的文件夹
2. 标准库的安装路径
3. 操作系统环境变量PYTHONPATH所包含的路径

#### 将自定义库的路径添加到Python的库路径中去，有如下两种方法：
1. 动态的添加库路径。在程序运行过程中修改sys.path的值，添加自己的库路径

```
import sys
sys.path.append(r'your_path') 
```

2. 在Python安装目录下的\Lib\site-packages文件夹中建立一个.pth文件，内容为自己写的库路径。示例如下  
E:\\work\\Python\\http  
E:\\work\\Python\\logging

#### python引入导入自定义模块和外部文件
你的其他文件不是单个文件，或者不能如上所说放到同一目录下，而是在不同目录中
```
folder
------tobeinvodedA.py
------tobeinvodedB.py
------tobeinvodedC.py
toinvoke.py
```
这种情况，现在folder 下新建一个__init__.py 的空文件，此时的folder不再是一个普通的文件夹，而是一个包 package,现在像这样
folder #文件夹 现在的性质为一个python包package 
```
------__init__.py
------tobeinvoded.py
------tobeinvodedA.py
------tobeinvodedB.py
------tobeinvodedC.py
toinvoke.py
```

这样在toinvoke.py 中引入
import folder.toveinvoked 或 from folder.tobeinvoked import *
即可

Python使用class创建类，每个定义的类都有一个特殊的方法，名为 __init__() ,可以通过这个方法初始化对象
```
class Athlete:
	def __init__(self, value):
		self.thing = value

	def how_big(self):
		return (len(self.thing))
```
创建对象实例
```
a = Athlete('abc')  # Athlete().__init__(a, 'abc')
b = Athlete('hijklmn')  # Athlete().__init__(b, 'hijklmn')
```
每个方法的第一个参数都是self

如果你把ExampleClass类保存到了一个example.py的文件中，可以用下面这行代码把这个类导入你的代码中
```from expamle import ExampleClass```

继承
```
# 从list继承
>>> class NamedList(list):
...     def __init__(self, a_name):
...         list.__init__([])
...         self.name = a_name
...
>>> johnny = NamedList("John Paul Jones")
>>> type(johnny)
<class '__main__.NamedList'>
>>> dir(johnny)
['__add__', '__class__', '__contains__', '__delattr__', '__delitem__', '__delslice__', '__dict__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__getslice__', '__gt__', '__hash__', '__iadd__', '__imul__', '__init__', '__iter__', '__le__', '__len__', '__lt__', '__module__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__reversed__', '__rmul__', '__setattr__', '__setitem__', '__setslice__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'append', 'count', 'extend', 'index', 'insert', 'name', 'pop', 'remove', 'reverse', 'sort']
>>> johnny.append("Bass Player")
>>> johnny.extend(["Composer","Arranger"])
>>> johnny
['Bass Player', 'Composer', 'Arranger']
>>> johnny.name
'John Paul Jones'
>>> for attr in johnny:
...     print(johnny.name + " is a " + attr +".")
...
John Paul Jones is a Bass Player.
John Paul Jones is a Composer.
John Paul Jones is a Arranger.
>>>
```