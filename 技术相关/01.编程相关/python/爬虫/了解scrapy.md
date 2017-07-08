#### ÔÓÆßÔÓ°Ë
```
scrapy startproject myfirstpjt
scrapy startproject --logfile="logf.log" mypjt1

```



#### help
```
D:\MyZone\work\code\python\project\python_scrapy\part12\myfirstpjt>scrapy -h
Scrapy 1.4.0 - project: myfirstpjt

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

#### ÃüÁîÖ´ÐÐ¹ý³Ì
```
scrapy fetch http://www.baidu.com
```