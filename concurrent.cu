#define NSTREAM 4
#include<stdio.h>


__global__ void addVec(int* a, int* b, int* c, int const len){
    int i = blockDim.x*blockIdx.x + threadIdx.x;
    if (i<len) c[i] = a[i] + b[i];
};

int main(){

    int const totalLen = 1<<16;
    int const mSize = totalLen*sizeof(int);

    int* h_a;
    int* h_b;
    int* h_c;

    cudaHostAlloc((void**)&h_a, mSize, cudaHostAllocDefault);
    cudaHostAlloc((void**)&h_b, mSize, cudaHostAllocDefault);
    cudaHostAlloc((void**)&h_c, mSize, cudaHostAllocDefault);

    for (int i=0; i<totalLen; i++){
        h_a[i] = i;
        h_b[i] = totalLen - i;
    }

    int* d_a;
    int* d_b;
    int* d_c;

    cudaMalloc((void**)&d_a, mSize);
    cudaMalloc((void**)&d_b, mSize);
    cudaMalloc((void**)&d_c, mSize);

    int const lenPerStream = totalLen/NSTREAM;
    int const mSizePerStream = mSize/NSTREAM;

    cudaStream_t lsStream[NSTREAM];

    for (int i=0; i<NSTREAM; i++){
        cudaStreamCreate(&lsStream[i]);
    }

    int const block = 256;
    int const grid = lenPerStream/block;

    for (int i=0; i<NSTREAM; i++){
        int offset = i*lenPerStream;
        cudaMemcpyAsync(&d_a[offset], &h_a[offset], mSizePerStream, cudaMemcpyHostToDevice, lsStream[i]);
        cudaMemcpyAsync(&d_b[offset], &h_b[offset], mSizePerStream, cudaMemcpyHostToDevice, lsStream[i]);
        addVec<<<grid, block, 0, lsStream[i]>>>(&d_a[offset], &d_b[offset], &d_c[offset], lenPerStream);
        cudaMemcpyAsync(&h_c[offset], &d_c[offset], mSizePerStream, cudaMemcpyDeviceToHost, lsStream[i]);
    }

    for (int i=0; i<NSTREAM; i++){
        cudaStreamSynchronize(lsStream[i]);
    }

    for (int i=0; i<totalLen; i++){
        if (h_c[i]!=totalLen) {
            printf("error, %d, %d \n", h_c[i], i);
            break;
        }
    }

    for (int i=0; i<NSTREAM; i++){
        cudaStreamDestroy(lsStream[i]);
    }

    return 0;
}
