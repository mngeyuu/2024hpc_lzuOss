### 构建MPAS
#### 3.1 必要条件
要构建MPAS，必须使用兼容的C和Fortran编译器。此外，MPAS软件依赖于PIO并行I/O库来读取和写入模型字段，而PIO库还需要标准的netCDF库以及来自阿贡国家实验室的parallel-netCDF库。所有库都必须使用将用于构建MPAS的相同编译器进行编译。3.2节总结了安装MPAS所需I/O库的基本过程。

为了使MPAS的makefile能够找到PIO、parallel-netCDF和netCDF的包含文件和库，应该将环境变量PIO、PNETCDF和NETCDF设置为PIO、parallel-netCDF和netCDF安装的根目录。

还需要安装MPI，如MPICH或OpenMPI，并且无法构建MPAS可执行文件的串行版本。MPAS-Atmosphere v5.0引入了使用MPI和OpenMP的混合并行功能；然而，使用OpenMP应该被视为实验性的，通常不会提供性能优势。发布共享内存功能的主要原因是为了让合作开发者未来能够使用此代码。

#### 3.2 编译I/O库
**重要说明**：本节提供的安装库的说明已被MPAS开发人员成功使用，但由于库版本、编译器和系统配置的差异，建议用户在安装过程中遇到问题时参考各库提供商的文档。MPAS开发人员不能对第三方库承担责任。

虽然大多数较新的netCDF和parallel-netCDF库版本应该可以使用，但经过充分测试的版本是netCDF 4.4.x和parallel-netCDF 1.8.x。强烈建议用户使用最新的PIO 2.x版本（可从https://github.com/NCAR/ParallelIO/获取）或PIO版本1.7.1或1.9.23，因为其他版本尚未测试，或已知无法与MPAS一起使用。必须在编译PIO库之前安装netCDF和parallel-netCDF库。

#### 3.2.1 NetCDF
可以从[Unidata网站](http://www.unidata.ucar.edu/downloads/netcdf/index.jsp)下载netCDF 4.4.x版本。该页面提供了详细的netCDF C和Fortran库构建说明；PIO需要C和Fortran接口。如果需要netCDF-4支持，则需要在构建netCDF之前安装zlib和HDF5库。在继续编译PIO之前，应将NETCDF环境变量设置为netCDF根安装目录。

#### 3.2.2 Parallel-NetCDF
可以从[parallel-netCDF的下载页面](https://trac.mcs.anl.gov/projects/parallel-netcdf/wiki/Download)下载parallel-netCDF 1.8.x版本。在继续编译PIO之前，应将PNETCDF环境变量设置为parallel-netCDF根安装目录。

#### 3.2.3 PIO
从MPAS v5.2版本开始，可以使用PIO 1.x或2.x版本的库。这两个主要版本有些不同的API；默认情况下，MPAS构建系统假设使用PIO 1.x API，但可以通过在编译MPAS时添加`USE PIO2=true`选项来使用PIO 2.x版本。对于使用PIO 1.x版本的编译，强烈建议选择PIO 1.7.1或PIO 1.9.23，因为其他1.x版本可能无法正常工作；这两个特定版本可以从[PIO 1.7.1发布页面](https://github.com/NCAR/ParallelIO/releases/tag/pio1_7_1)和[PIO 1.9.23发布页面](https://github.com/NCAR/ParallelIO/releases/tag/pio1_9_23)获取。

PIO 2.x版本支持与GPTL库集成的性能计时；然而，MPAS基础设施目前没有提供调用此库的功能。因此，建议在运行cmake命令以构建PIO 2.x版本时，添加`-DPIO ENABLE TIMING=OFF`选项。

在构建并安装PIO后，应将PIO环境变量设置为PIO安装目录。PIO的最新版本支持指定安装前缀，而一些旧版本则不支持，在这种情况下，PIO环境变量应设置为PIO编译的目录。

### 3.3 编译MPAS

**重要说明**：在编译MPAS之前，必须将NETCDF、PNETCDF和PIO环境变量设置为库的安装目录，具体设置方法见前述章节。MPAS代码仅使用`make`工具进行编译。在构建代码之前，没有单独的配置步骤，所有关于编译器、编译器标志等的信息都包含在顶层的Makefile中；每种支持的编译器组合（即配置）在Makefile中作为一个单独的make目标进行定义，用户通过在命令行中指定构建目标的名称来选择配置，例如：

> make gfortran  
用于使用GNU Fortran和C编译器构建代码。

下表列出了一些可用的目标，更多目标可以通过简单编辑顶层目录中的Makefile来添加。

| 目标       | Fortran编译器   | C编译器       | MPI包装器                |
|------------|-----------------|----------------|--------------------------|
| xlf        | xlf90           | xlc            | mpxlf90 / mpcc           |
| pgi        | pgf90           | pgcc           | mpif90 / mpicc           |
| ifort      | ifort           | gcc            | mpif90 / mpicc           |
| gfortran   | gfortran        | gcc            | mpif90 / mpicc           |
| llvm       | flang           | clang          | mpifort / mpicc          |
| bluegene   | bgxlf95         | r bgxlc r      | mpxlf95 r / mpxlc r      |

MPAS框架支持多个核心——目前包括浅水模型、海洋模型、陆冰模型、非静力大气模型和非静力大气初始化核心——因此，构建过程必须指定要构建的核心。可以通过设置`CORE`环境变量为要构建的模型核心名称，或通过在命令行中明确指定要构建的核心来完成此操作。例如，对于大气核心，可以运行：

> setenv CORE atmosphere  
> make gfortran  

或：

> make gfortran CORE=atmosphere

如果设置了`CORE`环境变量并且在命令行中也指定了核心，命令行的值优先；如果没有指定核心，无论是在命令行中还是通过`CORE`环境变量，构建过程会停止并显示错误消息。假设编译成功，名为`${CORE} model`（例如，`atmosphere model`）的模型可执行文件应在顶层MPAS目录中创建。

要查看可用的核心，可以简单地运行顶层Makefile，而不设置`CORE`环境变量或通过命令行传递核心。例如，输出如下：

> make  
（make错误）  
make[1]: 进入目录 ‘/scratch/MPAS-Release’  
用法：make target CORE=[core] [options]  
示例目标：  
ifort  
gfortran  
xlf  
pgi  
可用的核心：  
atmosphere  
init_atmosphere  
landice  
ocean  
seaice  
sw  
test  
可用选项：  
DEBUG=true - 构建调试版本，默认是优化版本。  
USE_PAPI=true - 构建版本使用PAPI计时器，默认关闭。  
TAU=true - 使用TAU钩子进行性能分析，默认关闭。  
AUTOCLEAN=true - 强制在构建新核心之前清理基础设施。  
GEN_F90=true - 通过CPP生成中间的.f90文件并进行构建。  
TIMER_LIB=opt - 选择用于性能分析的计时器库接口。选项有：  
TIMER_LIB=native - 使用MPAS内置的本地计时器。  
TIMER_LIB=gptl - 使用gptl代替本地计时器接口。  
TIMER_LIB=tau - 使用TAU代替本地计时器接口。  
OPENMP=true - 构建并链接OpenMP标志，默认不使用OpenMP。  
USE_PIO2=true - 链接PIO 2库，默认使用PIO 1.x库。  
PRECISION=single - 使用单精度浮点数构建，默认使用双精度。

确保NETCDF、PNETCDF、PIO和PAPI（如果`USE_PAPI=true`）的环境变量指向库的绝对路径。

**错误**：没有指定CORE。退出。

### 3.4 选择单精度构建
从版本2.0开始，MPAS-Atmosphere可以以单精度编译和运行，提供更快的模型执行速度和更小的输入输出文件。从版本5.0开始，可以通过命令行选择模型的精度，而不需要编辑Makefile。要编译一个单精度的MPAS-Atmosphere可执行文件，请在构建命令中添加`PRECISION=single`，例如：

> make gfortran CORE=atmosphere PRECISION=single

无论MPAS-Atmosphere的`init_atmosphere`和`atmosphere`核心是用单精度还是双精度编译的，都可以使用单精度或双精度的输入文件。一般来说，MPAS框架应正确检测输入文件的精度，但也可以通过在输入流中添加`precision`属性来明确指定文件的精度，详细信息见第5.2节。

### 3.5 清理
要删除构建过程中创建的所有文件，包括模型可执行文件，可以运行`make clean`命令：

> make clean

与编译一样，指定要清理的核心，可以通过`CORE`环境变量，或通过在命令行中指定核心来完成，`CORE=`。