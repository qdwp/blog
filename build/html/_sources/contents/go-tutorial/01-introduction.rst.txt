.. _01-introduction:

介绍
######

**目录：**

    * `介绍与安装`_
    * `hello world`_

介绍与安装
=================

这是 Golang 教程系列的第一节。

什么是Golang？
-----------------

Go 也被称为 Golang，是由 Google 开发并开源的一种编译型和静态类型的编程语言。

Golang 的主要关注点在于使开发具有高可用和可伸缩的 Web 应用程序变得简单。

为什么选择 Golang？
--------------------

当有大量的其他语言 (如 python、ruby、nodejs) 时, 你为什么选择 Golang 作为你的服务端编程语言。

这里有一些我找到的使用 Go 的优点：


* 语言原生支持并发。因此，编写多线程程序是小菜一碟。这是通过 Goroutine 和 Channel 实现的，我们将在接下来的教程中讨论。

* Golang 是一种编译型语言。源代码会被编译成本机的二进制文件。这与解释型语言不同（如 Nodejs 中使用的 javaScript）。

* 语言规范非常简单。整个规范适合于一个页面，你甚至可以使用它来编写自己的编译器。

* Go 编译器支持静态链接。所有的代码都可以链接到一个大的二进制文件，它可以轻松的部署在云服务器上而不必担心依赖关系。

安装
-------

Golang 支持 Max, Windows, Linux 三个平台。你可以在官网下载
`https://golang.org/dl/ <https://golang.org/dl/>`_ 相应平台的二进制安装文件。

Mac
-----

从 `https://golang.org/dl/ <https://golang.org/dl/>`_ 下载 OS X 安装文件。双击开始安装。跟着提示走，Golang 会安装在 \
*/usr/local/go* 并且会将路径 */usr/local/go/bin* 加到 *PATH* 环境变量中。

Windows
-----------

从 `https://golang.org/dl/ <https://golang.org/dl/>`_ 下载 MSI 安装文件。双击开始安装
并跟着提示走。Golang 会安装在 *c:\Go* ，并且会将路径 *c:\Go\bin* 加到 *PATH* 环境变量中。

Linux
--------

从 `https://golang.org/dl/ <https://golang.org/dl/>`_ 下载 tar 文件并解压到 */usr/local* 。

将路径 */usr/local/go/bin* 手动添加到 *PATH* 环境变量中。这样，GO 就安装到 Linux 中了。

hello world
==================

这是 Golang 教程系列的第二节。请先阅读 `介绍与安装`_ 来了解什么是 Golang 以及如何安装 Golang 。

学习一门编程语言，没有什么比自己动手写代码更好的了。让我们开始编写我们的第一个 go 项目吧。

我个人比较推荐使用 `Visual Studio Code <https://code.visualstudio.com/>`_ ，装上 \
`Go 扩展插件 <https://marketplace.visualstudio.com/items?itemName=lukehoban.Go>`_ 就像是真正的 IDE 一样。\
它拥有自动补全，代码风格检查以及其他的很多功能。

设置 Go 工作空间
--------------------

在开始写代码之前，我们要先设置 go 工作空间。

如果是 **Mac** 或者 **Linux**，go 工作空间应该位于 **$HOME/go** 位置。所以接下来在 **HOME** 内创建 **go** 文件夹。

如果是 **Windows**，go 工作空间应该位于 **C:\Users\YourName\go**。所以需要在 **C:\Users\YourName** 位置创建 **go** 文件夹。

通过设置 GOPATH 环境变量，可以使用不用的目录作为工作空间。现在为了方便操作，我们使用上面的位置。

所有 go 的资源文件都应该位于工作空间内一个叫做 **src** 的文件夹内。因此，我们在上面创建的 **go** 目录中创建目录 **src**。

每个 go 项目都应该在 src 中拥有自己的子目录。让我们在 src 中创建一个目录 **hello** 来保存 hello world 项目。

创建上述目录后，目录结构应如下所示。

::

    go
        src
            hello

在我们刚刚创建的 hello 目录中将以下程序保存为 **helloworld.go**。

.. code-block:: go

    package main

    import "fmt"

    func main() {
        fmt.Println("Hello World")
    }

创建上述的程序后，目录结构应如下所示。

::

    go
        src
            hello
                helloworld.go

运行 Go 程序
--------------

1. 使用 **go run** 命令 - 在命令提示符模式下输入 ``go run workspacepath/src/hello/helloworld.go``。

  上面命令中 **workspacepath** 应该替换成你自己的工作空间（在 Windows 中是 **C:/Users/YourName/go**，Linux 或 Mac 中是 \
  **$HOME/go**）。

  你可以在控制台看到输出 ``hello world``。

2. 使用 **go install** 命令 - 在目录 ``workspacepath/bin/hello`` 运行 ``go install hello`` 来执行这个程序。

  上面命令中 **workspacepath** 应该替换成你自己的工作空间（在 Windows 中是 **C:/Users/YourName/go**，Linux 或 Mac 中是 \
  **$HOME/go**）。

  你可以在控制台看到与上面同样的输出 ``hello world``。

  当你输入 **go install hello**，go tool 工具会在工作空间内寻找 hello 包。然后会在工作空间的 bin 目录下创建一个二进制文件 \
  ``hello`` （在 Windows 下为 ``hello.exe``）。文件结构如下 ::

        go
            bin
                hello
            src
                hello
                    helloworld.go

3. 第三种比较炫的方式是在 **go playground** 中运行程序。尽管它有着一定的局限性，但是运行一些简单的程序还是非常方便的。\
`点击这里 <https://play.golang.org/p/VtXafkQHYe>`_ 可以跳转到我已经创建好的程序。

  你也可以使用 `go playground <https://play.golang.org/>`_ 来分享你自己的代码。

一份 hello world 程序的简单说明
--------------------------------------

下面是我们刚刚写的 hello world 程序。

.. code-block:: go

    package main //1

    import "fmt" //2

    func main() { //3
         fmt.Println("Hello World") //4
    }

在这里我们将简单的了解一下程序的每一行都做了什么，然后将在接下来的教程总深入讲解每个部分。

**package main** - **每一个 go 文件都必须以 ``package name`` 语句开始**。包被用于提供代码划分和代码重用，这里使用的包名是 \
``main`` 。

**import "fmt"** - 引入 fmt 包，它可将在 main 函数中向标准输出打印文本。

**func main()** - main 函数是一个特别的函数。程序的执行都是从 main 函数开始的。main 函数应该一直处于 main 包内。符号 \
**{** 和 **}** 表示 main 函数的开始与结束。

**fmt.Println("Hello world")** - 包 **fmt** 中的 **Println** 函数是用来向标准输出写入文本的。

上面的代码可以从 `Github <https://github.com/golangbot/hello>`_ 下载。


\ `返回顶部⬆︎ <#>`_\
