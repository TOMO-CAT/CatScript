############################################################
# 指定基础镜像
############################################################
# FROM ubuntu:22.04
FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

############################################################
# 安装依赖
############################################################
RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
    && apt-get clean && apt-get update && apt-get install -y --fix-missing \
    build-essential \
    git \
    vim \
    iputils-ping \
    bear \
    wget \
    curl \
    sudo \
    python3-pip \
    make \
    cmake \
    htop \
    unzip \
    clang-format clangd clang \
    && pip install cpplint

############################################################
# install xmake
############################################################
ENV XMAKE_COMMIT_VERSION=v3.0.5
ENV XMAKE_ROOT=y
ENV XMAKE_STATS=n
ENV XMAKE_PROGRAM_DIR=/usr/local/share/xmake
ENV XMAKE_MAIN_REPO=https://github.com/zxmake/zxmake-repo.git
ENV XMAKE_BINARY_REPO=https://github.com/zxmake/zxmake-build-artifacts.git

RUN mkdir /software && cd /software \
    && git clone --recursive https://github.com/TOMO-CAT/xmake.git \
    && cd xmake \
    && git checkout ${XMAKE_COMMIT_VERSION} \
    && bash scripts/install.sh \
    && xmake --version \
    && cd / && rm -r software

############################################################
# install Bazel
############################################################
RUN mkdir /software && cd /software \
    && wget https://github.com/bazelbuild/bazel/releases/download/8.1.1/bazel-8.1.1-linux-x86_64 \
    && chmod +x bazel-8.1.1-linux-x86_64 \
    && mv bazel-8.1.1-linux-x86_64 /usr/local/bin/bazel \
    && bazel --version \
    && cd / && rm -r software

RUN mkdir /software && cd /software \
    && wget https://github.com/bazelbuild/buildtools/releases/download/6.0.1/buildifier-linux-amd64 \
    && chmod +x buildifier-linux-amd64 \
    && mv buildifier-linux-amd64 /usr/local/bin/buildifier \
    && buildifier --version \
    && cd / && rm -r software

############################################################
# install zig
############################################################
# 
# https://github.com/ziglang/docker-zig
# https://github.com/antonputra/tutorials/blob/main/lessons/208/http.zig/Dockerfile
#
# 下载页面: https://ziglang.org/download/
ENV ZIG_VER=0.14.0
RUN mkdir /software && cd /software \
    && curl https://ziglang.org/builds/zig-linux-$(uname -m)-${ZIG_VER}.tar.xz -o zig-linux.tar.xz \
    && tar xf zig-linux.tar.xz \
    && mv zig-linux-$(uname -m)-${ZIG_VER}/ /opt/zig \
    && cd / && rm -r software
ENV PATH=/opt/zig:$PATH

RUN git config --global --add safe.directory '*'

############################################################
# 安装 clang-18
############################################################
# RUN wget -qO- https://apt.llvm.org/llvm.sh | bash -s -- 18 \
#     && update-alternatives --remove clang /usr/bin/clang-14 \
#     && update-alternatives --remove clang++ /usr/bin/clang++-14 \
#     && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-18 1 --slave /usr/bin/clang++ clang++ /usr/bin/clang++-18

############################################################
# 安装 blade
############################################################
# RUN cd thirdparty/blade-build && ./install && echo 'export PATH=~/bin:$PATH' >> ~/.bashrc && bash

############################################################
# 切换到 $USER 用户
############################################################
ARG USER_NAME=root
RUN useradd -m ${USER_NAME}
# 设置密码
RUN echo "root:0000" | chpasswd
RUN echo "${USER_NAME}:0000" | chpasswd
# 设置免密 sudo
RUN echo "${USER_NAME} ALL=NOPASSWD: ALL" >> /etc/sudoers
USER ${USER_NAME}

# docker attach 进入 container 后的默认工作路径
# WORKDIR /app
