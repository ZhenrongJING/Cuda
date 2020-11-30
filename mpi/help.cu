#include<cstdlib>
#include<stdio.h>
#include"help.h"

void initialize(float* mtx, int const nx, int const ny){
    int tmp = nx*ny;
    for(int i=0; i<tmp; i++){
        mtx[i] = rand()/(float)RAND_MAX;
    }
};

__global__ void sumMatrix2D2D(float* d_a, float* d_b, float* d_c, int const nx, int const ny){

    int i = blockIdx.x*blockDim.x + threadIdx.x;
    int j = blockIdx.y*blockDim.y + threadIdx.y;
    int mp = j*ny+i;
    
    d_c[mp] = d_a[mp] + d_b[mp];
};

void computeGPU(float* h_a, float* h_b, float* h_c, int const mSize, int const nx, int const ny){

    float* d_a;
    float* d_b;
    float* d_c;
    cudaMalloc((void**)&d_a, mSize);
    cudaMalloc((void**)&d_b, mSize);
    cudaMalloc((void**)&d_c, mSize);
    cudaMemcpy(d_a, h_a, mSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, mSize, cudaMemcpyHostToDevice);

    int xBlock = 32;
    int yBlock = 32;

    dim3 block(xBlock, yBlock);
    dim3 grid(nx/xBlock, ny/yBlock);

    printf("run with block %d, %d", xBlock, yBlock);

    sumMatrix2D2D<<<grid, block>>>(d_a, d_b, d_c, nx, ny);
    cudaMemcpy(h_c, d_c, mSize, cudaMemcpyDeviceToHost);

    for (int i=0; i<nx*ny; i++){
        if ( abs(h_c[i] - (h_a[i] + h_b[i])) > 1e-4 ) {
            printf("2D2D");
            printf("%8.5f, %8.5f, %8.5f, %d \n", h_a[i], h_b[i], h_c[i], i);
            break;
        }
    }

    return;
}
