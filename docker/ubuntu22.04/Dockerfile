# 指定基础镜像
FROM ubuntu:22.04

# 安装依赖
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get clean && apt-get update && apt-get install -y --fix-missing \
    # build-essential \
    git \
    iputils-ping \
    # python2.7 \
    # ninja-build \
    # zlib1g-dev \
    bear \
    wget \
    # uuid-dev \
    # unzip \
    sudo \
    python3-pip \
    # nvidia-cuda-toolkit \
    # && ln -s /usr/bin/python2.7 /usr/bin/python \
    && pip install cpplint

# 切换到用户 CAT (由于我们在 docker run 中直接映射了宿主机的 /etc/group 等信息, 因此没必要添加用户)
# RUN groupadd -r cat && useradd -r -g cat cat
# RUN mkdir /home/cat
# RUN chown -R cat:cat /home
# RUN echo "root:0000" | chpasswd
# RUN echo "cat:0000" | chpasswd
# RUN echo "cat ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# USER cat

# 安装 blade
# RUN cd thirdparty/blade-build && ./install && echo 'export PATH=~/bin:$PATH' >> ~/.bashrc && bash

# docker attach 进入 container 后的默认工作路径
# WORKDIR /app
