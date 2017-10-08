1. 强制转换问题：强制转换后赋值可能会导致踩内存

```c
void getAddress(unsigned long * address)
{
    *address = 0L;
}

void main()
{
    unsigned int address;
    getAddress(unsigned long* address); //会踩高四字内存
}
```