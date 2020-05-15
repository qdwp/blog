.. _01-start:


入门介绍
######################

启动 RabbitMQ 服务

::

    docker run -it --name rabbit \
      --hostname myrabbit \
      -p 25672:25672 \
      -p 5672:5672 \
      -p 15672:15672 \
      -p 15671:15671 \
      -d rabbitmq:3.7-management-alpine

本教程假定本机（localhost）已经安装了 RabbitMQ 环境，并以端口 5672 启动。如果是以其它端口启动，使用时配置需要做相应的调整。

介绍
------------

RabbitMQ 是一个消息中间件：它可以接收并转发消息。你可以把它想象成一个邮局，当你希望向寄件箱中放入一封信件时，你需要确认最终的收件人。\
与之类似的，RabbitMQ 扮演的就是寄件箱、邮局和寄件人。

与邮局最大的不同点在于，RabbitMQ 不处理信件，它接收、存储和转发的二进制数据称为消息。

RabbitMQ 以及一般传递的消息都使用了一些术语。

**生产者**
    仅仅表示发送消息
**队列**
    表示在 RabbitMQ 中的寄件箱。虽然消息在 RabbitMQ 与应用程序之间流转，但是它只存储在队列中。队列只受主机内存和磁盘限制的约束，\
    它本质上是一个大的消息缓冲区。队列允许多个生产者向其发送消息，并允许多个消费者从中接收消息数据。
**消费者**
    表示接收消息

注意，生产者，消费者和消息代理（broker）不一定非要在同一台主机上；实际上大部分应用都不是在同一主机的。同样，一个应用既可以是生产者，\
也可以是消费者。


**使用 Go RabbitMQ 客户端**

本节使用 Go 语言实现了两个简单程序：一个用于发送单条消息的生产者；和一个接收消息并打印的消费者。想了解更多可以参考 \
`Go RabbitMQ API <http://godoc.org/github.com/streadway/amqp>`_ 文档。这里只关注最简单的实现，发送一条 \
"Hello World" 消息。

下图中，"P" 表示生产者，"C" 表示消费者，中间的盒子表示队列-RabbitMQ为消费者持有的消息缓存区。

.. image:: ../../_static/images/common/rabbit-01-01.png

**安装 Go 客户端组件库**

::

    go get github.com/streadway/amqp

现在我们已经安装了 amqp，可以写代码了。


发送消息
--------------

.. image:: ../../_static/images/common/rabbit-01-02.png

我们将 ``send.go`` 定为生产者（发送方），将 ``receive.go`` 定为消费者（接收方）。生产者会连接到 RabbitMQ，发送一条消息，\
然后退出。示例程序如下：

::

    package main

    import (
        "log"

        "github.com/streadway/amqp"
    )

    func failOnError(err error, msg string) {
        if err != nil {
            log.Fatalf("%s: %s", msg, err)
        }
    }

    func main() {
        conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
        failOnError(err, "Failed to connect to RabbitMQ")
        defer conn.Close()

        ch, err := conn.Channel()
        failOnError(err, "Failed to open a channel")
        defer ch.Close()

        q, err := ch.QueueDeclare(
            "hello", // name
            false,   // durable
            false,   // delete when unused
            false,   // exclusive
            false,   // no-wait
            nil,     // arguments
        )
        failOnError(err, "Failed to declare a queue")

        body := "Hello World!"
        err = ch.Publish(
            "",     // exchange
            q.Name, // routing key
            false,  // mandatory
            false,  // immediate
            amqp.Publishing{
                ContentType: "text/plain",
                Body:        []byte(body),
            })
        log.Printf(" [x] Sent %s", body)
        failOnError(err, "Failed to publish a message")
    }

声明一个队列很有必要，并且它只会在队列不存在时才创建。发送的消息体是字节数组，所以你可以编码任何你希望发送的数据。

注意：如果发送失败，先检查一下磁盘空间是否足够。RabbitMQ broker 默认需要 200M 磁盘空间才能启动。\
参考 `配置文档 <http://www.rabbitmq.com/configure.html#config-items>`_ 中 ``disk_free_limit`` 属性。


接收消息
---------------

消费者是相对对生产者而言的，它会监听 RabbitMQ 中的消息。与生产者仅仅发送一条消息不同，消费者会保持运行来监听并打印输出。

.. image:: ../../_static/images/common/rabbit-01-03.png

::

    package main

    import (
        "log"

        "github.com/streadway/amqp"
    )

    func failOnError(err error, msg string) {
        if err != nil {
            log.Fatalf("%s: %s", msg, err)
        }
    }

    func main() {
        conn, err := amqp.Dial("amqp://guest:guest@localhost:5672/")
        failOnError(err, "Failed to connect to RabbitMQ")
        defer conn.Close()

        ch, err := conn.Channel()
        failOnError(err, "Failed to open a channel")
        defer ch.Close()

        q, err := ch.QueueDeclare(
            "hello", // name
            false,   // durable
            false,   // delete when unused
            false,   // exclusive
            false,   // no-wait
            nil,     // arguments
        )
        failOnError(err, "Failed to declare a queue")

        msgs, err := ch.Consume(
            q.Name, // queue
            "",     // consumer
            true,   // auto-ack
            false,  // exclusive
            false,  // no-local
            false,  // no-wait
            nil,    // args
        )
        failOnError(err, "Failed to register a consumer")

        forever := make(chan bool)

        go func() {
            for d := range msgs {
                log.Printf("Received a message: %s", d.Body)
            }
        }()

        log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
        <-forever
    }


合并运行生产者与消费者
------------------------------------------

现在开始运行这两个脚本。首先在终端运行生产者：

::

    go run send.go

然后运行消费者：

::

    go run receive.go

消费者会打印生产者通过 RabbitMQ 发送的消息。然后消费者会保持运行状态（使用 Ctrl + C 可以退出），并且此时可以在其它终端再运行生产者。

在 RabbitMQ 的管理页面可以看到消息队列的详细信息，本地测试访问 `http://127.0.0.1:15672`，默认用户名：guest，密码：guest。


\ `返回顶部⬆︎ <#>`_\
