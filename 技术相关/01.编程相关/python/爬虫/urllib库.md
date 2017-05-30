#### python2��python3������
**python2�������⣬urllib��urllib2��python3�н�urllib2�ϲ�����urllib**
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

#### ����������
������|����
--|--
200|OK,һ������
301|Moved Permanently���ض����µ�URL��������
302|Found���ض�����ʱ��URL����������
304|Not Modified���������Դδ����
400|Bad Request���Ƿ�����
401|Unauthorized������δ��Ȩ
403|Forbidden����ֹ����
404|Not Found��û���ҵ���Ӧҳ��
500|Internal Server Error���������ڲ����ִ���
501|Not Implemented����������֧��ʵ����������Ҫ�Ĺ���

#### ����
```
sdir = "D:/temp/Python3/myweb"
```
#### GET������ȡ��ҳ
```Python
surl = "http://www.baidu.com/s?wd="
key="�����ھ�"
# ������ı�������
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

#### POST������ȡ��ҳ
```Python
surl = "http://yum.iqianyue.com/mypost/"
postdata = urllib.urlencode({
"name":"ceo@iqianyue.com",
"pass":"aA123456"
}).encode('utf-8')
#req��url��postdata��
req = urllib2.Request(surl, postdata)
#���header��ģ�������
req.add_header("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64) \
        AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36")
#��ȡ��ҳ��Ϣ
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

#### һЩ���ù���
##### ģ�����������ֹĳЩ��վ��ֹ�����������ҳ
��header������User-Agent��Ϣ
```Python
surl = "http://blog.csdn.net/shudaqi2010/article/details/43447363"
opener = urllib2.build_opener()
headers = ("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64) \
            AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.81 Safari/537.36")
opener.addheaders=[headers]
data=opener.open(surl).read()
```
##### ��ʱ����
openurl��ָ��timeout����
```Python
file=urllib2.urlopen("http://yum.iqianyue.com", timeout=60)
```

##### ���ô��������
build_opener���Դ����������������Ҫ���������Ч����Ҫһ���Խ��䴫��
```Python
def user_proxy(proxy_addr):
    proxy = urllib2.ProxyHandler({'http':proxy_addr})
    opener = urllib2.build_opener(proxy, urllib2.HTTPHandler)
    urllib2.install_opener(opener)
```
##### debug��־����
```Python
def open_url_debug():
    httpd = urllib2.HTTPHandler(debuglevel=1)
    httpshd = urllib2.HTTPSHandler(debuglevel=1)
    opener = urllib2.build_opener(httpd, httpshd)
    urllib2.install_opener(opener)
```
##### ֱ��ת����ҳ
```Python
urllib.urlretrieve("http://edu.51cto.com", filename=""+sdir+"/2.html")
```