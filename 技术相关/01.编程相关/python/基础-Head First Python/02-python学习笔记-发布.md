#### 利用python提供的setup函数

- 为模块创建一个文件夹，并把文件放到这个文件夹
- 在新文件夹中创建一个 setup.py 的文件，这个文件中调用setup函数

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

- 构建一个发布文件

```
#构建一个发布文件
python setup.py sdist
#将发布安装到python发布副本中
sudo python setup.py install
```

- 发布后目录结构

```
bogon:nester shiguangsheng$ ls -R
MANIFEST	build		dist		nester.py	setup.py

./build:
lib

./build/lib:
nester.py

./dist:
nester-1.0.0.tar.gz   --这个是发布包
```

- 使用

```
import nester

nester.fun_name
```