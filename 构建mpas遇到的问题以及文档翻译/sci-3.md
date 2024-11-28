编译命令
datagen.cpp
```
g++ -std=c++17 -o datagen datagen.cpp
```

matrix_cal_general.cpp
```
g++ -std=c++17 -I/root/upper_level_algorithm_opt/inc -o matrix_cal_general matrix_cal_general.cpp -lstdc++fs
```
matrix_cal_cuda.cu 

```
nvcc -std=c++17 -I/root/upper_level_algorithm_opt/inc -o matrix_cal_cuda matrix_cal_cuda.cu -lcudart -lstdc++fs
```

matrix_cal_mpi_cuda.cu
```
**nvcc -std=c++17 -o matrix_cal_mpi_cuda.o -c matrix_cal_mpi_cuda.cu -I/root/upper_level_algorithm_opt/inc -I/usr/lib/x86_64-linux-gnu/openmpi/include/**

**mpic++ -std=c++17 -o matrix_cal_mpi_cuda matrix_cal_mpi_cuda.o -I/root/upper_level_algorithm_opt/inc -L/usr/local/cuda-11.8/targets/x86_64-linux/lib/ -lcudart**

```

matrix_cal_openmp.cpp:
```
g++ -std=c++17 -I/root/upper_level_algorithm_opt/inc -o matrix_cal_openmp matrix_cal_openmp.cpp -lstdc++fs -fopenmp
```

matrix_cal_mpi.cpp:
```
mpic++ -std=c++17 -o matrix_cal_mpi matrix_cal_mpi.cpp -I/root/upper_level_algorithm_opt/inc   
```

matrix_cal_openblas
```
g++ -std=c++17 -o matrix_cal_openblas matrix_cal_openblas.cpp -I/root/upper_level_algorithm_opt/inc -L/usr/local/OpenBLAS/lib -lopenblas -std=c++17 -O2

```
matrix_cal_openmp:
```
g++ -std=c++17 -o matrix_openmp matrix_cal_openmp.cpp -fopenmp -I/root/upper_level_algorithm_opt/inc -std=c++17 -O2
```

matrix_cal_mpi_openmp
```

mpic++ -std=c++17 -o matrix_cal_mpi_openmp matrix_cal_mpi_openmp.cpp -fopenmp -I/root/upper_level_algorithm_opt/inc -std=c++17 -O2
```