#include<cstdlib>
#include<stdio.h>

void initialize(float* mtx, int const nx, int const ny){
    int tmp = nx*ny;
    for(int i=0; i<tmp; i++){
        mtx[i] = rand()/(float)RAND_MAX;
    }

};

__global__ void sumMatrix2D2D(float* d_a, float* d_b, float* d_c, int const nx, int const ny){

    int i = blockIdx.x*blockDim.x + threadIdx.x;
    int j = blockIdx.y*blockDim.y + threadIdx.y;
    int mp = i*ny+j;
    
    d_c[mp] = d_a[mp] + d_b[mp];
};

__global__ void sumMatrix1D1D(float* d_a, float* d_b, float* d_c, int const nx, int const ny){

    int i = blockIdx.x;
    for (; i < nx; i += gridDim.x){
        int j = threadIdx.x; 
        for (; j < ny; j += blockDim.x){
            int mp = i*ny + j;
            d_c[mp] = d_a[mp] + d_b[mp];
        }
    }
};

int main(int argc, char **argv){
    int const nx = 1<<14;
    int const ny = 1<<14;
    size_t mSize = nx*ny*sizeof(float);

    float* h_a;
    h_a = (float*)malloc(mSize);
    float* h_b;
    h_b = (float*)malloc(mSize);
    float* h_c;
    h_c = (float*)malloc(mSize);
    initialize(h_a, nx, ny);
    initialize(h_b, nx, ny);


    float* d_a;
    float* d_b;
    float* d_c;
    cudaMalloc((void**)&d_a, mSize);
    cudaMalloc((void**)&d_b, mSize);
    cudaMalloc((void**)&d_c, mSize);
    cudaMemcpy(d_a, h_a, mSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, mSize, cudaMemcpyHostToDevice);

    int xBlock = 32;
    int yBlock = 16;
    if(argc > 1) xBlock = atoi(argv[0]);
    if(argc > 2) xBlock = atoi(argv[1]);
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

    sumMatrix1D1D<<<128, 128>>>(d_a, d_b, d_c, nx, ny);
    cudaMemcpy(h_c, d_c, mSize, cudaMemcpyDeviceToHost);

    for (int i=0; i<nx*ny; i++){
        if ( abs(h_c[i] - (h_a[i] + h_b[i])) > 1e-4 ) {
            printf("1D1D");
            printf("%8.5f, %8.5f, %8.5f, %d \n", h_a[i], h_b[i], h_c[i], i);
            break;
        }
    }

    return 0;
}
