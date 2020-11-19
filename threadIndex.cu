#include<stdio.h>

__global__ void showCpy(float* d_a, int const nx, int const ny){
    unsigned int i = threadIdx.x;
    if(i<nx*ny) 
        printf("%d, %5.2f \n", i, d_a[i]); 
}

int main(){
    int const nx = 1<<4;
    int const ny = 1<<4;

    float h_a[nx][ny];
    for(int i=0; i<nx; i++){
        for(int j=0; j<ny; j++){
            h_a[i][j] = (float)i + ((float)j)/100;
        }
    }

    float* d_a;
    size_t mSize = nx*ny*sizeof(float);
    cudaMalloc((void**)&d_a, mSize); 

    cudaMemcpy(d_a, h_a, mSize, cudaMemcpyHostToDevice);

    dim3 grid(1, 1);
    dim3 block(nx*ny, 1);

    showCpy<<<grid, block>>>(d_a, nx, ny);

/*    for(int i=0; i<nx; i++){
        for(int j=0; j<ny; j++){
           printf("%5.2f ", h_a[i][j]); 
        }
        printf("\n");
    }
*/

    cudaDeviceSynchronize();
    return 0;
}
