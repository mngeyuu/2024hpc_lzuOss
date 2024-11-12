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