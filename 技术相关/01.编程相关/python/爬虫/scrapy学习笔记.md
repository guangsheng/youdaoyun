### ��ʹ��
#### ������Ŀ
```
scrapy startproject pjoname

cd pjoname
scrapy generate example example.com
```
#### �����Ŀ
```scrapy list```
#### ִ��ץȡ
```scrapy crawl pjoname```

#### ���ɳ����ļ�����
##### items.py
- ����Ҫ�������ȡ������Ϣ���൱�ڴ洢��ȡ�������ݵ�������
- �ṹ����
- ʵ�������������ʵ������һ���ֵ䣬key�Ƕ�����ֶ����֣�value����ȡ����ֵ

##### pipelines.py
- ���մ�֩���������ȡ������Ŀitem����������
- ���Զ�items�ﶨ������ݽ��н�һ���ӹ�����Ҳ����ÿ��ȡ��һ�����ݶ������һ�θ��ļ��ж����ָ������
- �����Ĵ�����Ҫ�У���ϴ����֤���洢��

##### spiders/example.py
- �����ļ�
- ���Դ�ģ�����ɣ��������ࣨSpider�������ࡣ
- ��ȡ�߼���������ȡ�߼��Ⱦ�������ļ�����
- ��Ҫ����Scrapy������response��Ӧ��������response��Ӧ�󣬻����Щresponse��Ӧ���з�������Ȼ����ȡ����Ӧ�Ĺ�ע�����ݣ�Ҳ������ȡ����������Ҫ���������ַ����Ϣ��

##### settings.py

#### ����˵��
- startproject �������ָ����־�ļ�����־�����

### scrapy�������
```
# ��ʾ��ȡ���̡����������ļ����鿴scrapy������Ϣ���ṩ�����նˡ����ܲ��ԡ����������ļ����������桢�Ϸ��Լ���
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