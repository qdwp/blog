.. _chapter1:

与环境交互
############

**目录：**
    * `检查Golang版本`_
    * `接收程序参数`_
    * `使用 flag 包创建程序接口`_

检查Golang版本
=================

当构建一个程序，特别是你的应用程序很复杂的时候，最好的实践是输出一下环境设置、构建版本以及\
运行时版本。这有助于分析问题，防止发生错误。

除了构建版本以及环境变量以外，用以编译二进制文件的 Go 版本也会包含在打印日志中。接下来的\
技巧将展示如何将 Go 运行时的版本信息包含到此类程序中。

准备
------

按照以下步骤安装并校验 Go 安装程序：

1. 下载并在电脑上安装 Go 程序
#. 校验 ``GOPATH`` 和 ``GOROOT`` 是否已经正确设置
#. 打开终端并执行 ``go version``，如果看到输出版本信息，那么 Go 已经正确安装了
#. 在 ``GOPATH/src`` 文件夹内创建代码仓库


实现
------

以下步骤涵盖了解决方案：

1. 打开控制台并创建文件夹 ``chapter01/recipe01``
2. 导航到该目录
3. 创建 ``main.go`` 文件并写入以下内容：

.. code-block:: go

    package main

    import (
        "log"
        "runtime"
    )

    const info = `
        Application %s starting.
        The binary was build by GO: %s`

    func main() {
        log.Printf(info, "Example", runtime.Version())
    }

4. 使用命令 ``go run main.go`` 运行
5. 查看终端输出：

.. code:: bash

    # output:
        Application Example starting.
        The binary was build by GO: go1.11.1

原理
------

``runtime`` 包涵盖了很多有用的函数。比如查看 Go 的运行时版本可以使用 ``Version`` 函数。\
文档表明该函数返回提交时的哈希值，以及二进制文件构建时的日期和标记。

``Version`` 函数实际上返回的是常量  ``runtime/internal/sys.TheVersion``。\
这个常量位于 ``$GOPATH/src/runtime/internal/sys/zversion.go`` 文件中。

这个 ``.go`` 文件由 ``go dist`` 工具生成，并且由 ``go/src/cmd/dist/build.go`` 中\
的 ``findversion`` 这个函数判定 Go 的版本，下面会详细说明。

在判定 Go 版本的时候，优先级最高的是 ``$GOROOT/VERSION`` 文件，如果这个文件为空或不存\
在的话，则查看 ``$GOROOT/VERSION.cache`` 文件。如果 ``$GOROOT/VERSION.cache`` \
文件也找不到的话，那么工具会尝试从 Git 信息中判断 Go 版本，前提是已经为 Go 代码\
创建 Git 仓库。

################################

接收程序参数
==============

参数化运行程序的最简单的方式是使用命令行参数作为程序参数。

参数化程序调用看起来像这样：``./parsecsv user.csv role.csv`` 。这里，parsecsv 是执行的二进制程序的名字，``user.csv`` \
和 ``role.csv`` 是参数，这些参数影响了程序的调用（此例表示将格式化数据结果输出到文件中）。

**代码展示：**

.. code-block:: go

   code content

    package main

    import (
    	"fmt"
    	"os"
    )

    func main() {

    	args := os.Args

    	// 打印所有命令行参数
    	fmt.Println(args)

    	// 第一个参数，即切片下表为0的参数，是二进制程序的文件名
    	programName := args[0]
    	fmt.Printf("The binary name is: %s \n", programName)

    	// 取出除第一个参数外的其他参数
    	otherArgs := args[1:]
    	fmt.Println(otherArgs)

    	for idx, arg := range otherArgs {
    		fmt.Printf("Arg %d = %s \n", idx, arg)
    	}
    }

**编译程序：**

::

    go build -o test

**运行程序：**

::

    ./test arg1 arg2

**输出结果：**

::

    [./test arg1 arg2]
    The binary name is: ./test
    [arg1 arg2]
    Arg 0 = arg1
    Arg 1 = arg2

**详细说明：**

在程序调用时接收参数，Go 标准库提供的方法很少。最常见的方式是使用 os 包提供的变量 Args 来接收参数。

这种方式可以通过命令行将所有参数放入一个字符串切片中。优点是你可以动态的输入参数的个数，比如文章开始时的例子，输入文件名并交由程序处理。

上面的程序仅仅是输出程序的所有参数。编译后的二进制程序名为 test，在终端执行命令：

::

    ./test arg1 arg2

程序中，os.Args[0] 会返回 ``./test`` ，而 ``os.Args[1:]`` 返回除二进制程序名外的其他参数。而实际应用中，最好不要完全信任程序输入\
的参数数量，而应该保持检查参数数组的长度。此外，如果给出了超出范围的下标，程序会 Panic。

**拓展信息：**

如果参数使用了 flag 标记，如 ``-flah calue``，那么需要一些额外的逻辑将 value 分配到 flag 上。这里，可以使用 flag 包实现参数解析，\
详细内容将在下节展开描述。

##########################################

使用 flag 包创建程序接口
=============================

前一节提到了一种非常常用的方式来接收程序参数。

本节提供了通过程序标记来定义接口的方式来接收程序参数。这种方法基于 GNU/Linux，BSD，和 macOS 系统。比如在 UNIX 系统中，调用 ``ls -l``，\
会列出当前文件夹中的文件。

Go标准库中 flag 不支持处理组合标记，如 ``ls -ll``，这里一个短横线后面有两个标记。每一个标记都应该是独立的。Go 语言中 ``flag`` \
包同样不区分长选项标记和短选项标记，比如 ``-flag`` 和 ``--flag`` 是等价的。

**代码展示：**

.. code-block:: go

    package main

    import (
        "flag"
        "fmt"
        "log"
        "os"
        "strings"
    )

    // 自定义类型，并实现 flag.Value 接口，
    // 以支持 flag.Var 函数调用。
    type ArrayValue []string

    func (s *ArrayValue) String() string {
        return fmt.Sprintf("%v", *s)
    }

    func (a *ArrayValue) Set(s string) error {
        *a = strings.Split(s, ",")
        return nil
    }

    func main() {

        // 调用返回指针的函数，解析标记的值
        retry := flag.Int("retry", -1, "Defines max retry count")

        // 使用 XXXVar 函数读取标记值。这里用于接收标记值的变量必须定义在标记之前。
        var logPrefix string
        flag.StringVar(&logPrefix, "prefix", "", "Logger prefix")

        var arr ArrayValue
        flag.Var(&arr, "array", "Input array to iterate through.")

        // 执行 flag.Parse 函数，才会实际将标记值读入定义的变量中。
        // 如果没有调用这个函数，变量仍为空值。
        flag.Parse()

        logger := log.New(os.Stdout, logPrefix, log.Ldate)

        retryCount := 0
        for retryCount < *retry {
            logger.Println("Retrying connection")
            logger.Printf("Sending array %v\n", arr)
            retryCount++
        }
    }

**编译程序：**

::

    go build -o util

**运行程序：**

::

    ./util -retry 2 -prefix=example -array=1,2

**输出结果：**

::

    example2019/10/31 Retrying connection
    example2019/10/31 Sending array [1 2]
    example2019/10/31 Retrying connection
    example2019/10/31 Sending array [1 2]

**详细说明：**

通过代码中使用的标记，可以看到 ``flag`` 包中定义了两种类型的函数。

第一种是单标记类型名，如 ``Int`` 函数。这个函数返回一个指向 ``Integer`` 变量的指针，其值为标记对应解析的结果。

第二种是 ``XXXVar`` 这样的函数。它提供了一类函数，不过你需要为函数提供指向变量的指针。解析出来的标记值会保存到给定的变量中。

Go 标准库同样支持自定义标记类型，不过自定义的类型需要实现 ``flag`` 包中的 ``Value`` 接口。

代码示例中，标记 ``retry`` 定义了连接到终端的重试次数限制，标记 ``prefix`` 定义了每行日志的前缀，标记 ``array`` 定义了\
需要发送到服务器的数组。

在实际使用这些解析到的标记值之前，还有最重要的一点，就是 ``Parse()`` 函数，它会将从 ``Args[1:]`` 中的参数解析为标记定义。\
这个函数必须在标记定义之后、接收实际值之前调用。

前面的代码展示了如何从命令行解析一些数据类型。同样，也可以解析其他内置数据类型。

对于代码中最后一个标记 ``array`` 的用法，表示可以定义自定义类型的标记。注意，``ArrayType`` 实现了 ``flag`` 包中的 \
``Value`` 接口。

**拓展信息：**

在 ``flag`` 包还设计了很多关于标记的接口，可以阅读一下关于 ``FlagSet`` 的文档。


\ `返回顶部⬆︎ <#>`_\
