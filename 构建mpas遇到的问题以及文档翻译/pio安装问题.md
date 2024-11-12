1. csizeof有问题
```
iompi_mod.F90:273:26:

 
                          1
Error: ‘x’ argument of ‘c_sizeof’ intrinsic at (1) must be an interoperable data entity: Type shall have a character length of 1
```
下载pio 2.x

2. 找不到pnetcdf路径
```
Make Error at clib/CMakeLists.txt:158 (message):
  Must have PnetCDF and/or NetCDF C libraries
```
在makefile里改路径

3. cmake找不到config.h文件 
```
/root/ParallelIO-pio2_6_2/src/clib/pio_file.c:5:10: fatal error: config.h: No such file or directory
 #include <config.h>
          ^~~~~~~~~~
```
cmake路径是本文件夹而不是src

4. 类型不一致
```
/root/ParallelIO-pio2_6_2/tests/performance/pioperformance.F90:574:132:

  574 |        print *,__FILE__,__LINE__,trim(doftype),varsize,minval(compmap),maxval(compmap)
      |                                                                                                                                    1
Error: Line truncated at (1) [-Werror=line-truncation]
/root/ParallelIO-pio2_6_2/tests/performance/pioperformance.F90:574:132:

  574 |        print *,__FILE__,__LINE__,trim(doftype),varsize,minval(compmap),maxval(compmap)
      |                                                                                                                                    1
Error: Syntax error in argument list at (1)
/root/ParallelIO-pio2_6_2/tests/performance/pioperformance.F90:92:17:

   91 |   call MPI_Bcast(decompfile,256*max_decomp_files,MPI_CHARACTER,0, MPI_COMM_WORLD,ierr)
      |                 2
   92 |   call MPI_Bcast(piotypes,4, MPI_INTEGER, 0, MPI_COMM_WORLD,ierr)
      |                 1
Warning: Type mismatch between actual argument at (1) and actual argument at (2) (INTEGER(4)/CHARACTER(*)).
```
最后继续用的pio 1.7版本。其中遇到了没有连接到pnetcdf的问题。make命令时加入export指定路径就好了。

5. 安装pio1.7.1
```
   checking for Fortran flag to compile .F90 files... unknown
configure: error: Fortran could not compile .F90 files
```
```
export FC=mpiifort
```
6. configure: error: cannot find netCDF C library
   
export CPPFLAGS="-I/usr/local/netcdf4-needed/include"

export LDFLAGS="-L/usr/local/netcdf4-needed/lib"

7. configure: error: netcdf.mod not found in NETCDF_PATH/include         check the environment variable NETCDF_PATH

```
export NETCDF_PATH=/usr/local/netcdf4-needed
```
8. gfortran: error: unrecognized command line option ‘-f90’

找到Makefile.conf，修改
```
FC		= mpiifort
MPIFC          = mpif90
FFLAGS		=        -I/usr/local/netcdf4-needed/include 
```

9. 不知道怎么解决啊
```
iompi_mod.F90:273:26:

 
                          1
Error: ‘x’ argument of ‘c_sizeof’ intrinsic at (1) must be an interoperable data entity: Type shall have a character length of 1

```
10. 显示mpi的module找不到

    CC=mpicc FC=mpif90
