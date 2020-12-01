#include<stdio.h>

__global__ void kernel(int i){

    printf("hello world %d \n", i);
};

int main(){

    int const n_stream = 5;
    cudaStream_t *ls_stream;
    ls_stream = (cudaStream_t*) new cudaStream_t[n_stream];

    for (int i=0; i<n_stream; i++){
        cudaStreamCreate(&ls_stream[i]);
    }


    for(int i=0; i<n_stream; i++){
        kernel<<<1, 1, 0, ls_stream[i]>>>(i);
    }

    cudaDeviceSynchronize();

    for(int i=0; i<n_stream; i++){
        cudaStreamDestroy(ls_stream[i]);
    }

    return 0;
}
