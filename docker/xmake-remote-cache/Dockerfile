FROM ubuntu:22.04

RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && apt-get clean && apt-get update && apt-get install -y --fix-missing \
    build-essential \
    git \
    make \
    curl \
    lsof \
    vim

# XMake
ENV LATEST_XMAKE_VERSION v2.9.3+HEAD.71ec32ea6
ENV XMAKE_COMMIT_VERSION 71ec32ea6787c1c4b215ea40e1d5ab40c1c4eedc
ENV XMAKE_ROOT y
ENV XMAKE_PROGRAM_DIR /usr/local/share/xmake
ENV XMAKE_MAIN_REPO https://user:c91b0446f7a94ef081fd447205f7043e1715238690486@ezone.zelostech.com.cn/ezone/zelos/xmake-repo.git
ENV XMAKE_BINARY_REPO https://user:c91b0446f7a94ef081fd447205f7043e1715238690486@ezone.zelostech.com.cn/ezone/zelos/build-artifacts.git
RUN mkdir /software && cd /software \
    && git clone --recursive https://gitee.com/tboox/xmake.git \
    && cd xmake \
    && git checkout ${XMAKE_COMMIT_VERSION} \
    && ./configure \
    && make -j15 \
    && make install PREFIX=/usr/local \
    && xmake --version \
    && cd / && rm -r software

# XMake remote cache config
RUN mkdir -p /root/.xmake/service
ADD server.conf /root/.xmake/service/
ADD client.conf /root/.xmake/service/

# Workspace
EXPOSE 9692
WORKDIR /
ENTRYPOINT ["xmake", "service", "--ccache", "-vD"]
