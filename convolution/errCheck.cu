#include "errCheck.hpp"
#include <stdio.h>

void checkKernelLaunch(cudaError_t* err) {
    if ( *err != cudaSuccess ) {
        printf("CUDA Error: %s\n", cudaGetErrorString(*err));
        exit(-1);
    }
}
