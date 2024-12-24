#!/bin/bash

# 设置路径变量
MPI_INSTALL_DIR="/usr/local/mpich"
NETCDF_INSTALL_DIR="/usr/local/netcdf4-needed"
PIO_INSTALL_DIR="/usr/local/pio"

# 安装 MPICH
tar xzvf mpich-4.2.3.tar.gz
cd mpich-4.2.3
./configure --prefix=$MPI_INSTALL_DIR
make -j$(nproc) && make install
cd ..
rm -rf mpich-4.2.3

# 配置环境变量
if ! grep -q "export MPI_ROOT=" ~/.bashrc; then
    echo "export MPI_ROOT=$MPI_INSTALL_DIR" >> ~/.bashrc
    echo "export PATH=\$MPI_ROOT/bin:\$PATH" >> ~/.bashrc
    echo "export MANPATH=\$MPI_ROOT/man:\$MANPATH" >> ~/.bashrc
fi
source ~/.bashrc

export CC=mpicc
export FC=mpifort

# 安装 ZLIB
tar xzvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
CC=mpicc FC=mpifort ./configure --prefix=$NETCDF_INSTALL_DIR
make -j$(nproc) && make install
cd ..
rm -rf zlib-1.2.11

# 安装 HDF5
tar xzvf hdf5_1.14.5.tar.gz
cd hdf5-hdf5_1_14_5
CC=mpicc FC=mpifort ./configure --with-zlib=$NETCDF_INSTALL_DIR --prefix=$NETCDF_INSTALL_DIR --enable-fortran --enable-cxx
make -j$(nproc) && make install
cd ..
rm -rf hdf5-hdf5_1_14_5

# 安装 NetCDF-C
tar xzvf netcdf-c-4.4.1.tar.gz
cd netcdf-c-4.4.1
CPPFLAGS=-I$NETCDF_INSTALL_DIR/include LDFLAGS=-L$NETCDF_INSTALL_DIR/lib ./configure --prefix=$NETCDF_INSTALL_DIR --disable-dap
make -j$(nproc) && make install
cd ..
rm -rf netcdf-c-4.4.1

# 安装 NetCDF-Fortran
tar xzvf netcdf-fortran-4.4.1.tar.gz
cd netcdf-fortran-4.4.1
CPPFLAGS=-I$NETCDF_INSTALL_DIR/include LDFLAGS=-L$NETCDF_INSTALL_DIR/lib ./configure --prefix=$NETCDF_INSTALL_DIR
make -j$(nproc) && make install
cd ..
rm -rf netcdf-fortran-4.4.1

# 安装 Parallel NetCDF
tar xzvf parallel-netcdf-1.8.1.tar.gz
cd parallel-netcdf-1.8.1
CC=mpicc FC=mpifort CPPFLAGS=-I$NETCDF_INSTALL_DIR/include LDFLAGS=-L$NETCDF_INSTALL_DIR/lib ./configure \
    --prefix=$NETCDF_INSTALL_DIR \
    --with-mpi=$MPI_INSTALL_DIR \
    --with-netcdf=$NETCDF_INSTALL_DIR
make -j$(nproc) && make install
cd ..
rm -rf parallel-netcdf-1.8.1

# 安装 ParallelIO
tar xzvf ParallelIO-pio2_6_2.tar.gz
cd ParallelIO-pio2_6_2
CC=mpicc FC=mpifort cmake -DCMAKE_INSTALL_PREFIX=$PIO_INSTALL_DIR \
    -DPIO_ENABLE_TIMING=OFF \
    -DNetCDF_C_PATH=$NETCDF_INSTALL_DIR \
    -DNetCDF_Fortran_PATH=$NETCDF_INSTALL_DIR \
    -DPnetCDF_PATH=$NETCDF_INSTALL_DIR \
    .
make -j$(nproc) && make install
cd ..
rm -rf ParallelIO-pio2_6_2

# 配置环境变量
if ! grep -q "export NETCDF=" ~/.bashrc; then
    echo "export NETCDF=$NETCDF_INSTALL_DIR" >> ~/.bashrc
    echo "export PATH=\$NETCDF/bin:\$PATH" >> ~/.bashrc
    echo "export LD_LIBRARY_PATH=\$NETCDF/lib:\$LD_LIBRARY_PATH" >> ~/.bashrc
    echo "export CPPFLAGS='-I\$NETCDF/include'" >> ~/.bashrc
    echo "export LDFLAGS='-L\$NETCDF/lib'" >> ~/.bashrc
fi

if ! grep -q "export PIO=" ~/.bashrc; then
    echo "export PIO=$PIO_INSTALL_DIR" >> ~/.bashrc
fi

source ~/.bashrc
