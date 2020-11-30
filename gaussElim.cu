#include <iostream>
using std::cerr;
using std::endl;

// Error handling macro
#define CUDA_CHECK(call) \
    if((call) != cudaSuccess) { \
        cudaError_t err = cudaGetLastError(); \
        cerr << "CUDA error calling \""#call"\", code is " << err << endl;}

#include<stdio.h>
#include<stdlib.h>

void init_mtx(float* mtx, int n_unknows){

    for(int i=0; i<n_unknows; i++){
        for (int j=0; j<(n_unknows+1); j++){
            int mp = i*(n_unknows+1) + j;
            mtx[mp] = (float)(rand()%10);
        }
    }
}

void gauss_solver(float* mtx, int const n_unknows){
    for (int i=0; i<1; i++){
        for (int j=i+1; j<n_unknows; j++){
            int const mp = i*(n_unknows+1) + i;
            float ratio = mtx[j*(n_unknows+1)+i]/mtx[mp];
            for ( int k=0; k<n_unknows; k++){
                mtx[j*(n_unknows+1)+k] -= ratio*mtx[i*(n_unknows+1)+k];
            }
        } 
    }
}

void print_mtx(float* mtx, int n_r, int n_c){

    if (n_c>12 || n_c> 12) {
        printf("too large to be printed");
        return;
    }

    for(int i=0; i<n_r; i++){
        for(int j=0; j<n_c; j++){
            int mp = i*n_c + j;
            printf("%6.2f ", mtx[mp]);
        }
        printf("\n");
    }
    printf("-------------------------------------\n");
}

int main() {

    float* arg_mtx;
    float* h_mtx;
    int const n_unknows = 8;
    size_t mSize = n_unknows*(n_unknows+1)*sizeof(float);

    CUDA_CHECK(cudaMallocManaged((void**)&arg_mtx, mSize));
    h_mtx = (float*)malloc(mSize); 

    init_mtx(h_mtx, n_unknows);
    print_mtx(h_mtx, n_unknows, n_unknows+1);
    gauss_solver(h_mtx, n_unknows);
    print_mtx(h_mtx, n_unknows, n_unknows+1);

    return 0;
}
