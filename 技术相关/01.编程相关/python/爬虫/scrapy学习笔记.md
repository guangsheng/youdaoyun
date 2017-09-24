### 简单使用
#### 创建项目
```
scrapy startproject pjoname

cd pjoname
scrapy generate example example.com
```
#### 检查项目
```scrapy list```
#### 执行抓取
```scrapy crawl pjoname```

#### 生成出的文件介绍
##### items.py
- 定义要保存的爬取到的信息，相当于存储爬取到的数据的容器。
- 结构化的
- 实例化出的类对象实际上是一个字典，key是定义的字段名字，value是爬取到的值

##### pipelines.py
- 接收从蜘蛛组件中提取出的项目item，并做处理。
- 可以对items里定义的数据进行进一步加工处理，也就是每获取到一条数据都会调用一次该文件中定义的指定函数
- 常见的处理主要有：清洗、验证、存储等

##### spiders/example.py
- 爬虫文件
- 可以从模板生成，是爬虫类（Spider）的子类。
- 爬取逻辑、数据提取逻辑等均在这个文件定义
- 主要负责Scrapy引擎中response响应，接收了response响应后，会对这些response响应进行分析处理，然后提取出对应的关注的数据，也可以提取出接下来需要处理的新网址等信息。

##### settings.py

#### 其他说明
- startproject 命令可以指定日志文件、日志级别等

### scrapy命令介绍
```
# 显示爬取过程、运行爬虫文件、查看scrapy配置信息、提供交互终端、性能测试、创建爬虫文件、启动爬虫、合法性检查等
[shiguangsheng@workstation lagou]$ scrapy -h
Scrapy 1.4.0 - project: lagou

Usage:
  scrapy <command> [options] [args]

Available commands:
  bench         Run quick benchmark test
  check         Check spider contracts
  crawl         Run a spider
  edit          Edit spider
  fetch         Fetch a URL using the Scrapy downloader
  genspider     Generate new spider using pre-defined templates
  list          List available spiders
  parse         Parse URL (using its spider) and print the results
  runspider     Run a self-contained spider (without creating a project)
  settings      Get settings values
  shell         Interactive scraping console
  startproject  Create new project
  version       Print Scrapy version
  view          Open URL in browser, as seen by Scrapy

Use "scrapy <command> -h" to see more info about a command

```