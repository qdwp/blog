.. _generic-dockerfile:

基于 Alpine 的通用 Dockerfile 模板
######################################



::

    FROM alpine:3.12

    # 使用清华软件源
    # RUN echo https://mirror.tuna.tsinghua.edu.cn/alpine/v3.12/main/ > /etc/apk/repositories && \
    #     echo https://mirror.tuna.tsinghua.edu.cn/alpine/v3.12/community/ >> /etc/apk/repositories

    # 使用阿里云软件源
    # RUN echo http://mirrors.aliyun.com/alpine/v3.12/main/ > /etc/apk/repositories && \
    #     echo http://mirrors.aliyun.com/alpine/v3.12/community/ >> /etc/apk/repositories

    # root 用户密码
    ENV ROOT_PASSWD=password


    # 更新软件源 && 修改时区

    RUN echo http://mirrors.aliyun.com/alpine/v3.12/main/ > /etc/apk/repositories \
        && echo http://mirrors.aliyun.com/alpine/v3.12/community/ >> /etc/apk/repositories \
        && apk update \
        && apk upgrade \
        && apk add --no-cache tzdata \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && adduser runner --disabled-password --system --no-create-home -G root \
    	&& echo -e "$ROOT_PASSWD\n$ROOT_PASSWD" | passwd root \
        && rm -rf /var/cache/apk/*

    # 切换当前用户
    USER runner

    # 指定当前工作目录
    # WORKDIR /work

    # 执行文件复制工作 ADD or COPY
    # ADD executefile /work/executefile

    # 文件权限
    # RUN chmod 777 /work/executefile

    # 执行目标二进制文件
    # CMD ["./executefile", "params"...]




\ `返回顶部⬆︎ <#>`_\
