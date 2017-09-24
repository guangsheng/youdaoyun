### 获取拉勾网数据 https://git.oschina.net/nanxun/lagou.git
#### items.py
```
# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy import Field

class LagouItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    index=Field()
    salary=Field()
    company=Field()
    positionname=Field()
    position=Field()
```

#### pipelines.py
```
# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html
from lagou.items import LagouItem
from scrapy import log
class LagouPipeline(object):
    def process_item(self, item, spider):
        w=open('position.txt','a')
        w.write(str(dict(item))+"\n")
        w.close()
        log.msg("position added to file!!!",level=log.DEBUG,spider=spider)
        return item
```

#### spiders/lagou1.py
```
# -*- coding: utf-8 -*-
import scrapy
import re
from lagou.items import LagouItem
from scrapy import selector

class Lagou1Spider(scrapy.Spider):
    name = "lagou1"
    allowed_domains = ["www.lagou.com"]
    start_urls = ['http://www.lagou.com/']
    url=start_urls[0]
    def start_requests(self):
        yield scrapy.Request(self.url,callback=self.home_parse,dont_filter=True)

    def home_parse(self,response):
        sel=scrapy.selector.Selector(response)
        #/html/body/div[2]/div[1]/div[1]/div[1]/div[1]
        dd=sel.xpath("//div[@class='menu_main job_hopping']")
        allurl=dd.xpath("//a/@href").extract()
        for u in allurl:
            if 'http' in u:
                yield scrapy.Request(u,callback=self.parse,dont_filter=True)

    def parse(self,response):
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

#### settings.py
```
# -*- coding: utf-8 -*-

# Scrapy settings for lagou project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#     http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#     http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html

BOT_NAME = 'lagou'

SPIDER_MODULES = ['lagou.spiders']
NEWSPIDER_MODULE = 'lagou.spiders'


# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'lagou (+http://www.yourdomain.com)'

# Obey robots.txt rules
ROBOTSTXT_OBEY = True

# Configure maximum concurrent requests performed by Scrapy (default: 16)
#CONCURRENT_REQUESTS = 32

# Configure a delay for requests for the same website (default: 0)
# See http://scrapy.readthedocs.org/en/latest/topics/settings.html#download-delay
# See also autothrottle settings and docs
DOWNLOAD_DELAY = 0.5
# The download delay setting will honor only one of:
#CONCURRENT_REQUESTS_PER_DOMAIN = 16
#CONCURRENT_REQUESTS_PER_IP = 16

# Disable cookies (enabled by default)
#COOKIES_ENABLED = False

# Disable Telnet Console (enabled by default)
#TELNETCONSOLE_ENABLED = False

# Override the default request headers:
DEFAULT_REQUEST_HEADERS = {
    'Accept':'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Encoding':'gzip, deflate, sdch, br',
    'Accept-Language':'zh-CN,zh;q=0.8',
    'User-Agent':'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36',
}

# Enable or disable spider middlewares
# See http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html
#SPIDER_MIDDLEWARES = {
#    'lagou.middlewares.LagouSpiderMiddleware': 543,
#}

# Enable or disable downloader middlewares
# See http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#DOWNLOADER_MIDDLEWARES = {
#    'lagou.middlewares.MyCustomDownloaderMiddleware': 543,
#}

# Enable or disable extensions
# See http://scrapy.readthedocs.org/en/latest/topics/extensions.html
#EXTENSIONS = {
#    'scrapy.extensions.telnet.TelnetConsole': None,
#}

# Configure item pipelines
# See http://scrapy.readthedocs.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    'lagou.pipelines.LagouPipeline': 300,
}

# Enable and configure the AutoThrottle extension (disabled by default)
# See http://doc.scrapy.org/en/latest/topics/autothrottle.html
#AUTOTHROTTLE_ENABLED = True
# The initial download delay
#AUTOTHROTTLE_START_DELAY = 5
# The maximum download delay to be set in case of high latencies
#AUTOTHROTTLE_MAX_DELAY = 60
# The average number of requests Scrapy should be sending in parallel to
# each remote server
#AUTOTHROTTLE_TARGET_CONCURRENCY = 1.0
# Enable showing throttling stats for every response received:
#AUTOTHROTTLE_DEBUG = False

# Enable and configure HTTP caching (disabled by default)
# See http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html#httpcache-middleware-settings
#HTTPCACHE_ENABLED = True
#HTTPCACHE_EXPIRATION_SECS = 0
#HTTPCACHE_DIR = 'httpcache'
#HTTPCACHE_IGNORE_HTTP_CODES = []
#HTTPCACHE_STORAGE = 'scrapy.extensions.httpcache.FilesystemCacheStorage'

```

### 下载剑来小说
#### items.py
```
# -*- coding: utf-8 -*-

import scrapy

class JianlaiItem(scrapy.Item):
    # define the fields for your item here like:
    title = scrapy.Field()
    content = scrapy.Field()
    nextlink = scrapy.Field()

```
#### pipelines.py
```
# -*- coding: utf-8 -*-

from jianlai.items import JianlaiItem

class JianlaiPipeline(object):
    def process_item(self, item, spider):        
        title = item["title"][0].strip()
        content = item["content"]
        link = item["nextlink"]
        filename="output/"+title+".txt"
        try:
            file=open(filename,'a')
            for i in range(len(content)):
                file.write(content[i]+"\n")
            file.write(str(link))
        except Exception as e:
            print("Title is "+title+", error is "+str(e))
        finally:
            file.close() 
        
        return item

```
#### spiders/jianlai_biqugexsw.py
```
# -*- coding: utf-8 -*-
import scrapy
from jianlai.items import JianlaiItem
from scrapy.http import Request

class JianlaiBiqugexswSpider(scrapy.Spider):
    name = 'jianlai_biqugexsw'
    start_urls = ['http://www.jianlaixiaoshuo.com/book/17.html']

    def parse(self, response):
        item=JianlaiItem()
        item["title"]=response.xpath("//div[@class='inner']/h1/text()").extract()
        item["content"]=response.xpath("//div[@id='BookText']").xpath("//p/text()").extract()
        item["nextlink"]=response.xpath("//div[@class='link']/a[@rel='next']/@href").extract()
        url="http://www.jianlaixiaoshuo.com"+item["nextlink"][0].strip()
        yield item
        if 'html' in url:
            yield Request(url, callback=self.parse)

```
#### settings.py
```
# -*- coding: utf-8 -*-

# Scrapy settings for jianlai project
#
# For simplicity, this file contains only settings considered important or
# commonly used. You can find more settings consulting the documentation:
#
#     http://doc.scrapy.org/en/latest/topics/settings.html
#     http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#     http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html

BOT_NAME = 'jianlai'

SPIDER_MODULES = ['jianlai.spiders']
NEWSPIDER_MODULE = 'jianlai.spiders'


# Crawl responsibly by identifying yourself (and your website) on the user-agent
#USER_AGENT = 'jianlai (+http://www.yourdomain.com)'

# Obey robots.txt rules
ROBOTSTXT_OBEY = True

# Configure maximum concurrent requests performed by Scrapy (default: 16)
#CONCURRENT_REQUESTS = 32

# Configure a delay for requests for the same website (default: 0)
# See http://scrapy.readthedocs.org/en/latest/topics/settings.html#download-delay
# See also autothrottle settings and docs
DOWNLOAD_DELAY = 0.1
# The download delay setting will honor only one of:
#CONCURRENT_REQUESTS_PER_DOMAIN = 16
#CONCURRENT_REQUESTS_PER_IP = 16

# Disable cookies (enabled by default)
#COOKIES_ENABLED = False

# Disable Telnet Console (enabled by default)
#TELNETCONSOLE_ENABLED = False

# Override the default request headers:
#DEFAULT_REQUEST_HEADERS = {
#   'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
#   'Accept-Language': 'en',
#}

# Enable or disable spider middlewares
# See http://scrapy.readthedocs.org/en/latest/topics/spider-middleware.html
#SPIDER_MIDDLEWARES = {
#    'jianlai.middlewares.JianlaiSpiderMiddleware': 543,
#}

# Enable or disable downloader middlewares
# See http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html
#DOWNLOADER_MIDDLEWARES = {
#    'jianlai.middlewares.MyCustomDownloaderMiddleware': 543,
#}

# Enable or disable extensions
# See http://scrapy.readthedocs.org/en/latest/topics/extensions.html
#EXTENSIONS = {
#    'scrapy.extensions.telnet.TelnetConsole': None,
#}

# Configure item pipelines
# See http://scrapy.readthedocs.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    'jianlai.pipelines.JianlaiPipeline': 300,
}

# Enable and configure the AutoThrottle extension (disabled by default)
# See http://doc.scrapy.org/en/latest/topics/autothrottle.html
#AUTOTHROTTLE_ENABLED = True
# The initial download delay
#AUTOTHROTTLE_START_DELAY = 5
# The maximum download delay to be set in case of high latencies
#AUTOTHROTTLE_MAX_DELAY = 60
# The average number of requests Scrapy should be sending in parallel to
# each remote server
#AUTOTHROTTLE_TARGET_CONCURRENCY = 1.0
# Enable showing throttling stats for every response received:
#AUTOTHROTTLE_DEBUG = False

# Enable and configure HTTP caching (disabled by default)
# See http://scrapy.readthedocs.org/en/latest/topics/downloader-middleware.html#httpcache-middleware-settings
#HTTPCACHE_ENABLED = True
#HTTPCACHE_EXPIRATION_SECS = 0
#HTTPCACHE_DIR = 'httpcache'
#HTTPCACHE_IGNORE_HTTP_CODES = []
#HTTPCACHE_STORAGE = 'scrapy.extensions.httpcache.FilesystemCacheStorage'

```