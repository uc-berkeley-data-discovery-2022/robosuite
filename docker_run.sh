#!/bin/bash

port_ssh=9922
container=base-gui-gymphysics-310-robosuite
image=pmallozzi/devenvs:base-gui-gymphysics-310-robosuite

my_platform=""
case $(uname -m) in
    x86_64 | i686 | i386) my_platform="linux/amd64" ;;
    arm64)    my_platform="linux/arm64" ;;
esac
echo ${my_platform}

docker pull ${image}


cleanup() {
  echo "Checking if container already exists.."
  if [[ $(docker ps -a --filter="name=$container" --filter "status=running" | grep -w "$container") ]]; then
    docker stop $container
    docker rm $container
    echo "Cleaning up..."
  elif [[ $(docker ps -a --filter="name=$container") ]]; then
    docker rm $container || true
    echo "Cleaning up..."
  else
    echo "No existing container found"
  fi
}

main() {
  repo_dir="$(pwd)"
  mount_local=" -v ${repo_dir}:/root/host"
  port_arg="-p ${port_ssh}:22"

  which docker 2>&1 >/dev/null
  if [ $? -ne 0 ]; then
    echo "Error: the 'docker' command was not found.  Please install docker."
    exit 1
  fi

  cleanup

  case "${1}" in
    bash )
      echo "Entering docker environment..."
      docker run \
        -it \
        --name $container \
        --privileged \
        --workdir /root/host \
        --platform ${my_platform} \
        ${mount_local} \
        $port_arg \
        $image ${1}
      ;;
    * )
      echo "Launching docker environment in background..."
      docker run \
        -d \
        --name $container \
        --privileged \
        --workdir /root/host \
        --platform ${my_platform} \
        ${mount_local} \
        $port_arg \
        $image
      ;;

  esac

}

main "$@"

