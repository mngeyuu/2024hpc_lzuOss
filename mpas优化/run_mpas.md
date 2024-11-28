# 运行 MPAS 非静力大气模型

在生成 CVT 网格并根据第 4 章的相关步骤进行准备后，本章描述运行 MPAS-Atmosphere 模型的两个主要步骤：创建初始条件和运行模型本身。本章中用到了两个 MPAS 核心模块，init atmosphere 和 atmosphere，分别用于初始化和运行非静力大气模型。7.1 和 7.2 节介绍了如何使用 init atmosphere 核心创建理想化和实数据初始条件文件，而 7.3 节描述了运行模型的基本步骤。

本章的每一节遵循编译并执行 MPAS 模型组件的常规模式，不同之处在于所使用的核心模块因应用目的不同而有所区别。编译过程将生成初始化或模型可执行文件，分别命名为 init atmosphere model 和 atmosphere model。通常，使用 mpiexec 或 mpirun 运行可执行文件，例如：
> mpiexec -n 8 atmosphere model

这里的 8 表示将使用的 MPI 任务数。当 n > 1 时，需要存在相应的图分解文件，例如 graph.info.part.8。有关图分解的详细信息，请参阅 4.1 节。

### 7.1 创建理想化初始条件

init atmosphere 初始化核心支持多种理想化测试用例：

1. Jablonowski 和 Williamson 的无初始扰动的斜压波
2. Jablonowski 和 Williamson 的具有初始扰动的斜压波
3. Jablonowski 和 Williamson 的具有正常模式扰动的斜压波
4. 飑线
5. 超级单体
6. 山波

创建理想化初始条件相对简单，不需要外部数据，并且创建初始条件文件（以下称为 init.nc）时起始日期/时间无关紧要。

创建 init.nc 文件的步骤如下：

- 在工作目录中包含包含 CVT 网格的 grid.nc 文件
- 如果使用多个 MPI 任务运行，请在工作目录中包含 graph.info.part.* 文件（见 4.1 节）
- 使用指定的 init atmosphere 核心编译 MPAS（见 3.3 节）
- 编辑 namelist.init atmosphere 配置文件（如下所述）
- 编辑 streams.init atmosphere I/O 配置文件（如下所述）
- 运行 init atmosphere model 以创建初始条件文件 init.nc

生成 init atmosphere model 可执行文件时，将创建默认的 namelist.init atmosphere 文件。许多 namelist.init atmosphere 文件中的参数与创建理想化条件无关，可以忽略或删除。下表列出了必需的 namelist 参数，右侧对某些关键参数进行了注释，所有 namelist 参数的正式说明可在附录 A 中找到。

```
&nhyd_model
  config_init_case = 2      # 对应于本节开始列出的用例中的数字1-6
  config_start_time = '0000-01-01_00:00:00'  # 模拟的起始时间
  config_theta_adv_order = 3   # theta 的对流阶数
  config_coef_3rd_order = 0.25
/
&dimensions
  config_nvertlevels = 26  # 模型中使用的垂直层数
/
&decomposition
  config_block_decomp_file_prefix = 'graph.info.part.'  # 并行运行时需与网格分解文件前缀匹配
/
```

编辑 namelist.init atmosphere 文件后，输入网格文件名称及将创建的初始条件文件名称必须在 XML I/O 配置文件 streams.init atmosphere 中设置。关于 XML I/O 配置文件格式的详细说明，请参见第 5 章。特别是，在“input”流定义中的 filename template 属性必须设置为网格文件名，而在“output”流定义中 filename template 属性必须设置为创建的初始条件文件名。

### 7.2 创建实数据初始条件

生成实数据初始条件的过程与上一节描述的理想化用例类似，但涉及的步骤更多，因为需要插值静态地理数据（如地形、土地覆盖、土壤类型等）、地表场（如土壤温度和 SST）以及特定日期和时间的初始大气条件。静态数据集与 WRF 模型所用数据集相同，地表场和初始大气条件可通过 WRF 预处理系统（WPS）从例如 NCEP 的 GFS 数据中获得。

创建实数据初始条件只需一次 init atmosphere 核心的编译，但实际生成 IC 文件需要运行 init atmosphere model 程序的两个独立步骤，每个步骤分别在以下小节中描述。尽管可以将两个实数据初始化步骤合并为一次运行，但分别运行每一步将有助于提高清晰度，并在生成后续初始条件时节省大量时间，即在使用相同网格但不同起始时间生成初始条件时。

第一步（7.2.1 节）是将静态场插值到网格上以创建 static.nc 文件。此步骤无法并行运行，通常需要较长时间才能完成；不过，由于这些场是静态的，只要针对特定网格运行一次即可，无论最终生成多少个来自 static.nc 输出文件的初始条件文件。7.2.2 节描述了从 7.2.1 节创建的 static.nc 文件开始处理大气初始条件。


### 7.2.1 静态场

生成`static.nc`文件需要一组静态地理数据。可以从WRF模型的[下载页面](http://www2.mmm.ucar.edu/wrf/users/download/get_source.html)获取合适的数据集。这些静态数据文件应下载到一个目录中，并在运行该插值步骤之前在`namelist.init_atmosphere`文件中指定路径。此步骤运行的结果是生成一个NetCDF文件（`static.nc`），将在第7.2.2节中用于创建动态初始条件。请注意，`static.nc`可以生成一次，并随后重复用于不同开始时间的初始条件文件生成。

以下步骤总结了`static.nc`的创建过程：
- 从WRF下载页面下载地理数据（如上所述）。
- 使用指定的`init_atmosphere`核心编译MPAS（参见3.3节）。
- 在工作目录中包含`grid.nc`文件。
- 编辑`namelist.init_atmosphere`配置文件（详见下文）。
- 编辑`streams.init_atmosphere`I/O配置文件（详见下文）。
- 指定一个MPI任务运行`init_atmosphere`模型，以创建`static.nc`。

请注意，在此步骤中，初始化核心必须串行运行；然而，7.2.2节中描述的步骤可以使用多个MPI任务运行。

```plaintext
&nhyd_model
    config_init_case = 7  # 必须为7，即实测数据初始化案例
/
&dimensions  # 目前以下维度应设为1，其值将在§7.2.2中生效
    config_nvertlevels = 1
    config_nsoillevels = 1
    config_nfglevels = 1
    config_nfgsoillevels = 1
/
&data_sources
    config_geog_data_path = '/path/to/WPS_GEOG/'  # 从WRF下载页面获取的静态文件的绝对路径
    config_landuse_data = 'MODIFIED_IGBP_MODIS_NOAH'  # 土地利用数据集选择
    config_topo_data = 'GMTED2010'  # 地形数据集选择
    config_vegfrac_data = 'MODIS'  # 月度植被覆盖率数据集选择
    config_albedo_data = 'MODIS'  # 月度反照率数据集选择
    config_maxsnowalbedo_data = 'MODIS'  # 最大积雪反照率数据集选择
    config_supersample_factor = 1  # MODIS超采样因子，通常只需在网格间距<6km时使用
/
&preproc_stages  # 仅启用静态插值和原生GWD静态阶段
    config_static_interp = true
    config_native_gwd_static = true
    config_vertical_grid = false
    config_met_interp = false
    config_input_sst = false
    config_frac_seaice = false
/
```

在编辑`namelist.init_atmosphere`文件后，必须在XML I/O配置文件`streams.init_atmosphere`中设置输入CVT网格文件名以及要创建的静态文件名。有关XML I/O配置文件格式的详细描述，请参考第5章。具体来说，需在`"input"`流定义中将`filename template`属性设置为SCVT网格文件的名称，在`"output"`流定义中将`filename template`属性设置为要创建的静态文件的名称。

### 7.2.2 垂直网格生成和初始场插值

创建实测数据初始条件文件（`init.nc`）的第二步是生成垂直网格，相关参数将指定在`namelist.init_atmosphere`文件中，并获取初始条件数据并将其插值到模型网格上。前述初始条件可以从多个数据源获得，这里假设使用WPS的“中间”数据文件，通过WPS的`ungrib`程序从GFS数据生成。有关WPS的详细构建和运行说明，以及如何从GFS数据生成中间数据文件，请参阅[WRF用户指南第3章](http://www2.mmm.ucar.edu/wrf/users/docs/user_guide_v4/v4.1/users_guide_chap3.html)。

以下步骤总结了`init.nc`的创建过程：
- 在工作目录中包含WPS中间数据文件。
- 在工作目录中包含`static.nc`文件（见7.2.1节）。
- 如果并行运行，在工作目录中包含`graph.info.part.*`文件（见4.1节）。
- 编辑`namelist.init_atmosphere`配置文件（详见下文）。
- 编辑`streams.init_atmosphere`I/O配置文件（详见下文）。
- 运行`init_atmosphere`模型以创建`init.nc`。

```plaintext
&nhyd_model
    config_init_case = 7  # 必须为7
    config_start_time = '2010-10-23 00:00:00'  # 初始数据的处理时间
    config_theta_adv_order = 3  # theta的对流顺序
    config_coef_3rd_order = 0.25
/
&dimensions
    config_nvertlevels = 55  # MPAS使用的垂直层数
    config_nsoillevels = 4  # MPAS使用的土壤层数
    config_nfglevels = 38  # 中间文件中的垂直层数
    config_nfgsoillevels = 4  # 中间文件中的土壤层数
/
&data_sources
    config_met_prefix = 'FILE'  # 用于初始条件的中间文件前缀
    config_use_spechumd = true  # 如果可用，使用比湿而非相对湿度
/
&vertical_grid
    config_ztop = 30000.0  # 模型顶高度（米）
    config_nsmterrain = 1  # 地形的平滑次数
    config_smooth_surfaces = true  # 是否平滑zeta面
    config_blend_boundary_terrain = false  # 是否在区域边界平滑地形；仅适用于区域模拟，详见第8.2节
/
&preproc_stages
    config_static_interp = false
    config_native_gwd_static = false
    config_vertical_grid = true  # 仅启用这三个阶段
    config_met_interp = true
    config_input_sst = false
    config_frac_seaice = true
/
&decomposition
    config_block_decomp_file_prefix = 'graph.info.part.'  # 如果并行运行，需与网格分解文件前缀匹配
/
```

在编辑`namelist.init_atmosphere`文件后，必须在XML I/O配置文件`streams.init_atmosphere`中设置静态文件名以及要创建的初始条件文件名。

在完成`init.nc`初始条件文件的生成后，就可以着手运行MPAS-Atmosphere模型。以下是运行模型的步骤：

1. 将初始条件文件`init.nc`放入工作目录（详见第7.1节或7.2节）。
2. **可选项**：如果需要定期更新海表温度（SST）和海冰字段，包含`surface.nc`文件（详见第8.1节）。
3. **可选项**：若进行区域模拟，包含LBC边界条件文件（如`lbc.YYYY-MM-DD_HH.mm.ss.nc`，详见第8.2节）。
4. 如果在并行环境下运行，将图形分解文件`graph.info.part.*`放入工作目录（详见第4.1节）。
5. 若上次初始化后未清理MPAS目录，使用`make clean`并指定大气核。
6. 编译MPAS，并指定大气核（详见第3.3节）。
7. 编辑默认的`namelist.atmosphere`配置文件。
8. 编辑`streams.atmosphere` I/O配置文件。
9. 运行大气模型可执行文件。

### `namelist.atmosphere`关键变量说明：

- **模型时间步**：`config_dt`（例如720秒，需根据网格间距适当选择）。
- **开始时间**：`config_start_time`（需与`init.nc`中的时间匹配）。
- **运行时长**：`config_run_duration`（例如'5_00:00:00'表示运行5天）。
- **最小网格间距**：`config_len_disp`（用于计算耗散长度）。
  
如果是冷启动，确保`config_start_time`与`init.nc`生成时的时间一致。

### 区域模拟与重启设置

- **区域模拟**：如运行区域模拟，设置`config_apply_lbcs = true`（详见第8.2节）。
- **重启运行**：若从上次的状态继续运行，设置`config_do_restart = true`，并确保`config_start_time`与重启文件匹配。

### 流配置文件`streams.atmosphere`

MPAS-Atmosphere中的主要流配置有：

- `input`：用于读取冷启动的初始条件。
- `restart`：用于写入和读取模型重启文件。
- `output`：写出模型的预测和诊断数据。
- `diagnostics`：通常以较高频率写出2D诊断数据。
- `surface`：定期读取更新的SST和海冰数据。
- `iau`：用于增量分析更新（IAU）方案。
- `lbc_in`：读取区域模拟的侧边界更新数据。

在运行过程中，可以通过在`restart`流中设置`output_interval`来控制重启文件的写出频率。