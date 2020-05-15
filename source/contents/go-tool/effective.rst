.. _go-effective:

Go 代码优化
################################

golang  在处理网路请求及高并发问题时，具有相当出彩的高效率。然而，有时候处理一下日常操作，如数据转化或字符串相关的问题时，
也会有很多肯优化性能的方法。如此，可以尽量压缩服务性能，减少资源消耗。


用字符串拼接替换 fmt
===========================


示例：

::

    fmt.Sprintf("%s-%s", first, second)

替换为：

::

    first + "-" + second


字符串比较尽量可以使用 byte
===============================

示例：

::

    // 3.5ns/op
    func (n Name) isWildCarded() bool {
        return len(n) > 0 && string(n[0]) == "*"
    }

替换为：

::

    const (
        // char  '*'
        wildcardStr = '*'
    )
    // 0.322ns/op
    func (n Name) isWildCarded() bool {
        return len(n) > 0 && n[0] == wildcardStr
    }


用 index +substring 来替代 Split
=========================================

示例：

::

    //  119 ns/op
    keys := strings.Split(clusterGroupName, "@")

替换为：

::

    // 11.6 ns/op
    c := strings.Index(clusterGroupName, "@")
    if c > 0 {
            keys := make([]string, 2)
            keys[0] = clusterGroupName[:c]
        keys[1] = clusterGroupName[c+1:]
        return keys[0], keys[1]
    }
