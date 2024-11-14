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

5. Failed to compile a PIO test program
Please ensure the PIO environment variable is set to the PIO installation directory

mpifort -I/usr/local/pio/include pio2.f90 -o pio2.out

************ ERROR ************
Failed to compile a PIO test program
Please ensure the PIO environment variable is set to the PIO installation directory
************ ERROR ************ 为什么我单独跑测试文件可以 但用makefie就失败

mpifort pio2.f90 -I/usr/local/pio/include -I/usr/local/netcdf4-needed/include -I/usr/local/netcdf4-needed/include -O3 -m64 -ffree-line-length-none -fconvert=big-endian -ffree-form -O3 -m64 -ffree-line-length-none -fconvert=big-endian -ffree-form -O3 -m64 -L/usr/local/pio/lib -lpio -lpiof -lpioc -L/usr/local/netcdf4-needed/lib -lnetcdff -lnetcf -L/usr/local/netcdf4-needed/lib -lpnetcdf -o pio2.out

```
program pio2
  use pio
  integer, parameter :: MPAS_IO_OFFSET_KIND = PIO_OFFSET_KIND
  integer, parameter :: MPAS_INT_FILLVAL = PIO_FILL_INT
end program

```t$(FC) pio2.f90 $(FCINCLUDES) $(FFLAGS) $(LDFLAGS) $(LIBS) -o pio2.out

mpifort pio2.f90 -I/usr/local/pio/include -I/usr/local/netcdf4-needed/include -I/usr/local/netcdf4-needed/include -O3 -m64 -ffree-line-length-none -fconvert=big-endian -ffree-form -O3 -m64 -ffree-line-length-none -fconvert=big-endian -ffree-form -O3 -m64 -L/usr/local/pio/lib -lpio -lpiof -lpioc -L/usr/local/netcdf4-needed/lib -lnetcdff -lnetcdf -L/usr/local/netcdf4-needed/lib -lpnetcdf -o pio2.out

在makefile里删除-lpio

6. [root@mpas MPAS-A_benchmark_120km_v7.0]# ./atmosphere_model
-bash: ./atmosphere_model: Permission denied


