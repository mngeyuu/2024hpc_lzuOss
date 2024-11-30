## 1.2 编译mpas
编译 MPAS 的 init_atmosphere 和 atmosphere 核心模块  
如课程中所述，需要从相同的 MPAS 源代码中编译两个“核心”模块：init_atmosphere 核心和 atmosphere 核心。

在开始编译过程之前，建议确认我们路径中包含 MPI 编译器包装程序，并且指向 Parallel-NetCDF 库的环境变量已设置：

```bash
which mpif90
/glade/u/apps/ch/opt/ncarcompilers/0.5.0/gnu/10.1.0/mpi/mpif90

which mpicc
/glade/u/apps/ch/opt/ncarcompilers/0.5.0/gnu/10.1.0/mpi/mpicc

echo $PNETCDF
/glade/u/apps/ch/opt/pnetcdf/1.12.2/mpt/2.25/gnu/10.1.0/
```

如果以上命令均成功，则我们的 shell 环境应足以支持 MPAS 核心的编译。

我们将首先编译 init_atmosphere 核心，生成一个名为 init_atmosphere_model 的可执行文件。

**重要说明**：在 Cheyenne 上编译时，有一点非常重要！为了避免因编译进程饱和 Cheyenne 登录节点并对其他用户产生负面影响，我们将在批处理节点上使用特殊的 `qcmd` 命令运行编译命令。`qcmd` 命令将在批处理节点上启动指定命令，并在命令完成时返回。因此，虽然在其他系统上编译 MPAS 时通常不使用 `qcmd`，但在本教程中，我们会在编译命令前加上 `qcmd -A UMMM0004 --`（其中 UMMM0004 是我们工作的计算项目）。

切换到 MPAS-Model 目录：

```bash
cd MPAS-Model
```

然后我们可以使用 gfortran 编译器发出以下命令来构建 init_atmosphere 核心：

```bash
qcmd -A UMMM0004 -- make -j4 gfortran CORE=init_atmosphere PRECISION=single
```

请注意在编译命令中包含了 `PRECISION=single`；默认情况下，MPAS 核心会以双精度编译，但单精度可执行文件消耗更少的内存，生成的输出文件更小，运行速度更快，并且对于 MPAS-Atmosphere 而言，单精度的结果与双精度结果几乎没有差别。

在构建命令中，我们还添加了 `-j4` 标志，以指示 `make` 使用四个任务来构建代码；这应该会显著减少编译 init_atmosphere_model 可执行文件的时间！

在上面的 make 命令执行后，编译应仅需几分钟。如果编译成功，构建过程的末尾应生成类似以下的消息：

```plaintext
*******************************************************************************
MPAS was built with default single-precision reals.
Debugging is off.
Parallel version is on.
Papi libraries are off.
TAU Hooks are off.
MPAS was built without OpenMP support.
MPAS was built with .F files.
The native timer interface is being used
Using the SMIOL library.
*******************************************************************************
```

如果 init_atmosphere 核心的编译成功，我们应会看到一个名为 init_atmosphere_model 的可执行文件：

```bash
ls -l
total 2006
drwxr-xr-x  2 duda ncar    4096 Apr 26 20:32 default_inputs
-rwxr-xr-x  1 duda ncar 2014592 Apr 26 20:32 init_atmosphere_model
-rw-r--r--  1 duda ncar    3131 Apr 26 20:26 INSTALL
-rw-r--r--  1 duda ncar    2311 Apr 26 20:26 LICENSE
-rw-r--r--  1 duda ncar   27864 Apr 26 20:26 Makefile
-rw-r--r--  1 duda ncar    1379 Apr 26 20:32 namelist.init_atmosphere
-rw-r--r--  1 duda ncar    2555 Apr 26 20:26 README.md
drwxr-xr-x 14 duda ncar    4096 Apr 26 20:32 src
-rw-r--r--  1 duda ncar     920 Apr 26 20:32 streams.init_atmosphere
drwxr-xr-x  4 duda ncar    4096 Apr 26 20:26 testing_and_setup
```

注意，init_atmosphere 核心的默认 namelist 和 streams 文件也在编译过程中生成了，这些文件分别是 `namelist.init_atmosphere` 和 `streams.init_atmosphere`。

现在，我们准备编译 atmosphere 核心。如果不清理任何共享基础代码的情况下尝试：

```bash
make gfortran CORE=atmosphere PRECISION=single
```

会出现以下错误：

```plaintext
*******************************************************************************
 The MPAS infrastructure is currently built for the init_atmosphere_model core.
 Before building the atmosphere core, please do one of the following.


 To remove the init_atmosphere_model_model executable and clean the MPAS infrastructure, run:
      make clean CORE=init_atmosphere_model

 To preserve all executables except atmosphere_model and clean the MPAS infrastructure, run:
      make clean CORE=atmosphere

 Alternatively, AUTOCLEAN=true can be appended to the make command to force a clean,
 build a new atmosphere_model executable, and preserve all other executables.

*******************************************************************************
```

在编译一个 MPAS 核心后，我们需要清理共享基础设施，才能编译不同的核心。可以通过以下命令清理 atmosphere 核心所需的基础设施：

```bash
make clean CORE=atmosphere
```

**重要说明**：由于我们是在 Cheyenne 的批处理节点上进行编译，而批处理节点没有网络访问权限，因此在 Cheyenne 上使用 `qcmd` 编译时需要手动获取物理方案使用的查找表。一般来说，在登录节点上编译时不需要这一步。

在使用 `qcmd` 在批处理节点上启动模型编译之前，可以从 MPAS-Model 顶层目录中手动获取物理查找表，方法如下：

```bash
cd src/core_atmosphere/physics
./checkout_data_files.sh
cd ../../..
```

获取物理查找表后，可以继续使用以下命令编译单精度的 atmosphere 核心：

```bash
qcmd -A UMMM0004 -- make -j4 gfortran CORE=atmosphere PRECISION=single
```

atmosphere_model 可执行文件的编译可能需要几分钟或更长时间才能完成（取决于使用的编译器）。与 init_atmosphere 核心的编译类似，成功编译 atmosphere 核心应显示以下消息：

```plaintext
*******************************************************************************
MPAS was built with default single-precision reals.
Debugging is off.
Parallel version is on.
Papi libraries are off.
TAU Hooks are off.
MPAS was built without OpenMP support.
MPAS was built with .F files.
The native timer interface is being used
Using the SMIOL library.
*******************************************************************************
```

现在，MPAS-Model 目录中应包含一个名为 atmosphere_model 的可执行文件，以及默认的 `namelist.atmosphere` 和 `streams.atmosphere` 文件：
```bash
ls -lL
total 33018
-rwxr-xr-x  1 duda ncar  5644864 Apr 26 20:37 atmosphere_model
-rwxr-xr-x  1 duda ncar   209256 Apr 26 20:36 build_tables
-rw-r--r--  1 duda ncar 20580056 Apr 26 20:34 CAM_ABS_DATA.DBL
-rw-r--r--  1 duda ncar    18208 Apr 26 20:34 CAM_AEROPT_DATA.DBL
drwxr-xr-x  2 duda ncar     4096 Apr 26 20:37 default_inputs
-rw-r--r--  1 duda ncar      261 Apr 26 20:34 GENPARM.TBL
-rwxr-xr-x  1 duda ncar  2014592 Apr 26 20:32 init_atmosphere_model
-rw-r--r--  1 duda ncar     3131 Apr 26 20:26 INSTALL
-rw-r--r--  1 duda ncar    29820 Apr 26 20:34 LANDUSE.TBL
-rw-r--r--  1 duda ncar     2311 Apr 26 20:26 LICENSE
-rw-r--r--  1 duda ncar    27864 Apr 26 20:26 Makefile
-rw-r--r--  1 duda ncar     1774 Apr 26 20:37 namelist.atmosphere
-rw-r--r--  1 duda ncar     1379 Apr 26 20:32 namelist.init_atmosphere
-rw-r--r--  1 duda ncar   543744 Apr 26 20:34 OZONE_DAT.TBL
-rw-r--r--  1 duda ncar     2555 Apr 26 20:26 README.md
-rw-r--r--  1 duda ncar     2240 Apr 26 20:37 streams.atmosphere
-rw-r--r--  1 duda ncar      920 Apr 26 20:32 streams.init_atmosphere
```


## 1.3 静态地表场处理
这个教程帮助你在 240 公里分辨率的准均匀网格上运行 MPAS 大气模型的静态数据处理。以下是各个步骤的总结，帮助你在系统上设置环境并执行必要的命令。

### 1. 创建工作目录
在 MPAS 项目根目录下创建一个新的子目录，以区分不同分辨率的模拟数据：
```bash
cd /glade/scratch/${USER}/mpas_tutorial
mkdir 240km_uniform
cd 240km_uniform
```

### 2. 链接网格文件
将 240 公里准均匀网格文件以符号链接的方式加入到当前目录：
```bash
ln -s /glade/p/mmm/wmr/mpas_tutorial/meshes/x1.10242.grid.nc .
```

### 3. 获取必要的可执行文件和配置文件
需要链接 `init_atmosphere_model` 可执行文件，并复制 `namelist.init_atmosphere` 和 `streams.init_atmosphere` 文件，因为稍后需要修改它们：
```bash
ln -s /glade/scratch/${USER}/mpas_tutorial/MPAS-Model/init_atmosphere_model .
cp /glade/scratch/${USER}/mpas_tutorial/MPAS-Model/namelist.init_atmosphere .
cp /glade/scratch/${USER}/mpas_tutorial/MPAS-Model/streams.init_atmosphere .
```

### 4. 编辑 `namelist.init_atmosphere` 文件
使用你喜欢的编辑器打开 `namelist.init_atmosphere` 文件，并修改指定选项以匹配以下配置：

```plaintext
&nhyd_model
    config_init_case = 7
/
&data_sources
    config_geog_data_path = '/glade/p/mmm/wmr/mpas_tutorial/mpas_static/'
    config_landuse_data = 'MODIFIED_IGBP_MODIS_NOAH'
    config_topo_data = 'GMTED2010'
    config_vegfrac_data = 'MODIS'
    config_albedo_data = 'MODIS'
    config_maxsnowalbedo_data = 'MODIS'
    config_supersample_factor = 3
/
&preproc_stages
    config_static_interp = true
    config_native_gwd_static = true
    config_vertical_grid = false
    config_met_interp = false
    config_input_sst = false
    config_frac_seaice = false
/
```

注意地理数据集路径的设置，以及仅启用静态数据和重力波拖曳（gwd）静态字段处理的设置。

### 5. 编辑 `streams.init_atmosphere` 文件
在 `streams.init_atmosphere` 文件中，将输入网格文件和输出静态文件的文件名配置如下：

```xml
<immutable_stream name="input"
                  type="input"
                  filename_template="x1.10242.grid.nc"
                  input_interval="initial_only"/>

<immutable_stream name="output"
                  type="output"
                  filename_template="x1.10242.static.nc"
                  packages="initial_conds"
                  output_interval="initial_only" />
```

注意不要删除 `surface` 或 `lbc` 流，否则 `init_atmosphere_model` 程序会报错。

### 6. 提交任务以运行初始化程序
复制预设的作业脚本并提交：

```bash
cp /glade/p/mmm/wmr/mpas_tutorial/job_scripts/init_real.pbs .
qsub init_real.pbs
```

### 7. 检查任务状态
可以通过以下命令每分钟检查一次任务状态：
```bash
qstat -u $USER
```

### 8. 查看程序输出
任务运行后，通过以下命令查看日志文件内容以跟踪进度：

```bash
tail -f log.init_atmosphere.0000.out
```

如果每隔几秒都会输出新行，则处理正在进行中，可以按 `CTRL-C` 退出 `tail` 命令。如果没有输出，请检查 `log.init_atmosphere.0000.err` 文件以找出问题原因。

**重要提示**：此步骤的成功执行是后续教程练习的前提。

## 进行理想化模拟初始化

在 `240km_uniform` 目录下运行 `init_atmosphere_model` 程序处理静态、时间不变的场数据时，我们可以尝试在一个单独的目录中初始化并运行一个理想化模拟。

`init_atmosphere_model` 程序支持为以下几种理想化案例创建初始条件：

- 球面上的三维斜压波
- 双周期笛卡尔平面上的三维超级单体雷暴
- xz平面上的二维山波

对于这些理想化案例，都有现成的输入文件可用，文件可以从 MPAS-Atmosphere 下载页面获取。我们将逐步创建超级单体案例的初始条件；其他两个案例的过程类似。

#### 1. 下载理想化案例输入文件

准备好的 MPAS-Atmosphere 理想化案例输入文件可以通过访问 MPAS 官网，并点击左侧的“MPAS-Atmosphere 下载”链接来找到。接着，点击“理想化测试案例配置”链接，您将看到各个理想化案例的下载链接。

虽然可以通过网页下载这些输入文件，但我们也可以直接使用 `wget` 下载文件，例如：下载超级单体的输入文件，步骤如下：

```bash
cd /glade/scratch/${USER}/mpas_tutorial
wget http://www2.mmm.ucar.edu/projects/mpas/test_cases/v7.0/supercell.tar.gz
tar xzvf supercell.tar.gz
```

解压后，进入超级单体目录，`README` 文件将提供初始化和运行测试案例的概述。关键步骤是我们需要将 `init_atmosphere_model` 和 `atmosphere_model` 可执行文件符号链接到超级单体目录：

```bash
ln -s /glade/scratch/${USER}/mpas_tutorial/MPAS-Model/init_atmosphere_model .
ln -s /glade/scratch/${USER}/mpas_tutorial/MPAS-Model/atmosphere_model .
```

#### 2. 通过 `qcmd` 运行初始化程序

与 `README` 文件中描述的方法不同，我们不会直接在命令行运行 `init_atmosphere_model` 和 `atmosphere_model` 程序，而是通过 `qcmd` 提交任务：

```bash
qcmd -A UMMM0004 -- ./init_atmosphere_model
```

#### 3. 检查初始化过程是否有错误

一旦初始条件创建完毕，检查是否有错误非常重要。可以查看 `log.init_atmosphere.0000.out` 文件的末尾，确认是否存在错误信息。文件末尾应该类似于以下内容：

```plaintext
 -----------------------------------------
 Total log messages printed:
    Output messages =                  304
    Warning messages =                  13
    Error messages =                     0
    Critical error messages =            0
 -----------------------------------------
```

如果没有错误，说明初始条件创建成功。

#### 4. 提交模拟任务

初始条件创建完成后，我们可以使用 32 个处理器运行模拟。首先，将准备好的作业脚本复制到工作目录中，并通过 `qsub` 提交作业：

```bash
cp /glade/p/mmm/wmr/mpas_tutorial/job_scripts/supercell.pbs .
qsub supercell.pbs
```

#### 5. 检查作业状态

与静态场插值类似，我们需要等待作业开始运行。每隔一分钟可以使用 `qstat` 命令查看作业的状态：

```bash
qstat -u $USER
```

当看到作业正在运行时，就可以继续执行下一步。模拟运行大约需要 10 分钟，使用 32 个 MPI 任务。

#### 6. 查看模拟结果

在后续的实际操作中，如果你想回顾模拟结果，可以使用 `supercell.ncl` NCL 脚本生成时间演化的模型场数据图：

```bash
ncl supercell.ncl
```

这样，你就完成了理想化超级单体雷暴案例的初始化与模拟运行过程。