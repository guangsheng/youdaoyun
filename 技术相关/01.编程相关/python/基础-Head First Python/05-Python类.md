#### Python�İ�����·��
Python��������·������������ҪѰ�ҵ�ģ�飺
1. �������ڵ��ļ���
2. ��׼��İ�װ·��
3. ����ϵͳ��������PYTHONPATH��������·��

#### ���Զ�����·����ӵ�Python�Ŀ�·����ȥ�����������ַ�����
1. ��̬����ӿ�·�����ڳ������й������޸�sys.path��ֵ������Լ��Ŀ�·��

```
import sys
sys.path.append(r'your_path') 
```

2. ��Python��װĿ¼�µ�\Lib\site-packages�ļ����н���һ��.pth�ļ�������Ϊ�Լ�д�Ŀ�·����ʾ������  
E:\\work\\Python\\http  
E:\\work\\Python\\logging

#### python���뵼���Զ���ģ����ⲿ�ļ�
��������ļ����ǵ����ļ������߲���������˵�ŵ�ͬһĿ¼�£������ڲ�ͬĿ¼��
```
folder
------tobeinvodedA.py
------tobeinvodedB.py
------tobeinvodedC.py
toinvoke.py
```
�������������folder ���½�һ��__init__.py �Ŀ��ļ�����ʱ��folder������һ����ͨ���ļ��У�����һ���� package,����������
folder #�ļ��� ���ڵ�����Ϊһ��python��package 
```
------__init__.py
------tobeinvoded.py
------tobeinvodedA.py
------tobeinvodedB.py
------tobeinvodedC.py
toinvoke.py
```

������toinvoke.py ������
import folder.toveinvoked �� from folder.tobeinvoked import *
����

Pythonʹ��class�����࣬ÿ��������඼��һ������ķ�������Ϊ __init__() ,����ͨ�����������ʼ������
```
class Athlete:
	def __init__(self, value):
		self.thing = value

	def how_big(self):
		return (len(self.thing))
```
��������ʵ��
```
a = Athlete('abc')  # Athlete().__init__(a, 'abc')
b = Athlete('hijklmn')  # Athlete().__init__(b, 'hijklmn')
```
ÿ�������ĵ�һ����������self

������ExampleClass�ౣ�浽��һ��example.py���ļ��У��������������д��������ർ����Ĵ�����
```from expamle import ExampleClass```

�̳�
```
# ��list�̳�
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