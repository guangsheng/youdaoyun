### 基础
  1. python的变量标识符没有类型，只是一个名字，但标识符指向的对象有类型。
  2. Python属于“敏感型”，区分大小写
  3. 键入 dir(__builtins__) 可以看到 Python 提供的内置方法类别，键入 help(input) 就会得到对应函数的功能描述
  4. 集合：无序，且不允许重复。可以用set函数创建一个集合。
  5. 字典：也就是映射，允许数据与键关联
  6. Python允许在函数中访问和读取一个全局变量，但不允许修改，如果要修改，必须用global关键字说明下这个变量
 
### 其他
  ● Python内置的测试框架 unitest和doctest
  ● Python的一些高级特性：匿名函数、生成器、元类、定义异常、正则表达式
  ● 关于线程：Python使用一种称为全局解释器锁（Global Interpreter Lock，GIL）的技术来实现，他强制实现这样一个限制，要求Python只能在一个解释器进程中运行，因此即使使用了线程，也不会变快。


#### 内存组织相关
  1. python的列表在内存中是用一个类似数组的结构来存储的，数据项从下向上堆放
  2. line_spoken = line_spoken.strip()      在line_spoken上调用strip方法会会创建一个新的字符串，新的字符串去除了前后的空白符。这个新字符串再复制给line_spoken。Python内置的内存管理技术会回收所使用的RAM，也就是说，除非还有另外某个Python数据对象也指向那个旧的字符串，否则python会将它回收。即Python变量只包含数据对象的一个引用。


#### 列表
  ● 列表常用方法：len, append, pop, extend, remove, insert 

#### 语法：与C不同的，比C更方便的
  1.  for 目标标识符 in 列表
  2. 

#### Python术语
  1. BIF: 内置函数


#### 常用技巧
  1.  包含 end='' 作为print() 的一个参数会关闭其默认行为（及在输入中自动包含换行）
  2. range() 可以与for结合使用，从而固定迭代次数