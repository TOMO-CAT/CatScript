# 指定基础镜像
FROM centos:latest

# 维护者信息
# LABEL maintainer="Your Name <your_email@example.com>"

# 设置工作目录
# WORKDIR /app

# 复制应用程序到容器中
# COPY app /app


# 安装依赖包
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* && \
    yum update -y && \
    yum -y install vim && \
    yum -y install net-tools && \
    yum -y install git && \
    yum -y install sudo && \
    yum clean all


# 设置环境变量
# ENV MY_VAR=value

# 暴露端口
# EXPOSE 80

# 定义启动命令
# CMD ["/app/myapp"]

CMD /bin/bash
