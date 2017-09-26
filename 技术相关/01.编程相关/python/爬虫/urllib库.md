#### python2和python3的区别
**python2是两个库，urllib和urllib2，python3中将urllib2合并到了urllib**

python2|python3
-------|-------
import urllib2|import urllib.request, urllib.error
import urllib|import urllib.request, urllib.error, urllib.pares
import urlparese|import urllib.pares
urllib2.urlopen|urllib.request.urlopen
urllib.urlencode|urllib.pares.urlencode
urllib.quote|urllib.request.quote
cookielib.CookieJar|http.CookieJar
urllib2.Request|urllib.request.Request

#### 常见错误码
错误码|含义
--|--
200|OK,一切正常
301|Moved Permanently，重定向到新的URL，永久性
302|Found，重定向到临时的URL，非永久性
304|Not Modified，请求的资源未更新
400|Bad Request，非法请求
401|Unauthorized，请求未授权
403|Forbidden，禁止访问
404|Not Found，没有找到对应页面
500|Internal Server Error，服务器内部出现错误
501|Not Implemented，服务器不支持实现请求所需要的功能

#### 代码
```
sdir = "D:/temp/Python3/myweb"
```
#### GET方法获取网页
```Python
surl = "http://www.baidu.com/s?wd="
key="数据挖掘"
# 解决中文编码问题
key_code=urllib2.quote(key)
surl_all=surl+key_code;
try:
    data=urllib2.urlopen(surl_all).read()
except urllib2.URLError as e:
    if hasattr(e,"code"):
        print e.code
    if hasattr(e,"reason"):
        print e.reason
fh=open(sdir+"/4.html","wb")
fh.write(data)
fh.close()
```

#### POST方法获取网页
```Python
surl = "http://yum.iqianyue.com/mypost/"
postdata = urllib.urlencode({
"name":"ceo@iqianyue.com",
"pass":"aA123456"
}).encode('utf-8')
#req和url，postdata绑定
req = urllib2.Request(surl, postdata)
#添加header，模拟浏览器
req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64) \
        AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36")
#获取网页信息
try:
    data = urllib2.urlopen(req).read()
except urllib2.URLError as e:
    if hasattr(e,"code"):
        print e.code
    if hasattr(e,"reason"):
        print e.reason
fh=open(sdir+"/5.html","wb")
fh.write(data)
fh.close()
```

#### 一些常用功能
##### 模拟浏览器：防止某些网站禁止用爬虫访问网页
在header中增加User-Agent信息
```Python
surl = "http://blog.csdn.net/shudaqi2010/article/details/43447363"
opener = urllib2.build_opener()
headers = ("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64) \
            AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36")
opener.addheaders=[headers]
data=opener.open(surl).read()
```
##### 超时设置
openurl中指定timeout参数
```Python
file=urllib2.urlopen("http://yum.iqianyue.com", timeout=60)
```

##### 设置代理服务器
build_opener可以传入多个参数，如果想要多个配置生效，需要一次性将其传入
```Python
def user_proxy(proxy_addr):
    proxy = urllib2.ProxyHandler({'http':proxy_addr})
    opener = urllib2.build_opener(proxy, urllib2.HTTPHandler)
    urllib2.install_opener(opener)
```
##### debug日志开关
```Python
def open_url_debug():
    httpd = urllib2.HTTPHandler(debuglevel=1)
    httpshd = urllib2.HTTPSHandler(debuglevel=1)
    opener = urllib2.build_opener(httpd, httpshd)
    urllib2.install_opener(opener)
```
##### 直接转储网页
```Python
urllib.urlretrieve("http://edu.51cto.com", filename=""+sdir+"/2.html")
```