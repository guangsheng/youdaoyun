- 分包压缩和解压
```bash
tar czf - test.pdf | split -b 500 - test.tar.gz
cat logs.tar.bz2.a* | tar xj
```