#include<stdio.h>

__global__ void kernal1(float* d_a){
    float a;
    float b;
    a = b = 0.0;

    int nid = blockDim.x*blockIdx.x + threadIdx.x;
    if (nid%2 == 0){
        a = 100.0;
    }else{
        b = 200.0;
    }
    d_a[nid] = a+b;
};

int main(int argc, char** argv){
    int const n = 1<<16;
    int mSize = n*sizeof(float);

    float* d_a;
    cudaMalloc((void**)&d_a, mSize);

    int xBlock = 256;
    kernal1<<<n/xBlock, xBlock>>>(d_a);

    cudaDeviceSynchronize();
    return 0;
}
