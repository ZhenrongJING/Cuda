//__constant__ float filter[CHN][COL_F][ROW_F];

__global__ void convl(int const colR, int const rowR, float const* filter, float const* img, float* imgR){

    int const i= blockDim.y*blockIdx.y + threadIdx.y;
    int const j= blockDim.x*blockIdx.x + threadIdx.x;

    if (i<rowR && j<colR){
        int np = i*colR+j;
        imgR[np] = 0.0f;
        for(int ii=0; ii<ROW_F; ii++){
            for(int jj=0; jj<COL_F; jj++){

                int id = i*colR + j; 
                imgR[np] = img[id];

            }
        }
    }

}
