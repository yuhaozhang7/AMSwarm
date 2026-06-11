FROM ros:noetic-ros-base

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=yuhao
ARG USER_UID=1000
ARG USER_GID=1000

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# AMSwarm is a ROS 1/catkin package tested on Melodic/Noetic.  The source
# depends on roscpp/roslib, Eigen, yaml-cpp, eigen-quadprog, OpenMP, pthreads,
# and Python packages used by the visualization scripts.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    gfortran \
    libeigen3-dev \
    libgomp1 \
    libyaml-cpp-dev \
    python3-catkin-tools \
    python3-matplotlib \
    python3-numpy \
    python3-pip \
    python3-rosdep \
    python3-rospkg \
    python3-tk \
    python3-yaml \
    ros-noetic-roscpp \
    ros-noetic-roslib \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir "cmake>=3.20,<4"

# The upstream README asks for this symlink, and main_acado_nav.cpp includes
# <Eigen/Dense> directly.
RUN ln -sfn /usr/include/eigen3/Eigen /usr/include/Eigen

# eigen-quadprog is not a standard Ubuntu package in the ROS Noetic base image.
# Installing from the upstream CMake project provides the headers, library, and
# CMake config consumed by find_package(eigen-quadprog).
RUN git clone --depth 1 --recurse-submodules --shallow-submodules \
        https://github.com/jrl-umi3218/eigen-quadprog.git /tmp/eigen-quadprog \
    && cmake -S /tmp/eigen-quadprog -B /tmp/eigen-quadprog/build \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build /tmp/eigen-quadprog/build --parallel "$(nproc)" \
    && cmake --install /tmp/eigen-quadprog/build \
    && ldconfig \
    && rm -rf /tmp/eigen-quadprog

# Match the usual host user so bind-mounted catkin build/devel files are not
# created as root-owned files on the host.
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" \
    && mkdir -p /catkin_ws/src \
    && chown -R "${USERNAME}:${USERNAME}" /catkin_ws

USER ${USERNAME}
WORKDIR /catkin_ws

RUN echo "source /opt/ros/noetic/setup.bash" >> "/home/${USERNAME}/.bashrc" \
    && echo 'if [ -f /catkin_ws/devel/setup.bash ]; then source /catkin_ws/devel/setup.bash; fi' >> "/home/${USERNAME}/.bashrc"

CMD ["bash"]
