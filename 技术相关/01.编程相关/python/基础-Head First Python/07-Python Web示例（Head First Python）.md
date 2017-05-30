Python实现支持CGI的Web服务器 
```
from http.server import HTTPServer, CGIHTTPRequestHandler

port = 8080

httpd = HTTPServer(('', port), CGIHTTPRequestHandler)
print("Starting simple_httpd on port: " + str(httpd.server_port))
httpd.serve_forever()

启用CGI跟踪来帮助解决错误：在CGI脚本最前面加下面两行代码
import cgitb
cgitb.enable()
```