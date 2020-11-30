#include<mpi.h>
#include<stdio.h>

int main(int argc, char** argv) {

    int rank, nprocs;

//    initialisation_cuda()
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    printf("hello world from %d, there are total %d \n", rank, nprocs);


    MPI_Finalize();
    return 0;
}