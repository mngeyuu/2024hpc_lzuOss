#!/usr/bin/env bash

# Exit on error
set -e

# Exit on undefined variables
set -u

# Exit if any command in a pipe fails
set -o pipefail

# Define constants
readonly VERSION="7.0"
readonly MPAS_DIR="/root/MPAS-Model-${VERSION}"
readonly BENCHMARK_DIR="/root/MPAS-A_benchmark_120km_v${VERSION}"
readonly NAMELIST_FILE="${BENCHMARK_DIR}/namelist.atmosphere"
readonly NUM_THREADS=4

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check required environment variables
check_env_vars() {
    local required_vars=("NETCDF" "PNETCDF" "PIO")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log "ERROR: Required environment variable $var is not set"
            exit 1
        fi
    done
}

# Function to download and extract MPAS
download_mpas() {
    log "Downloading MPAS v${VERSION}..."
    wget -q "https://github.com/MPAS-Dev/MPAS-Model/archive/refs/tags/v${VERSION}.tar.gz"
    
    log "Extracting archive..."
    tar -xf "v${VERSION}.tar.gz"
    rm "v${VERSION}.tar.gz"
    
    cd "${MPAS_DIR}"
}

# Function to update Makefile PIO test
update_pio_test() {
    log "Updating PIO test in Makefile..."
    cat > pio_test.tmp << 'EOF'
FC=mpifort
pio_test:
	@echo "program pio1; use pio; use pionfatt_mod; integer, parameter :: MPAS_IO_OFFSET_KIND = PIO_OFFSET; integer, parameter :: MPAS_INT_FILLVAL = NF_FILL_INT; end program" > pio1.f90
	@echo "program pio2; use pio; integer, parameter :: MPAS_IO_OFFSET_KIND = PIO_OFFSET_KIND; integer, parameter :: MPAS_INT_FILLVAL = PIO_FILL_INT; end program" > pio2.f90
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
    sed -i '/^pio_test:/,/^endif/{ r pio_test.tmp; d }' Makefile
    rm pio_test.tmp
}

# Function to update Makefile gfortran settings
update_gfortran_settings() {
    log "Updating gfortran settings in Makefile..."
    cat > gfortran.tmp << 'EOF'
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
    sed -i '/^gfortran:/,/\)$/{ r gfortran.tmp; d }' Makefile
    rm gfortran.tmp
}

# Function to compile MPAS
compile_mpas() {
    log "Compiling MPAS..."
    make -j"${NUM_THREADS}" gfortran \
        CORE=init_atmosphere \
        PRECISION=single \
        VERBOSE=1 \
        NETCDF="${NETCDF}" \
        PNETCDF="${PNETCDF}" \
        PIO="${PIO}" \
        AUTOCLEAN=true \
        USE_PIO2=true
}

# Function to prepare benchmark directory
prepare_benchmark() {
    log "Preparing benchmark directory..."
    cp "${MPAS_DIR}/atmosphere_model" "${BENCHMARK_DIR}"
    cd "${BENCHMARK_DIR}"
    
    if [[ ! -f "x1.40962.graph.info" ]]; then
        log "ERROR: Graph info file not found"
        exit 1
    }
    
    gpmetis -minconn -contig "x1.40962.graph.info" "${NUM_THREADS}"
}

# Function to update namelist
update_namelist() {
    log "Updating namelist configuration..."
    if [[ ! -f "${NAMELIST_FILE}" ]]; then
        log "ERROR: Namelist file not found at ${NAMELIST_FILE}"
        exit 1
    }

    sed -i \
        -e 's/config_run_duration = '\''3_00:00:00'\''/config_run_duration = '\''00:16:00'\''/' \
        -e 's/&io\n    config_pio_num_iotasks = 0\n    config_pio_stride = 1/&io\n    config_pio_num_iotasks = 4\n    config_pio_stride = 1/' \
        "${NAMELIST_FILE}"
}

# Function to run MPAS
run_mpas() {
    log "Running MPAS with ${NUM_THREADS} threads..."
    mpirun -np "${NUM_THREADS}" ./atmosphere_model
}

# Main execution
main() {
    log "Starting MPAS build and run script..."
    
    check_env_vars
    download_mpas
    update_pio_test
    update_gfortran_settings
    compile_mpas
    prepare_benchmark
    update_namelist
    run_mpas
    
    log "Script completed successfully"
}

# Execute main function
main "$@"