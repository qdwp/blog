.. _02-var-type-const:

变量，类型和常量
#################

**目录：**

    * `变量`_
    * `类型`_
    * `常量`_

变量
============

这是 Golang 教程系列的第三节。本节的关注点是变量。

什么是变量
-------------

变量是为内存中用来存储特定类型数值位置的命名。在 go 中声明变量有多种语法。

声明一个简单的变量
----------------------

声明一个简单变量的语法是 **var name type**。

.. code-block:: go

    package main

    import "fmt"

    func main() {
        var age int // variable declaration
        fmt.Println("my age is", age)
    }

`Run in playground i2RoIaWVrif <https://play.golang.org/p/i2RoIaWVrif>`_

**var age int** 语句声明了一个 *int* 类型的变量叫做 *age*。

我们需要为声明的变量值。如果没有为变量指定值，go 会使用变量类型的零值来自动初始化它。当前情况下，*age* 会被指定值为 *0*。如果你运行这个程序，你就会看到一下输出。

.. code-block:: bash

    my age is 0

一个变量可以被指定多个对应类型的值。上面的程序中 *age* 可以被指定为任意整数。

.. code-block:: go

    package main

    import "fmt"

    func main() {
        var age int // variable declaration
        fmt.Println("my age is ", age)
        age = 29 //assignment
        fmt.Println("my age is", age)
        age = 54 //assignment
        fmt.Println("my new age is", age)
    }

`Run in playground z4nKMjBxLx <https://play.golang.org/p/z4nKMjBxLx>`_

上面的程序会输出一下内容：

::

    my age is  0
    my age is 29
    my new age is 54

声明一个变量并初始化
---------------------------

变量同样可以在声明的时候给定一个初始化的值。

声明一个变量并初始化的语法是 **var name type = initialvalue**。

.. code-block:: go

    package main

    import "fmt"

    func main() {
        var age int = 29 // variable declaration with initial value

        fmt.Println("my age is", age)
    }

`Run in playground TFfpzsrchh <https://play.golang.org/p/TFfpzsrchh>`_

在上面的程序中，age 是 int 类型的变量，并且拥有初始值 29。如果你运行上面的程序，你可以看到下面的输出结果。它表示 age 已经使用数值 29 初始化过了。

::

    my age is 29

类型推断
-------------

如果一个变量拥有初始值，Go 可以自动的根据变量使用的初始值来推断出变量的类型。所以如果变量有初始值的话，变量声明的 *type* 可以被省略。

如果变量声明的时候，使用语法 **var name = initialvalue**，Go 会根据初始化的值自动推断出这个变量的类型。

在下面的示例中，你可以看到第 6 行变量 *age* 的类型 *int* 被移除了。由于变量的初始值为 29, go 可以推断它是 int 类型。

::

    package main

    import "fmt"

    func main() {
        var age = 29 // type will be inferred

        fmt.Println("my age is", age)
    }

`Run in playground FgNbfL3WIt <https://play.golang.org/p/FgNbfL3WIt>`_

声明多个变量
-----------------

可以在一个语句中声明多个变量。

声明多个变量的语法是 **var name1, name2 type = initialvalue1, initialvalue2**。

::

    package main

    import "fmt"

    func main() {
        var width, height int = 100, 50 //declaring multiple variables

        fmt.Println("width is", width, "height is", height)
    }

`Run in playground 4aOQyt55ah <https://play.golang.org/p/4aOQyt55ah>`_

如果多个变量都有初始值，那么 *type* 同样可以省略。下面的程序就使用类型推断声明了多个变量。

::

    package main

    import "fmt"

    func main() {
        var width, height = 100, 50 //"int" is dropped

        fmt.Println("width is", width, "height is", height)
    }

`Run in playground sErofTJ6g <https://play.golang.org/p/sErofTJ6g>`_

上面的程序会打印输出 ``width is 100 height is 50``。

现在你应该猜测的到，如果 width 和 height 没有指定初始值，那么会默认分配 0 作为它们的初始值。

::

    package main

    import "fmt"

    func main() {
        var width, height int
        fmt.Println("width is", width, "height is", height)
        width = 100
        height = 50
        fmt.Println("new width is", width, "new height is ", height)
    }

`Run in playground DM00pcBbsu <https://play.golang.org/p/DM00pcBbsu>`_

上面的程序会打印::

    width is 0 height is 0
    new width is 100 new height is  50

在某些情况下，我们可能希望在单个语句中声明多个变量。执行此操作的语法是::

    var (
        name1 = initialvalue1
        name2 = initialvalue2
    )

下面的程序使用上面的语法声明了不同类型的变量。

::

    package main

    import "fmt"

    func main() {
        var (
            name   = "naveen"
            age    = 29
            height int
        )
        fmt.Println("my name is", name, ", age is", age, "and height is", height)
    }

`Run in playground 7pkp74h_9L <https://play.golang.org/p/7pkp74h_9L>`_

现在我们声明了 **string 类型的 name，int 类型的 age 和 height**。（我们将在下一节讨论这些变量的类型的相关内容）。运行上面的程序会生成输出 ``my name is naveen , age is 29 and height is 0``。

短式声明
-------------

Go 还提供了其他简洁的变量声明方式。这就是所谓的短式声明，它使用 ``:=`` 操作符。

短式声明的语法是 **name := initialvalue**。

::

    package main

    import "fmt"

    func main() {
        name, age := "naveen", 29 //short hand declaration

        fmt.Println("my name is", name, "age is", age)
    }

`Run in playground ctqgw4w6kx <https://play.golang.org/p/ctqgw4w6kx>`_

如果你运行上面的程序，你会看到输出 ``my name is naveen age is 29``。

短式声明要求分配符的左边所有变量必须指定初始值。下面的程序会抛出错误 ``cannot assign 1 values to 2 variables``，这是因为 **age 没有指定初始值**。

::

    package main

    import "fmt"

    func main() {
        name, age := "naveen" //error

        fmt.Println("my name is", name, "age is", age)
    }

`Run in playground wZd2HmDvqw <https://play.golang.org/p/wZd2HmDvqw>`_

只有在声明操作符 `:=` 左侧至少有一个新的变量时短式声明语法才可用。参考以下程序。

::

    package main

    import "fmt"

    func main() {
        a, b := 20, 30 // declare variables a and b
        fmt.Println("a is", a, "b is", b)
        b, c := 40, 50 // b is already declared but c is new
        fmt.Println("b is", b, "c is", c)
        b, c = 80, 90 // assign new values to already declared variables b and c
        fmt.Println("changed b is", b, "c is", c)
    }

`Run in playground MSUYR8vazB <https://play.golang.org/p/MSUYR8vazB>`_

上面的程序中，第 8 航的变量 **b** 已经声明过，不过 **c** 是新声明的变量，所以程序可以运行并输出：

::

    a is 20 b is 30
    b is 40 c is 50
    changed b is 80 c is 90

反之，如果我们运行下面的程序：

::

    package main

    import "fmt"

    func main() {
        a, b := 20, 30 //a and b declared
        fmt.Println("a is", a, "b is", b)
        a, b := 40, 50 //error, no new variables
    }

`Run in playground EYTtRnlDu3 <https://play.golang.org/p/EYTtRnlDu3>`_

会抛出错误 ``no new variables on left side of :=``。这是因为变量 **a** 和 **b** 都已经声明过了，在 `:=` 左边没有新的变量。

变量同样可以由程序运行时的计算结果指定。参考以下程序：

::

    package main

    import (
        "fmt"
        "math"
    )

    func main() {
        a, b := 145.8, 543.8
        c := math.Min(a, b)
        fmt.Println("minimum value is ", c)
    }

`Run in playground 7XojAtrpH9 <https://play.golang.org/p/7XojAtrpH9>`_

上面的程序中，c 的值为程序运行时决定，且为 a 与 b 中较小的值。程序将会打印

::

    minimum value is  145.8

因为 Go 是强类型语言，因此不能为声明为一种类型的变量分配其他类型的值。下面的程序尝试为被声明为 int 类型的变量 age 分配 string 类型的值，因此会抛出错误 ``cannot use "naveen" (type string) as type int in assignment``。

::

    package main

    func main() {
        age := 29      // age is int
        age = "naveen" // error since we are trying to assign a string to a variable of type int
    }

`Run in playground K5rz4gxjPj <https://play.golang.org/p/K5rz4gxjPj>`_

类型
============

下面是 go 中的基本变量类型:

* bool
* 数值类型
  * int8, int16, int32, int64, int
  * uint8, uint16, uint32, uint64, uint
  * float32, float64
  * complex64, complex128
  * byte
  * rune
* string


bool
---------------

一个 bool 类型的变量代表了一个非 *true* 即 *false* 的 bool 值。

::

    package main

    import "fmt"

    func main() {
        a := true
        b := false
        fmt.Println("a:", a, "b:", b)
        c := a && b
        fmt.Println("c:", c)
        d := a || b
        fmt.Println("d:", d)
    }

`Run in playground v_W3HQ0MdY <https://play.golang.org/p/v_W3HQ0MdY>`_


在上面的程序中，变量 a 被标记为 *true*，变量 b 被标记为 *false*。

变量 c 被标记为 ``a && b`` 的值，操作符 ``&&`` 在当且仅当 a 和 b 都为 *true* 的时候返回 *true*。所以这里变量 c 的值为 *false*。

操作符 ``||`` 会在 a 或 b 有一个为 *true* 的时候返回 *true*。因为这里 a 是 *true，所以 *变量 d 被标记为 *true*。上面的程序会有输出。

::

    a: true b: false
    c: false
    d: true


有符号整数
---------------

* ``int8``: 表示 8 位有符号整数
  * 大小: 8 位
  * 范围: -128 ~ 127

* ``int16``: 表示 16 位有符号整数
  * 大小: 16 位
  * 范围: -32768 ~ 32767

* ``int32``: 表示 32 位有符号整数
  * 大小: 32 位
  * 范围: -2147483648 ~ 2147483647

* ``int64``: 表示 64 位有符号整数
  * 大小: 64 位
  * 范围: -9223372036854775808 ~ 9223372036854775807

* ``int``: 由底层系统平台决定表示 32 位整数还是 64 位整数
  * 大小: 在 32 位系统上为 32 位， 在 64 位系统上为 64 位
  * 范围: 在 32 位系统上 -2147483648 ～ 2147483647，在 64 位系统上 -9223372036854775808 to 9223372036854775807

::

    package main

    import "fmt"

    func main() {
        var a int = 89
        b := 95
        fmt.Println("value of a is", a, "and b is", b)
    }

`Run in playground NyDPsjkma3 <https://play.golang.org/p/NyDPsjkma3>`_

上面的程序将会输出 ``value of a is 89 and b is 95``。

在上面的程序中，*变量 a 是 int 类型*，*变量 b 的类型由它被标记的值 95 来推断得到*。就像我们上面描述的，*int* 类型的大小在 32 位操作系统中是 32 位，在 64 位操作系统中是 64 位。下面继续并论证这个说法。

变量的类型可以使用 Printf 函数中的 **%T** 格式分类符打印出来。



常量
============



\ `返回顶部⬆︎ <#>`_\
