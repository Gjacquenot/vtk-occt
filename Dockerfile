FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    libfontconfig1-dev \
    libgl1-mesa-dev \
    libx11-dev \
    libxi-dev \
    libxmu-dev \
    libxt-dev \
    libfreetype6-dev \
    libtbb-dev \
    libeigen3-dev \
    make \
    ninja-build \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt

########################################
# Build VTK (without rendering)
########################################
ARG VTK_VERSION=v9.4.2

RUN git clone --branch ${VTK_VERSION} https://gitlab.kitware.com/vtk/vtk.git /opt/vtk_src \
 && mkdir -p /opt/vtk_src/build && cd /opt/vtk_src/build && \
    cmake -G Ninja ../ \
      -D CMAKE_BUILD_TYPE=Release \
      -D CMAKE_INSTALL_PREFIX=/opt/vtk \
      -D VTK_BUILD_ALL_MODULES=OFF \
      -D VTK_GROUP_ENABLE_Rendering=DONT_WANT \
      -D VTK_GROUP_ENABLE_StandAlone=YES \
      -D VTK_GROUP_ENABLE_Imaging=YES \
      -D BUILD_DOCUMENTATION:BOOL=NO \
      -D BUILD_EXAMPLES:BOOL=NO \
      -D BUILD_TESTING:BOOL=NO \
      -D BUILD_SHARED_LIBS:BOOL=NO \
      -D VTK_USE_X:BOOL=NO \
      -D VTK_Group_MPI:BOOL=NO \
      -D CMAKE_C_FLAGS="-fPIC" \
      -D CMAKE_CXX_FLAGS="-fPIC" \
    && ninja install \
    && rm -rf /opt/vtk_src

ENV VTK_DIR=/opt/vtk/lib/cmake/vtk-9.4

########################################
# Build OpenCASCADE (OCCT)
########################################
ARG OCCT_VERSION=V7_9_0

RUN git clone --depth 1 --branch ${OCCT_VERSION} https://github.com/Open-Cascade-SAS/OCCT.git /opt/occt_src
RUN mkdir -p /opt/occt_src/build && cd /opt/occt_src/build && \
    cmake -G Ninja ../ \
      -D CMAKE_BUILD_TYPE=Release \
      -D INSTALL_DIR=/opt/occt \
      -D BUILD_MODULE_Draw=OFF \
      -D BUILD_LIBRARY_TYPE=Shared \
      -D USE_TBB=ON \
      -D 3RDPARTY_TBB_INCLUDE_DIR=/usr/include \
      -D 3RDPARTY_TBB_LIBRARY_DIR=/usr/lib/x86_64-linux-gnu \
      -D 3RDPARTY_TBBMALLOC_LIBRARY=/usr/lib/x86_64-linux-gnu/libtbbmalloc.so \
      -D 3RDPARTY_TBBMALLOC_PROXY_LIBRARY=/usr/lib/x86_64-linux-gnu/libtbbmalloc_proxy.so \
      -D USE_EIGEN=ON \
      -D USE_FREEIMAGE=OFF \
      -D USE_VTK=OFF \
    && ninja install \
    && rm -rf /opt/occt_src

ENV OpenCASCADE_DIR=/opt/occt

########################################
# Setup user and entry
########################################
WORKDIR /workspace
CMD ["/bin/bash"]
