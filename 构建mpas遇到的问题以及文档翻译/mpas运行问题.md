1. benchmark数据集格式不对 
```
At line 343 of file mpas_atmphys_lsm_noahinit.F (unit = 3, file = 'VEGPARM.TBL')
Fortran runtime error: Bad integer for item 1 in list input
```
7.x的benchmark数据集只能在mpas7.x的模型上跑。。

2. Ensure that NETCDF, PNETCDF, PIO, and PAPI (if USE_PAPI=true) are environment variablesthat point to the absolute paths for the libraries.
    
```
make -j4 gfortran CORE=init_atmosphere PRECISION=single VERBOSE=1 NETCDF=$NETCDF PNETCDF=$PNETCDF PIO=$PIO AUTOCLEAN=true

```


3. 编译mpas7.0
```
Failed to compile a PIO test program
Please ensure the PIO environment variable is set to the PIO installation directory
```
pio1.7的lib库只有一个.a文件，是我的pio下载不对吗

初步想编译一个pio_test

重新下了pio 2.x
4. piolib没找到定义
```
 mpas_io.F:(.text+0x1604f): undefined reference to `__piolib_mod_MOD_seterrorhandlingiosystem'
collect2: error: ld returned 1 exit status
```
