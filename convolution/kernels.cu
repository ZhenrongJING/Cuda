//__constant__ float filter[CHN][COL_F][ROW_F];

__global__ void convl(int const rowR, int const colR, float const* filter, float const* img, float* imgR){

    int const i= blockDim.y*blockIdx.y + threadIdx.y;
    int const j= blockDim.x*blockIdx.x + threadIdx.x;

    if (i<rowR && j<colR){
        int np = i*colR+j;
        imgR[np] = 0.0f;
        for(int ii=0; ii<ROW_F; ii++){
            int ix = i-ROW_F/2+ii;
            for(int jj=0; jj<COL_F; jj++){
                int iy = j-COL_F/2+jj;
                float tmp;
                if (ix<0 || ix>=rowR || iy< 0 || iy>=colR){
                    tmp = 0.0f;
                }else{
                    int id = ix*colR + iy;
                    tmp = img[id];
                }
                imgR[np] += filter[ii*COL_F+jj]*tmp;
            }
        }
    }

}
