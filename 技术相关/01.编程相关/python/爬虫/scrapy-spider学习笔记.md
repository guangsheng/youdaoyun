### 典型示例
```
# -*- coding: utf-8 -*-
import scrapy
import re
from lagou.items import LagouItem
from scrapy import selector

class LagoutestSpider(scrapy.Spider):
    name = 'lagoutest'
    allowed_domains = ['https://www.lagou.com/']
    start_urls = ['https://www.lagou.com//']

    url=start_urls[0]
    
    def start_requests(self):
        yield scrapy.Request(self.url, callback=self.home_parse, dont_filter=True)

    def home_parse(self,response):
        sel=scrapy.selector.Selector(response)
        #/html/body/div[2]/div[1]/div[1]/div[1]/div[1]
        dd=sel.xpath("//div[@class='menu_main job_hopping']")
        allurl=dd.xpath("//a/@href").extract()
        for u in allurl:
            if 'http' in u:
                yield scrapy.Request(u,callback=self.parse,dont_filter=True)

    def parse(self, response):
        sel=selector.Selector(response)
        dd=sel.xpath('//li[@class="con_list_item default_list"]')
        for d in dd:
            position=LagouItem()
            position['index']=d.xpath('@data-index').extract()
            position['salary']=d.xpath('@data-salary').extract()
            position['company']=d.xpath('@data-company').extract()
            position['position']=d.xpath('div[@class="list_item_top"]/div/div/a/span/em/text()').extract()
            position['positionname']=d.xpath('@data-positionname').extract()
            yield position
        purl=sel.xpath('//div[@class="pager_container"]/a[last()]/@href').extract()
        if 'http' in purl:
            yield scrapy.Request(purl,callback=self.parse,dont_filter=True)

```
### 基本说明
名称|属性 or 方法|含义
---|---|---
name|属性|爬虫名称
allowed_domains|属性|允许爬行的域名，如果启动了OffsiteMiddleware，非允许的域名对应的网址会被自动过滤掉，不再跟进。
start_urls|属性|爬行的起始网址，如果没有特别指定爬取得URL网址，则会从该属性中定义的网址开始爬行，在该属性中，我们可以定义多个网址，网址与网址之间用逗号隔开即可。
start_requests()|方法|默认行为：读取start_urls属性中的网址，为每一个网址生成一个Request对象，并返回可迭代对象。如果想要改变start_urls中指定的网址，可以重写该方法。
make_requests_from_url(url)|方法|默认行为：被start_requests方法调用，负责生成Requests对象。
__init__()|方法|负责爬虫的初始化，为构造函数
closed(reason)|方法|关闭Spider时调用该方法
log(message[, level, component])|方法|添加log

### 几种spider模板
```
$ scrapy genspider -l
Available templates:
  basic
  crawl
  csvfeed
  xmlfeed

```

### Spider类参数传递
原理：  
在爬虫文件中重写构造方法__init__()，在构造方法中设置一个变量用于接收用户在执行该爬虫文件时传递过来的参数。  
运行时只需要通过-a选项指定对应的参数名和参数值就可以实现参数的传递。

示例：  
```
# init方法示例
def __init__(self, myurl=None, *args, **kwargs):
    super(MySpider, self).__init__(*args, **kwargs)
    self.start_urls=["%s"%myurl]

# 调用示例
$scrapy crawl myspider -a myurl=http://www.baidu.com
```

### 需要的基础XPATH知识
- XPath是一种XML路径语言，通过该语言可以在XML文档中迅速的查找对应的信息。
- XPath的表达式通常叫做XPath selector
- 在XPath表达式中，使用"/"可以选择某个标签，并且可以使用"/"进行多层标签的查找。

#### 语法学习
http://www.w3school.com.cn/xpath/xpath_syntax.asp  
https://baike.baidu.com/item/XPath/5574064?fr=aladdin

#### 几个简单例子
- /html/body/h2  提取body下h2标签对应的内容
- /html/body/h2/text() 提取body下h2标签中的文本信息
- //p   将所有<p>标签的信息都提取出来
- //img[@class="f1"]  将所有class属性值为f1的img标签信息都提取出来
- <a title="a标头" class="pic" ...    //a[@class='pic']/@title   说明：@表示选取属性 