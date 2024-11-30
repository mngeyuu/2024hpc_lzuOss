# # 定义变量
# CXX = g++
# NVCC = nvcc
# MPICXX = mpic++
# CXXFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -lstdc++fs
# CXXFLAGS_OPENMP = $(CXXFLAGS) -fopenmp
# CXXFLAGS_OPENBLAS = $(CXXFLAGS) -L/usr/local/OpenBLAS/lib -lopenblas 
# CUDAFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -lcudart
# MPIFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -L/usr/local/cuda-11.8/targets/x86_64-linux/lib/ -lcudart
# CUDA_INC = -I/usr/lib/x86_64-linux-gnu/openmpi/include

# # 设置源文件路径
# LOG_DIR = logs

# # 目标文件名
# TARGETS = datagen matrix_cal_general matrix_cal_cuda matrix_cal_mpi_cuda matrix_cal_openmp matrix_cal_mpi matrix_cal_openblas matrix_cal_mpi_openmp

# # 创建 logs 目录
# $(shell mkdir -p $(LOG_DIR))

# # 默认目标
# all: $(TARGETS)

# # 编译 datagen.cpp
# datagen: $/datagen.cpp
# 	$(CXX) $(CXXFLAGS) -o $@ $^
# #./$@ >> $(LOG_DIR)/datagen.log 2>&1

# # 编译 matrix_cal_general.cpp
# matrix_cal_general: $/matrix_cal_general.cpp
# 	$(CXX) $(CXXFLAGS) -o $@ $^
# 	./$@ >> $(LOG_DIR)/matrix_cal_general.log 2>&1

# # 编译 matrix_cal_cuda.cu
# matrix_cal_cuda: $/matrix_cal_cuda.cu
# 	$(NVCC) $(CUDAFLAGS) -o $@ $^
# 	./$@ >> $(LOG_DIR)/matrix_cal_cuda.log 2>&1

# # 编译 matrix_cal_mpi_cuda.cu
# matrix_cal_mpi_cuda.o: $/matrix_cal_mpi_cuda.cu
# 	$(NVCC) -std=c++17 -o $@ -c $^ $(MPIFLAGS)

# matrix_cal_mpi_cuda: matrix_cal_mpi_cuda.o
# 	$(MPICXX) $(MPIFLAGS) -o $@ $^ -lcudart -lcuda
# 	./$@ >> $(LOG_DIR)/matrix_cal_mpi_cuda.log 2>&1

# # 编译 matrix_cal_openmp.cpp
# matrix_cal_openmp: $/matrix_cal_openmp.cpp
# 	$(CXX) $(CXXFLAGS_OPENMP) -o $@ $^
# 	./$@ >> $(LOG_DIR)/matrix_cal_openmp.log 2>&1

# # 编译 matrix_cal_mpi.cpp
# matrix_cal_mpi: $/matrix_cal_mpi.cpp
# 	$(MPICXX) $(MPIFLAGS) -o $@ $^
# 	./$@ >> $(LOG_DIR)/matrix_cal_mpi.log 2>&1

# # 编译 matrix_cal_openblas.cpp
# matrix_cal_openblas: $/matrix_cal_openblas.cpp
# 	$(CXX) -o $@ $^ $(CXXFLAGS_OPENBLAS) 
# 	./$@ >> $(LOG_DIR)/matrix_cal_openblas.log 2>&1

# # 编译 matrix_cal_mpi_openmp.cpp
# matrix_cal_mpi_openmp: $/matrix_cal_mpi_openmp.cpp
# 	$(MPICXX) $(MPIFLAGS) -o $@ $^ -fopenmp -O2
# 	./$@ >> $(LOG_DIR)/matrix_cal_mpi_openmp.log 2>&1

# # 清理编译生成的文件
# clean:
# 	rm -f $(TARGETS) *.o
# 	rm -rf $(LOG_DIR)

# 定义变量
CXX = g++
NVCC = nvcc
MPICXX = mpic++
CXXFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -lstdc++fs
CXXFLAGS_OPENMP = $(CXXFLAGS) -fopenmp
CXXFLAGS_OPENBLAS = $(CXXFLAGS) -L/usr/local/OpenBLAS/lib -lopenblas 
CUDAFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -lcudart
MPIFLAGS = -std=c++17 -I/root/upper_level_algorithm_opt/inc -L/usr/local/cuda-11.8/targets/x86_64-linux/lib/ -lcudart
CUDA_INC = -I/usr/lib/x86_64-linux-gnu/openmpi/include

# 设置源文件路径
SRC_DIR = src
INC_DIR = inc

# 目标文件名
TARGETS = datagen matrix_cal_general matrix_cal_cuda matrix_cal_mpi_cuda matrix_cal_openmp matrix_cal_mpi matrix_cal_openblas matrix_cal_mpi_openmp

all: $(TARGETS)

# 编译 datagen.cpp
datagen: $/datagen.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

# 编译 matrix_cal_general.cpp
matrix_cal_general: $/matrix_cal_general.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

# 编译 matrix_cal_cuda.cu
matrix_cal_cuda: $/matrix_cal_cuda.cu
	$(NVCC) $(CUDAFLAGS) -o $@ $^

# 编译 matrix_cal_mpi_cuda.cu
matrix_cal_mpi_cuda.o: $/matrix_cal_mpi_cuda.cu
	$(NVCC) -std=c++17 -o $@ -c $^ $(CXXFLAGS) $(CUDA_INC)

matrix_cal_mpi_cuda: matrix_cal_mpi_cuda.o
	$(MPICXX) $(MPIFLAGS) -o $@ $^ -lcudart -lcuda

# 编译 matrix_cal_openmp.cpp
matrix_cal_openmp: $/matrix_cal_openmp.cpp
	$(CXX) $(CXXFLAGS_OPENMP) -o $@ $^

# 编译 matrix_cal_mpi.cpp
matrix_cal_mpi: $/matrix_cal_mpi.cpp
	$(MPICXX) $(MPIFLAGS) -o $@ $^

# 编译 matrix_cal_openblas.cpp
matrix_cal_openblas: $/matrix_cal_openblas.cpp
	$(CXX) -o $@ $^ $(CXXFLAGS_OPENBLAS) 

# 编译 matrix_cal_mpi_openmp.cpp
matrix_cal_mpi_openmp: $/matrix_cal_mpi_openmp.cpp
	g++ -std=c++17 -I/root/upper_level_algorithm_opt/inc -o matrix_cal_openmp matrix_cal_openmp.cpp -lstdc++fs -fopenmp

# 清理编译生成的文件
clean:
	rm -f $(TARGETS) *.o
