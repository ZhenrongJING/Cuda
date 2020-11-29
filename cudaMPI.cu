
#include <cuda.h>
#include <cuda_runtime.h>

void initialisation_cuda()
{
    char* local_rank_env;
    int local_rank;
    cudaError_t cudaRet;
 
     /* Recovery of the local rank of the process via the environment variable
        set by Slurm, as  MPI_Comm_rank cannot be used here because this routine
        is used BEFORE the initialisation of MPI*/
    local_rank_env = getenv("SLURM_LOCALID");
 
    if (local_rank_env) {
        local_rank = atoi(local_rank_env);
        /* Define the GPU to use for each MPI process */
        cudaRet = cudaSetDevice(local_rank);
        if(cudaRet != CUDA_SUCCESS) {
            printf("Erreur: cudaSetDevice has failed\n");
            exit(1);
        }
    } else {
        printf("Error : impossible to determine the local rank of the process\n");
        exit(1);
    }
}

