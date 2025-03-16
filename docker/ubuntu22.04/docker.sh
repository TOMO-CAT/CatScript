#!/bin/bash

set -e

# Docker Container 名
DOCKER_CONTAINER="container_${USER}_${PROJECT_NAME}"
# Docker hostname
DOCKER_HOSTNAME="docker_dev"

# 项目所在文件夹
PROJECT_BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")";pwd)"
# 项目名: 取自项目文件夹
PROJECT_NAME="$(basename ${PROJECT_BASE_DIR})"
# Docker 镜像
DOCKER_IMAGE="${PROJECT_NAME}:latest"

function info() {
  (>&2 printf "[\e[34m\e[1mINFO\e[0m] $*\n")
}

function error() {
  (>&2 printf "[\033[0;31mERROR\e[0m] $*\n")
}

function warning() {
  (>&2 printf "[\033[0;33mWARNING\e[0m] $*\n")
}

function ok() {
  (>&2 printf "[\e[32m\e[1m OK \e[0m] $*\n")
}

function help_info() {
  local bash_name=$(basename "${BASH_SOURCE[0]}")
  echo "Usage: bash docker.sh COMMAND [OPTIONS]"
  echo ""
  echo "A script to build/run/delete docker container easily"
  echo ""
  echo "Commands:"
  echo "  run              Run container."
  echo "  build            Build container."
  echo "  clear            Delete image && container for this project." 
  echo "  help             Print help text."
  echo ""
  echo "[OPTIONS] for docker clear:"
  echo "  --image          Delete docker image."
  echo ""
}

function docker_run() {
  docker exec -it ${DOCKER_CONTAINER} /bin/bash -c "source /home/${USER}/.profile && /bin/bash"
}

function docker_build() {
  # 检查镜像是否存在, 不存在则 build
  if docker images | awk '{print $1":"$2}' | grep -q ${DOCKER_IMAGE}; then
    info "Docker image ${DOCKER_IMAGE} already exists."
  else
    info "Docker image ${DOCKER_IMAGE} does not exist. Start building..."
    docker build --build-arg USER_NAME="${USER}" -t ${DOCKER_IMAGE} .
  fi

  # 检查 docker container 是否存在, 存在则 docker build 结束
  if docker ps -a | grep -q "${DOCKER_CONTAINER}"; then
    info "Docker container ${DOCKER_CONTAINER} already exists."
    exit 0
  fi

  info "Docker container ${DOCKER_CONTAINER} does not exist. Starting..."

  # 编辑 docker container 的启动参数

  ## 1. 决定在哪个 X 服务器上显示界面
  # local display="${DISPLAY}"
  # [ -z "${display}" ] && display=":0"
  local display=":0"

  ## 2. 设备映射
  local devices=" --volume /dev:/dev"

  ## 3. 其他参数
  USER_ID=$(id -u)
  GRP=$(id -g -n)
  GRP_ID=$(id -g)
  LOCAL_HOST=$(hostname)

  ## 4. home 目录
  DOCKER_HOME="/home/$USER"
  [ "$USER" == "root" ] && DOCKER_HOME="/root"

  ## 创建一些宿主机目录方便后面映射, 避免 --volume 挂载时文件不存在
  [ ! -f "${HOME}/.gitconfig" ] && touch "${HOME}/.gitconfig"
  # 不挂载 ~/.profile 和 ~/.bashrc 了, 因为如果这里面定义了 CXX CPP CC 和 LD 环境变量会影响交叉编译
  # [ ! -f "${HOME}/.profile" ] && touch "${HOME}/.profile"
  # [ ! -f "${HOME}/.bashrc" ] && touch "${HOME}/.bashrc"
  [ ! -d "${HOME}/.ssh" ] && mkdir "${HOME}/.ssh"

  ## 5. 通用参数
  #
  # -v ${HOME}:${docker_home} 比较危险, 这里只映射一些常用的文件夹
  #
  # --restart always 表示进程退出时总是重启
  general_param="-it -d \
    --privileged \
    --restart always \
    --name ${DOCKER_CONTAINER} \
    --env DISPLAY=${display} \
    --env DOCKER_USER=root \
    --env USER=${USER} \
    --env DOCKER_USER_ID=${USER_ID} \
    --env DOCKER_GRP=${GRP} \
    --env DOCKER_GRP_ID=${GRP_ID} \
    --env DOCKER_IMG=${DOCKER_IMAGE} \
    --volume ${PROJECT_BASE_DIR}:/${PROJECT_BASE_DIR} \
    --volume ${HOME}/.gitconfig:${DOCKER_HOME}/.gitconfig \
    --volume ${HOME}/.ssh:${DOCKER_HOME}/.ssh \
    --volume /etc/passwd:/etc/passwd:ro \
    --volume /etc/shadow:/etc/shadow:ro \
    --volume /etc/group:/etc/group:ro \
    --volume /etc/localtime:/etc/localtime:ro \
    --volume /etc/resolv.conf:/etc/resolv.conf:ro \
    ${devices} \
    --net host \
    --add-host in_dev_docker:127.0.0.1 \
    --add-host ${LOCAL_HOST}:127.0.0.1 \
    --hostname in_dev_docker \
    --workdir ${PROJECT_BASE_DIR}"

  # 启动 docker container
  info "Starting docker container \"${DOCKER_CONTAINER}\" ..."

  if [ "$(uname)" == "Darwin" ] ;then
    ## 1. macOS 暂不支持
    error "No support macOs now!"
    exit -1
  else
    ## 2. Linux
    # ro 表示只读
    #
    # https://unix.stackexchange.com/questions/581445/why-su-gives-su-authentication-failure-even-when-running-as-root
    # /etc/shadow 避免在 docker 中通过 su 命令切换到普通用户报错: Authentication failure
    #
    # ${HOME}/.bashrc 主要是为了 ll 命令
    #
    # https://stackoverflow.com/questions/48507140/docker-docker-error-response-from-daemon-linux-spec-user-unable-to-find-user
    # 如果 -u ${USER} 会报错 docker: Error response from daemon: unable to find user cat: no matching entries in passwd file.
    # 可以使用 --user $(id -u) 代替
    #
    docker run ${general_param} ${DOCKER_IMAGE} /bin/bash
  fi

  # 如果当前目录根目录存在 BLADE_ROOT 则以 USER 用户安装 blade
  # 目前都是自己手动安装: "cd thirdparty/blade-build/ && ./install && /bin/bash"
  # [ -f "${PROJECT_BASE_DIR}/BLADE_ROOT" ] && {
  #   info "Installing blade for project with BLADE_ROOT file ..."
  #   docker exec --user $(id -u):$(id -g) ${DOCKER_CONTAINER} bash -c "cd thirdparty/blade-build/ && ./install && /bin/bash"
  # } || {
  #   info "Skip install blade because this project don't have BLADE_ROOT file"
  # }

  docker exec ${DOCKER_CONTAINER} /bin/bash -c 'echo DOCKER_IMAGE: ${DOCKER_IMG}'
  ok 'Docker environment has already been setted up, you can enter with cmd: "bash scripts/docker.sh run"'
}

function docker_clear() {
  local docker_clear_image=false
  while [ $# -ge 1 ]; do
    case "$1" in
    --image )
      docker_clear_image=true
      shift 1
      ;;
    * )
      error "Invalid param for docker clear"
      echo ""
      help_info
      exit -1
      ;;
    esac
  done

  # 停止并删除对应的 docker container
  # (docker container stop ${DOCKER_CONTAINER} 1>/dev/null && docker container rm -f ${DOCKER_CONTAINER} 1>/dev/null) || true
  info "Stoping docker container \"${DOCKER_CONTAINER}\" ..."
  docker container stop ${DOCKER_CONTAINER} 1>/dev/null || warning "No such container: ${DOCKER_CONTAINER}"
  info "Deleting docker container \"${DOCKER_CONTAINER}\" ..."
  docker container rm -f ${DOCKER_CONTAINER} 1>/dev/null || warning "No such container: ${DOCKER_CONTAINER}"

  # 删除对应镜像
  if ${docker_clear_image}; then
    info "Deleting docker image \"${DOCKER_IMAGE}\" ..."
    docker rmi ${DOCKER_IMAGE}
  fi
  ok "Delete docker container [${DOCKER_CONTAINER}] successfully!"
}

function main() {
  # 参数必须大于等于 1
  [ $# -lt 1 ] && {
    echo "Please set param for docker.sh!"
    echo ""
    help_info
    exit -1
  }

  # 将第一个参数赋值给 cmd 并删掉第一个参数, 剩下的参数作为二级参数传递给 docker clear 等
  local cmd=$1
  shift 1

  case ${cmd} in
  run )
    docker_run
    ;;
  build )
    docker_build
    ;;
  clear )
    docker_clear $*
    ;;
  help | usage )
    help_info
    ;;
  *)
    help_info
    ;;
  esac
}

main "$@"
