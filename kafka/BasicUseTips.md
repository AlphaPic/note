### Sender Tips
- [消息是如何发出的](#消息是如何发出的)

#### 消息是如何发出的
1、kafka的消息是通过producer实例对一个发送的buffer的写入，然后通过一个异步的线程进行发送的,消息的发送受到几个参数的影响,其分别如下

|param|desc|
|:-:|:-:|
|batch.size||
|linger.ms||

2、在消息发出的过程中，预先经过拦截器进行处理，经过拦截器处理的消息然后

### Consumer Tips
