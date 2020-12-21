.. _01-work-queues:


工作队列
######################

在本节中，我们将创建一个工作队列，用于在多个工作者（消费者）之间分配耗时任务。

工作队列（又称：任务队列），背后的主旨是避免立即执行资源密集型任务，且必须等待其运行结束。相对地，我们计划将任务推后完成。\
我们将任务包装成消息发送到队列中，后台的工作进程会将任务弹出并最终执行任务处理。当你运行多个工作进程时，它们之间将共享任务。

这个概念在 Web 程序中尤为有用，因为在一个 HTTP 短时窗口中处理复杂的任务是不现实的。


准备
------------

上一节我们发送了一条包含 ``Hello World!`` 的消息。现在来发送一条代表复杂任务的字符串。我们没有实际的任务操作，诸如调整图片大小，\
渲染 pdf 文件等。所以我们使用 ``time.Sleep`` 方法假装自己很忙。我们将字符串中的点的个数作为消息的复杂度，每一个点都被认为是\
工作 1 秒钟。例如，虚拟的任务描述 ``Hello...`` 会占用 3 秒钟。

我们稍微改动一下上一节中的 ``send.go`` 文件，允许从命令行发送任意消息字符串。这个修改后的程序会将任务安排到工作队列中，\
我们将其命名为 ``new_task.go``。

::

    body := bodyFrom(os.Args)
    err = ch.Publish(
      "",           // exchange
      q.Name,       // routing key
      false,        // mandatory
      false,
      amqp.Publishing {
        DeliveryMode: amqp.Persistent,
        ContentType:  "text/plain",
        Body:         []byte(body),
      })
    failOnError(err, "Failed to publish a message")
    log.Printf(" [x] Sent %s", body)

还有 bodyFrom 函数:

::

    func bodyFrom(args []string) string {
        var s string
        if (len(args) < 2) || os.Args[1] == "" {
            s = "hello"
        } else {
            s = strings.Join(args[1:], " ")
        }
        return s
    }

原先的 ``receive.go`` 文件也需作一些改动：程序需要为消息体中的每一个点都模拟一个耗时 1 秒的任务。新的程序会打印消息并执行任务，\
所以称其为 ``worker.go``。

::

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
        dot_count := bytes.Count(d.Body, []byte("."))
        t := time.Duration(dot_count)
        time.Sleep(t * time.Second)
        log.Printf("Done")
      }
    }()

    log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
    <-forever

注意这里我们模拟了执行任务消耗的时间。

运行上面的程序代码

::

    go run worker.go

::

    go run new_task.go


循环调度
-----------------

使用任务队列的优点是可以轻松的进行并行操作。如果任务造成了堆积，只需要增加工作者（消费者）就可以了，而且这种扩展的方式很简单。

首先，同时运行两个 ``worker.go`` 脚本，它们都会从队列中获得消息。实际上是不是这样呢？

你需要打开三个控制台窗口，其中两个运行 ``worker.go`` 脚本，表示有两个消费者：``C1`` 和 ``C2``。

.. image:: /_static/images/rabbit/rabbit-02-01.png

第一个控制台

::

    # shell 1
    go run worker.go
    # => [*] Waiting for messages. To exit press CTRL+C

第二个控制台

::

    # shell 2
    go run worker.go
    # => [*] Waiting for messages. To exit press CTRL+C

在第三个控制台中我们来生产新的消息任务。当你启动消费者后，可以在此发布新消息

::

    # shell 3
    go run new_task.go First message.
    go run new_task.go Second message..
    go run new_task.go Third message...
    go run new_task.go Fourth message....
    go run new_task.go Fifth message.....

来看一下我们的消费者做了什么

第一个消费者

::

    # shell 1
    go run worker.go
    # => [*] Waiting for messages. To exit press CTRL+C
    # => [x] Received 'First message.'
    # => [x] Received 'Third message...'
    # => [x] Received 'Fifth message.....'

第二个消费者

::

    # shell 2
    go run worker.go
    # => [*] Waiting for messages. To exit press CTRL+C
    # => [x] Received 'Second message..'
    # => [x] Received 'Fourth message....'

默认情况下，RabbitMQ 会将消息逐条发送给序列中的下一个消费者。平均下来每个消费者获得的消息数量应该是一样的。这种消息分配方式称为 \
**循环调度** 。你可以试试运行三个或更多消费者。


消息确认
---------------

执行一个任务需要一定的时间。当一个消费者执行一个长时间的任务，并且在完成了部分工作之后挂掉了，你可能希望知道其中发生了什么。\
使用当前的代码的话，一旦 RabbitMQ 将消息推送给消费者，就会立即将这条消息标记为已删除。这种情况下，如果杀掉了消费者，就会丢失\
它一直在处理的消息。同时，已经分配给这个消费者但还没有处理的消息也会丢失。

但是我们并不想丢失任何任务。如果一个消费者挂掉了，我们希望将分配给它的消息再推送给其它的消费者。

为确保消息永不丢失，RabbitMQ 支持消息 `确认机制 <https://www.rabbitmq.com/confirms.html>`_ 。消费者回传 \
ack（acknowledgement）来告知 RabbitMQ 已经接收了一个特定的消息并处理完成，RabbitMQ 可以自由地删除它。

如果一个消费者在发送确认消息之前挂掉了（信道关闭，连接关闭，TCP 连接丢失），RabbitMQ 会知道消息没有完成处理，并会将其放回队列。\
如果同一时间还有其他消费者在线，RabbitMQ 会立即将消息再推送给其他消费者。这样就可以确保即便有消费者偶尔挂掉，消息也永远不会丢失。

这里没有任何消息超时；当消费者挂掉之后，RabbitMQ 会再次推送消息。即使消息需要很长的时间来处理也没关系。

本教程中，我们通过设置 ``"auto-ack"`` 为 ``false`` ，一但任务完成，由消费者通过 ``d.Ack(false)`` 来手动发送恰当的确认消息\
（确认单次消息推送结束）。

::

    msgs, err := ch.Consume(
      q.Name, // queue
      "",     // consumer
      false,  // auto-ack       // need ack by manual
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
        dot_count := bytes.Count(d.Body, []byte("."))
        t := time.Duration(dot_count)
        time.Sleep(t * time.Second)
        log.Printf("Done")
        d.Ack(false)            // ack by manual
      }
    }()

    log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
    <-forever

使用上面的代码，可以确保即使你使用 ``CTRL+C`` 关闭了一个正在处理消息的消费者，消息也不会丢失。当这台机器挂掉之后，\
其所有未确认的消息都会被重新推送。

确认消息必须发送到与推送消息相同的信道，否则会产生信道层协议异常。


消息持久化
----------------

我们已经了解到，如何在消费者挂掉之后保证任务不丢失，但是如果 RabbitMQ 服务器停了消息还是会丢失的。

当 RabbitMQ 退出或者崩溃的时候，默认情况下会丢失所有队列和消息。确保消息不丢失需要保证两个点：同时将队列和消息标记为持久化。

首先，如果我们希望 RabbitMQ 永远不会丢失队列，我们需要将其声明为持久化。

::

    q, err := ch.QueueDeclare(
      "hello",      // name
      true,         // durable
      false,        // delete when unused
      false,        // exclusive
      false,        // no-wait
      nil,          // arguments
    )
    failOnError(err, "Failed to declare a queue")

尽管这段代码本身是正确的，但是在当前的环境中却无法运行。这是因为我们已经声明了一个名为 ``hello`` 的非持久化消息队列。RabbitMQ \
不允许使用不同的参数重复声明一个已存在的队列。但是我们可以使用其他的队列名，比如 ``task_queue`` ：

::

    q, err := ch.QueueDeclare(
      "task_queue", // name
      true,         // durable
      false,        // delete when unused
      false,        // exclusive
      false,        // no-wait
      nil,          // arguments
    )
    failOnError(err, "Failed to declare a queue")

队列声明持久化 ``durable`` 需要同是对生产者和消费者代码做出修改。

现在，即便是 RabbitMQ 重启我们也能保证 ``task_queue`` 队列中的消息不会丢失。这时候，我们需要在 ``amqp.Publishing`` \
中的使用 ``amqp.Persistent`` 选项，将消息标记为持久化的。

::

    err = ch.Publish(
      "",           // exchange
      q.Name,       // routing key
      false,        // mandatory
      false,
      amqp.Publishing {
        DeliveryMode: amqp.Persistent,
        ContentType:  "text/plain",
        Body:         []byte(body),
    })

**关于消息持久化**
    将消息标记为持久化并不一定能确保消息不会丢失。尽管会告知 RabbitMQ 将消息保存在磁盘中，但是在 RabbitMQ 接收到消息并保存之前，\
    还是有一个较短的时间窗口。而且，RabbitMQ 并不会对每一条消息都执行 fsync(2)  ，它可能只是将其缓存下来，而非是真的写到磁盘中。\
    这种持久化声明并不健壮，但是在处理简单的任务队列时足够用了。如果需要强保证消息持久化，可以使用 \
    `生产者确认模式 <https://www.rabbitmq.com/confirms.html>`_。


均衡分发
----------------

你现在可能已经注意到此时的消息调度并不是我们期望的那样。比如说，目前有两个消费者 ``worker`` ，当所有的奇数条消息都很重，而所有偶数条消息\
都很轻量时，就会导致一个 ``worker`` 非常忙，而另一个 ``worker`` 几乎不工作的情况。然而，RabbitMQ 并不知道这种情况，仍旧平均地调度消息。

这是由于 RabbitMQ 只是单纯地在消息进入队列时进行调度分派，而不会关心消费者未确认完成的消息数量。只是忙目地将第 N 条消息指派给第 N 个消费者。

.. image:: /_static/images/rabbit/rabbit-02-02.png

为了解决这个问题，我们可以将预指派计数设置为 1 。这会告诉 RabbitMQ 同一时间不要给一个 ``worker`` 指派多条消息。或者说，在一个 \
``worker`` 没有处理完并确认上一条消息之前，不要给它指派新的消息。而是将消息指派给下一个不忙的 ``worker`` 。

::

    err = ch.Qos(
      1,     // prefetch count
      0,     // prefetch size
      false, // global
    )
    failOnError(err, "Failed to set QoS")

**关于队列大小**
    如果所有的 ``worker`` 都处于忙碌状态，这时候你的队列可能会满。此时你就需要留意了，并且可能需要增加消费者 ``worker`` ，\
    或者采取一些其他的策略、


完整的代码示例
----------------------------

生产者 ``new_task.go``

::

    package main

    import (
        "log"
        "os"
        "strings"

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
            "task_queue", // name
            true,         // durable
            false,        // delete when unused
            false,        // exclusive
            false,        // no-wait
            nil,          // arguments
        )
        failOnError(err, "Failed to declare a queue")

        body := bodyFrom(os.Args)
        err = ch.Publish(
            "",     // exchange
            q.Name, // routing key
            false,  // mandatory
            false,
            amqp.Publishing{
                DeliveryMode: amqp.Persistent,
                ContentType:  "text/plain",
                Body:         []byte(body),
            })
        failOnError(err, "Failed to publish a message")
        log.Printf(" [x] Sent %s", body)
    }

    func bodyFrom(args []string) string {
        var s string
        if (len(args) < 2) || os.Args[1] == "" {
            s = "hello"
        } else {
            s = strings.Join(args[1:], " ")
        }
        return s
    }

消费者 ``worker.go``

::

    package main

    import (
        "bytes"
        "log"
        "time"

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
            "task_queue", // name
            true,         // durable
            false,        // delete when unused
            false,        // exclusive
            false,        // no-wait
            nil,          // arguments
        )
        failOnError(err, "Failed to declare a queue")

        err = ch.Qos(
            1,     // prefetch count
            0,     // prefetch size
            false, // global
        )
        failOnError(err, "Failed to set QoS")

        msgs, err := ch.Consume(
            q.Name, // queue
            "",     // consumer
            false,  // auto-ack
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
                dot_count := bytes.Count(d.Body, []byte("."))
                t := time.Duration(dot_count)
                time.Sleep(t * time.Second)
                log.Printf("Done")
                d.Ack(false)
            }
        }()

        log.Printf(" [*] Waiting for messages. To exit press CTRL+C")
        <-forever
    }


通过消息确认以及预指派计数可以实现一个工作队列。而持久化选项则可以保证在 RabbitMQ 重启后任务仍然可以继续。

关于 ``amqp.Channel`` 的更多信息以及消息的属性，可以浏览 `amqp API 参考 <http://godoc.org/github.com/streadway/amqp>`_ 。











\ `返回顶部⬆︎ <#>`_\
