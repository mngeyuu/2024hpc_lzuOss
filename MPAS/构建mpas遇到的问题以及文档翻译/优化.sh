# 下载mpas
wget https://github.com/MPAS-Dev/MPAS-Model/archive/refs/tags/v7.0.tar.gz
tar -zxvf MPAS-Model-7.0.tar.gz
cd MPAS-Model-7.0

# 修改makefile

# 修改makefile的pio测试
cat > new_content.tmp << 'EOF'
FC=mpifort
pio_test:
	@#
	@# Create two test programs: one that should work with PIO1 and a second that should work with PIO2
	@#
	@echo "program pio1; use pio; use pionfatt_mod; integer, parameter :: MPAS_IO_OFFSET_KIND = PIO_OFFSET; integer, parameter :: MPAS_INT_FILLVAL = NF_FILL_INT; end program" > pio1.f90
	@echo "program pio2; use pio; integer, parameter :: MPAS_IO_OFFSET_KIND = PIO_OFFSET_KIND; integer, parameter :: MPAS_INT_FILLVAL = PIO_FILL_INT; end program" > pio2.f90
	@#
	@# See whether either of the test programs can be compiled
	@#
	@echo "Checking for a usable PIO library..."
	@echo $(FC) $(FCINCLUDES) $(FFLAGS) $(FFLAGS) $(LDFLAGS) $(LIBS)
	@($(FC) pio1.f90 $(FCINCLUDES) $(FFLAGS) $(LDFLAGS) $(LIBS) -o pio1.out &> /dev/null && echo "=> PIO 1 detected") || \
	 ($(FC) pio2.f90 $(FCINCLUDES) $(FFLAGS) $(LDFLAGS) $(LIBS) -o pio2.out &> /dev/null && echo "=> PIO 2 detected") || \
	 (echo "************ ERROR ************"; \
	  echo "Failed to compile a PIO test program"; \
	  echo "Please ensure the PIO environment variable is set to the PIO installation directory"; \
	  echo "************ ERROR ************"; \
	  rm -rf pio[12].f90 pio[12].out; exit 1)
	@rm -rf pio[12].out
EOF

# Create a sed script to perform the replacement
cat > sed_script.tmp << 'EOF'
/^pio_test:/,/^endif/{
  r new_content.tmp
  d
}
EOF

# Perform the replacement
sed -i -f sed_script.tmp Makefile

# Clean up temporary files
rm new_content.tmp sed_script.tmp

# 修改make gfortran的编译器

# Create a temporary file to store the new content
cat > new_content.tmp << 'EOF'
gfortran:
	( $(MAKE) all \
	"FC_PARALLEL = mpif90" \
	"CC_PARALLEL = mpicc" \
	"CXX_PARALLEL = mpicxx" \
	"FC_SERIAL = gfortran" \
	"CC_SERIAL = gcc" \
	"CXX_SERIAL = g++" \
	"FFLAGS_PROMOTION = -fdefault-real-8 -fdefault-double-8" \
	"FFLAGS_OPT = -Ofast -ffree-line-length-none -fconvert=big-endian -ffree-form -mavx512f -march=native -O3" \
	"CFLAGS_OPT = -Ofast -mavx512f -march=native -O3" \
	"CXXFLAGS_OPT = -Ofast -mavx512f -march=native -O3" \
	"LDFLAGS_OPT = -Ofast -mavx512f -march=native -O3" \
	"FFLAGS_DEBUG = -g -m64 -ffree-line-length-none -fconvert=big-endian -ffree-form -fbounds-check -fbacktrace -ffpe-trap=invalid,zero,overflow" \
	"CFLAGS_DEBUG = -g -m64" \
	"CXXFLAGS_DEBUG = -O3 -m64" \
	"LDFLAGS_DEBUG = -g -m64" \
	"FFLAGS_OMP = -fopenmp" \
	"CFLAGS_OMP = -fopenmp" \
	"CORE = $(CORE)" \
	"DEBUG = $(DEBUG)" \
	"USE_PAPI = $(USE_PAPI)" \
	"OPENMP = $(OPENMP)" \
	"CPPFLAGS = $(MODEL_FORMULATION) -D_MPI" )
EOF

# Create a sed script for the replacement
cat > sed_script.tmp << 'EOF'
/^gfortran:/,/\)$/{
  r new_content.tmp
  d
}
EOF

# Perform the replacement
sed -i -f sed_script.tmp Makefile

# Clean up temporary files
rm new_content.tmp sed_script.tmp

# 编译MPAS

make -j4 gfortran CORE=init_atmosphere PRECISION=single VERBOSE=1 NETCDF=$NETCDF PNETCDF=$PNETCDF PIO=$PIO AUTOCLEAN=true USE_PIO2=true

# 拷贝可执行文件

cp  /root/MPAS-Model-7.0/atmosphere_model /root/MPAS-A_benchmark_120km_v7.0
cd /root/MPAS-A_benchmark_120km_v7.0

gpmetis −minconn −contig /root/MPAS-A_benchmark_120km_v7.0/x1.40962.graph.info 4

# 定义文件路径
NAMELIST_FILE="/root/MPAS-A_benchmark_120km_v7.0/namelist.atmosphere"

# 检查文件是否存在
if [ ! -f "$NAMELIST_FILE" ]; then
  echo "文件 $NAMELIST_FILE 不存在，请检查路径！"
  exit 1
fi

# 使用 sed 进行文本替换
sed -i "
s/config_run_duration = '3_00:00:00'/config_run_duration = '00:16:00'/;
s/&io\n    config_pio_num_iotasks = 0\n    config_pio_stride = 1/&io\n    config_pio_num_iotasks = 4\n    config_pio_stride = 1/
" "$NAMELIST_FILE"

# 检查替换是否成功
if [ $? -eq 0 ]; then
  echo "文件修改成功！"
else
  echo "文件修改失败，请检查脚本。"
fi

# 运行MPAS
mpirun -np 4 ./atmosphere_model 