#include <iostream>
using std::cerr;
using std::endl;

// Error handling macro
#define CUDA_CHECK(call) \
    if((call) != cudaSuccess) { \
        cudaError_t err = cudaGetLastError(); \
        cerr << "CUDA error calling \""#call"\", code is " << err << endl;}

#include<stdio.h>

struct dataElem {
    int val;
    char* name;
};

__global__ void kernal(dataElem* e){
    printf("From the device %s\n", e->name);
};

int main() {

    dataElem* e;
    CUDA_CHECK(cudaMallocManaged((void**)&e, sizeof(dataElem)));
    e->val = 10;

    cudaMallocManaged((void**)&(e->name), sizeof(char)*(strlen("hello")+1) );
    strcpy(e->name, "hello");

    printf("From the host %s\n", e->name);

//    kernal<<<1,1>>>(e);
//    cudaDeviceSynchronize();

    return 0;
}
