# netcdf-c的configure

1. configure: error: Can't find or link to the z library. Turn off netCDF-4 and      opendap with --disable-netcdf-4 --disable-dap, or see config.log for errors.
   
   ```
   sudo yum install zlib-devel
   ```

2. configure: error: Can't find or link to the hdf5 library. Use --disable-netcdf-4, or see config.log for errors.
   
重新安装hdf5

3. cc1: warning: /root/hdf5/include: No such file or directory [-Wmissing-include-dirs]
```
echo $CPPFLAGS
echo $CFLAGS
export CPPFLAGS=""
export CFLAGS=""
```

4. 
```
iompi_mod.F90:273:26:

 
                          1
Error: ‘x’ argument of ‘c_sizeof’ intrinsic at (1) must be an interoperable data entity: Type shall have a character length of 1
```

下载pio 2.x

5. 
```
   CMake Error at clib/CMakeLists.txt:158 (message):
  Must have PnetCDF and/or NetCDF C libraries
```
在makefile里改路径

6. 
```
/root/ParallelIO-pio2_6_2/src/clib/pio_file.c:5:10: fatal error: config.h: No such file or directory
 #include <config.h>
          ^~~~~~~~~~
```
cmake路径是本文件夹而不是src

7.
 
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

```
make gfortran make LDFLAGS="-L$PNETCDF/lib -lpnetcdf" CORE=atmosphere PRECISION=single  AUTOCLEAN=true 
```

8. 
```
ERROR:root:Failed with output:
    error: RPC failed; curl 7 Failed to connect to github.com port 443: Connection timed out
    fatal: the remote end hung up unexpectedly

ERROR: In directory
    /root/MPAS-Model-8.2.2/src/core_atmosphere/physics
Process did not run successfully; returned status 128:
    git clone --quiet https://github.com/NCAR/MMM-physics.git /root/MPAS-Model-8.2.2/src/core_atmosphere/physics/physics_mmm
See above for output from failed command.

ERROR:root:Failed with output:
    error: RPC failed; curl 7 Failed to connect to github.com port 443: Connection timed out
    fatal: the remote end hung up unexpectedly

ERROR: In directory
    /root/MPAS-Model-8.2.2/src/core_atmosphere/physics
Process did not run successfully; returned status 128:
    git clone --quiet https://github.com/NCAR/MMM-physics.git /root/MPAS-Model-8.2.2/src/core_atmosphere/physics/physics_mmm
See above for output from failed command.


ERROR: Failed with output:
    error: RPC failed; curl 7 Failed to connect to github.com port 443: Connection timed out
    fatal: the remote end hung up unexpectedly

ERROR: In directory
    /root/MPAS-Model-8.2.2/src/core_atmosphere/physics
Process did not run successfully; returned status 128:
    git clone --quiet https://github.com/NCAR/MMM-physics.git /root/MPAS-Model-8.2.2/src/core_atmosphere/physics/physics_mmm
```
