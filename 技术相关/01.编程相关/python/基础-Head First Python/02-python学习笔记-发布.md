#### ����python�ṩ��setup����

- Ϊģ�鴴��һ���ļ��У������ļ��ŵ�����ļ���
- �����ļ����д���һ�� setup.py ���ļ�������ļ��е���setup����

```
bogon:nester $ cat setup.py
#coding=utf-8

from distutils.core import setup

setup(
	name = 'nester',
	version = '1.1.0',
	py_modules = ['nester'],
	author = 'hfpython',
	author_email = 'xxx@foxmail.com',
	url = 'http://www.headfirstlabs.com',
	description = 'A simple printer of nested lists',
	)
```

- ����һ�������ļ�

```
#����һ�������ļ�
python setup.py sdist
#��������װ��python����������
sudo python setup.py install
```

- ������Ŀ¼�ṹ

```
bogon:nester shiguangsheng$ ls -R
MANIFEST	build		dist		nester.py	setup.py

./build:
lib

./build/lib:
nester.py

./dist:
nester-1.0.0.tar.gz   --����Ƿ�����
```

- ʹ��

```
import nester

nester.fun_name
```