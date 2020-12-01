#include<stdio.h>

__global__ void kernel(){

    printf("hello world");
};

int main(){

    cudaStream_t stream;
    cudaStreamCreate(&stream);

    for(int i=0; i<5; i++){
        kernel<<<1, 1>>>();
    }

    cudaStreamDestroy(stream);

    cudaDeviceSynchronize();

    return 0;
}
