### ����ʾ��
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
### ����˵��
����|���� or ����|����
---|---|---
name|����|��������
allowed_domains|����|�������е����������������OffsiteMiddleware���������������Ӧ����ַ�ᱻ�Զ����˵������ٸ�����
start_urls|����|���е���ʼ��ַ�����û���ر�ָ����ȡ��URL��ַ�����Ӹ������ж������ַ��ʼ���У��ڸ������У����ǿ��Զ�������ַ����ַ����ַ֮���ö��Ÿ������ɡ�
start_requests()|����|Ĭ����Ϊ����ȡstart_urls�����е���ַ��Ϊÿһ����ַ����һ��Request���󣬲����ؿɵ������������Ҫ�ı�start_urls��ָ������ַ��������д�÷�����
make_requests_from_url(url)|����|Ĭ����Ϊ����start_requests�������ã���������Requests����
__init__()|����|��������ĳ�ʼ����Ϊ���캯��
closed(reason)|����|�ر�Spiderʱ���ø÷���
log(message[, level, component])|����|���log

### ����spiderģ��
```
$ scrapy genspider -l
Available templates:
  basic
  crawl
  csvfeed
  xmlfeed

```

### Spider���������
ԭ��  
�������ļ�����д���췽��__init__()���ڹ��췽��������һ���������ڽ����û���ִ�и������ļ�ʱ���ݹ����Ĳ�����  
����ʱֻ��Ҫͨ��-aѡ��ָ����Ӧ�Ĳ������Ͳ���ֵ�Ϳ���ʵ�ֲ����Ĵ��ݡ�

ʾ����  
```
# init����ʾ��
def __init__(self, myurl=None, *args, **kwargs):
    super(MySpider, self).__init__(*args, **kwargs)
    self.start_urls=["%s"%myurl]

# ����ʾ��
$scrapy crawl myspider -a myurl=http://www.baidu.com
```

### ��Ҫ�Ļ���XPATH֪ʶ
- XPath��һ��XML·�����ԣ�ͨ�������Կ�����XML�ĵ���Ѹ�ٵĲ��Ҷ�Ӧ����Ϣ��
- XPath�ı��ʽͨ������XPath selector
- ��XPath���ʽ�У�ʹ��"/"����ѡ��ĳ����ǩ�����ҿ���ʹ��"/"���ж���ǩ�Ĳ��ҡ�

#### �﷨ѧϰ
http://www.w3school.com.cn/xpath/xpath_syntax.asp  
https://baike.baidu.com/item/XPath/5574064?fr=aladdin

#### ����������
- /html/body/h2  ��ȡbody��h2��ǩ��Ӧ������
- /html/body/h2/text() ��ȡbody��h2��ǩ�е��ı���Ϣ
- //p   ������<p>��ǩ����Ϣ����ȡ����
- //img[@class="f1"]  ������class����ֵΪf1��img��ǩ��Ϣ����ȡ����
- <a title="a��ͷ" class="pic" ...    //a[@class='pic']/@title   ˵����@��ʾѡȡ���� 