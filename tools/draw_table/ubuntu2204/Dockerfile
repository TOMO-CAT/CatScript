# 指定基础镜像
FROM ubuntu:22.04

# 维护者信息
# LABEL maintainer="Your Name <your_email@example.com>"

# 设置工作目录
# WORKDIR /app
# docker run -w /app

# 复制应用程序到容器中
# COPY app /app


# 安装依赖包
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get clean && apt-get update && \
    apt-get install -y --fix-missing \
    git \
    vim \
    net-tools 
    # 如果需要在 docker 中使用 apt 的话需要注掉这一行
    # && rm -rf /var/lib/apt/lists/* \


# 设置环境变量
# ENV MY_VAR=value

# 暴露端口
# EXPOSE 80

# 定义启动命令
# CMD ["/app/myapp"]

CMD /bin/bash
