### 构建PIO

要构建PIO，请解压分发的tar包并执行以下命令：

```bash
CC=mpicc FC=mpif90 ./configure --enable-fortran && make check install
```

要查看所有可用的选项和标志，可以运行：

```bash
./configure --help
```

注意，可能需要设置环境变量`CC`和`FC`为MPI版本的C和Fortran编译器。此外，可能还需要设置`CPPFLAGS`和`LDFLAGS`来指示一个或多个依赖库的位置。（如果使用MPI编译器，所有依赖库都应使用相同的编译器构建。）例如：

```bash
export CC=mpicc
export FC=mpifort
export CPPFLAGS='-I/usr/local/netcdf-fortran-4.4.5_c_4.6.3_mpich-3.2/include -I/usr/local/netcdf-c-4.6.3_hdf5-1.10.5/include -I/usr/local/pnetcdf-1.11.0_shared/include'
export LDFLAGS='-L/usr/local/netcdf-c-4.6.3_hdf5-1.10.5/lib -L/usr/local/pnetcdf-1.11.0_shared/lib'
./configure --prefix=/usr/local/pio-2.4.2 --enable-fortran
make check
make install
```

./configure --prefix=/usr/local/netcdf4-needed --enable-fortran

### 构建PIO C和Fortran库

解压tar包并使用以下命令构建：

```bash
./configure --enable-fortran
make
make check
make install
```

环境变量`CC`和`FC`应设置为MPI C和Fortran编译器。`CPPFLAGS`可以设置为包含netCDF和pnetCDF的头文件的目录列表。`LDFLAGS`可以设置为包含库文件的目录列表。

完整示例：

```bash
export CPPFLAGS='-I/usr/local/pnetcdf-1.11.0_shared/include -I/usr/local/netcdf-c-4.7.0_hdf5-1.10.5_mpich-3.2/include -I/usr/local/netcdf-fortran-4.4.5_c_4.6.3_mpich-3.2/include'
export LDFLAGS='-L/usr/local/pnetcdf-1.11.0_shared/lib  -L/usr/local/netcdf-c-4.7.0_hdf5-1.10.5_mpich-3.2/lib'
export CC=mpicc
export FC=mpifort
export CFLAGS='-g -Wall'
./configure --enable-fortran
make check
make install
```

### 使用MPI进行测试

测试作为一个bash脚本运行，使用`mpiexec`启动程序。如果安装系统无法运行`mpiexec`，可以使用`--disable-test-runs`选项来配置。这将构建测试，但不会运行。测试可以手动运行。

### 可选的GPTL使用

PIO可以选择使用通用目的计时库（GPTL）。这对于性能测试程序`pioperf`是必需的，但对于其余的库和测试是可选的。如果要与GPTL一起构建PIO，请在运行`configure`之前，在`CPPFLAGS/LDFLAGS`中包含其头文件和库目录的路径。

### PIO库日志记录

如果使用`--enable-logging`构建，PIO库将输出日志语句到文件（每个任务一个）和标准输出。使用`PIOc_set_log_level()`函数打开日志记录。启用日志记录会对性能产生负面影响，但有助于调试。

### 使用CMake构建

PIO C和Fortran库也可以使用CMake构建。用户可以选择使用CMake构建系统而非自动工具构建。

#### CMake安装过程

要配置构建，PIO需要CMake版本2.8.12或更高。使用CMake的典型配置如下：

```bash
CC=mpicc FC=mpif90 cmake [-DOPTION1=value1 -DOPTION2=value2 ...] /path/to/pio/source
```

其中`mpicc`和`mpif90`是适用于系统的MPI编译器包装器。

OPTIONS部分通常应包含指向各种依赖项安装位置的指针，假设这些依赖项不位于标准搜索路径中。

对于每个依赖项`XXX`，可以使用CMake变量`XXX_PATH`指定其安装路径。如果C和Fortran库安装在不同的位置（例如NetCDF），则可以分别指定`XXX_C_PATH`和`XXX_Fortran_PATH`。例如，可以使用以下CMake配置行指定NetCDF-C和NetCDF-Fortran以及PnetCDF的位置：

```bash
CC=mpicc FC=mpif90 cmake -DNetCDF_C_PATH=/path/to/netcdf-c \
           -DNetCDF_Fortran_PATH=/usr/local/netcdf4-needed \
           -DPnetCDF_PATH=/path/to/pnetcdf \
          /root/ParallelIO-pio2_6_2
```
CC=mpicc FC=mpifort cmake -DCMAKE_INSTALL_PREFIX=/usr/local/pio -DPIO_ENABLE_TIMING=OFF -DNetCDF_C_PATH=/usr/local/netcdf4-needed \
           -DNetCDF_Fortran_PATH=/usr/local/netcdf4-needed \
           -DPnetCDF_PATH=/usr/local/netcdf4-needed \
           /root/ParallelIO-pio2_6_2
适用于以下依赖项：NetCDF、PnetCDF、HDF5、LIBZ、SZIP。

#### CMake选项

可以在命令行中指定其他配置选项。

- `PIO_ENABLE_TIMING`选项可以设置为`ON`或`OFF`，以启用或禁用在PIO库中使用GPTL计时。如果系统中已经安装了GPTL C库（用于PIO C库）和GPTL Fortran库（包含`perf_mod.mod`和`perf_utils.mod`接口模块），用户可以通过`GPTL_PATH`变量（或分别通过`GPTL_C_PATH`和`GPTL_Fortran_Perf_PATH`变量）指定这些库的位置。如果系统上没有安装这些GPTL库，且无法找到它们，PIO将构建其内部版本的GPTL。

- 如果系统上没有安装PnetCDF，用户可以通过设置`-DWITH_PNETCDF=OFF`来禁用其使用。这将禁用在系统上搜索PnetCDF，并禁用PIO内部对PnetCDF的使用。

- 如果用户希望禁用PIO测试，可以设置变量`-DPIO_ENABLE_TESTS=OFF`。这将完全禁用CTest测试套件，并删除所有测试构建目标。

- 如果您希望将PIO安装到一个安全的位置，以便以后与其他软件一起使用，可以设置`CMAKE_INSTALL_PREFIX`变量以指向所需的安装位置。

#### 使用CMake构建

在成功配置PIO后，可以在构建目录中通过以下命令构建PIO：

```bash
make
```

这将构建`pioc`和`piof`库。

#### 使用CMake进行测试

如果希望进行测试，并且`PIO_ENABLE_TESTS=ON`（默认设置），可以使用以下命令构建测试可执行文件：

```bash
make tests
```

一旦构建了测试，可以使用以下命令运行测试：

```bash
ctest
```

注意：如果在运行`ctest`之前没有运行`make tests`，则会看到所有测试失败。

或者，可以构建测试可执行文件并立即运行测试：

```bash
make check
```
mpiexec --host localhost:4 --allow-run-as-root -n 3 /root/ParallelIO-pio2_5_9/tests/cunit/test_async_mpi
mpiexec --host localhost:4 -n 3 /root/ParallelIO-pio2_6_2/tests/cunit/test_async_mpi

#### 其他注意事项

这些测试是并行运行的。如果您使用的是支持的超级计算平台（如NERSC、NWSC、ALCF等），则`ctest`命令将假设测试将在适当配置和调度的并行作业中运行。可以通过从登录节点请求交互式会话，然后在交互式终端中运行`ctest`来完成此操作。或者，也可以通过作业提交脚本运行`ctest`命令。重要的是要理解，`ctest`本身会将所有测试可执行文件的命令前置为适当的`mpirun/mpiexec/runjob`等。因此，您不应再将这些MPI启动命令前缀添加到`ctest`命令前。

### 安装CMake

一旦成功构建了PIO库，可以通过以下命令将其安装到指定的`CMAKE_INSTALL_PREFIX`位置：

```bash
make install
```

如果构建了内部GPTL库（因为系统中找不到GPTL且`PIO_ENABLE_TIMING`变量设置为`ON`），这些库将与PIO一起安装。

#### CMake构建示例

从构建目录中，使用以下命令构建PIO示例：

```bash
make examples
```

这将构建`examples`子目录中的C和Fortran示例。