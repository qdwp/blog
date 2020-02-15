.. _get-x:

golang.org/x 库安装方法
################################

有时候在命令行使用 ``go get`` 安装工具包的时候，会无法下载。遇到如超时之类的问题。这时候可以从 Github 下载 Golang 工具包。

比如命令无法执行：

::

    go get -u golang.org/x/tools/cmd/present

解决方案：

1. 在 ``$GOPATH/src`` 路径下创建文件夹 ``golang.org/x``
2. 通过 ``git clone`` 命令下载工具包

::

    git clone https://github.com/golang/crypto.git
    git clone https://github.com/golang/lint.git
    git clone https://github.com/golang/net.git
    git clone https://github.com/golang/sys.git
    git clone https://github.com/golang/text.git
    git clone https://github.com/golang/tools.git

如上述需要安装使用 ``present`` 工具，还需要执行安装命令:

::

    go install golang.org/x/tools/cmd/present
