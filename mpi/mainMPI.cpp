#include<stdlib.h>
#include<stdio.h>
#include<mpi.h>

#include"help.h"

int main(int argc, char **argv){

    MPI_Init(&argc, &argv);
    int rank, n_proc;
    MPI_Comm_size(MPI_COMM_WORLD, &n_proc);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    printf("processor %d, there are %d in total \n", rank, n_proc);

    int const nx = 1<<8;
    int const ny = 1<<8;
    size_t mSize = nx*ny*sizeof(float);

    float* h_a;
    h_a = (float*)malloc(mSize);
    float* h_b;
    h_b = (float*)malloc(mSize);
    float* h_c;
    h_c = (float*)malloc(mSize);
    initialize(h_a, nx, ny);
    initialize(h_b, nx, ny);

    computeGPU(h_a, h_b, h_c, mSize, nx, ny);

    MPI_Finalize();
    return 0;
}
