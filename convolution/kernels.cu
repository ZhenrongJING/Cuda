//__constant__ float filter[CHN][COL_F][ROW_F];

__global__ void convl(int const colR, int const rowR, float const* filter, float const* img, float* imgR){

    int const i= blockDim.y*blockIdx.y + threadIdx.y;
    int const j= blockDim.x*blockIdx.x + threadIdx.x;

    if (i<rowR && j<colR){
        int np = i*colR+j;
        imgR[np] = 0.0f;
        for(int ii=0; ii<ROW_F; ii++){
            for(int jj=0; jj<COL_F; jj++){
                int id = (i-ROW_F/2 +ii)*colR + (j-COL_F/2+jj); 
                float tmp;
                if (id<0 ||id>colR*rowR-1){
                    tmp = 0.0f;
                }else{
                    tmp = img[id];
                }
                imgR[np] += filter[ii*COL_F+jj]*tmp;
            }
        }
    }

}
