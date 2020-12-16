__global__ void padding(int const nchl, int const nrow, int const ncol,int const npad,
        float* img, float* imgPad){

    int i = blockIdx.x*blockDim.x+threadIdx.x;
    int j = blockIdx.y*blockDim.y+threadIdx.y;
    int const rowP = nrow + 2*npad;
    int const colP = ncol + 2*npad;

    if ( (i<ncol+2*npad) && (j<nrow+2*npad) ){
    for (int n=0; n<nchl; n++){
        int idxP = idxD(nchl, rowP, colP, n, j, i);
        if ( (i>npad-1 && i<ncol+npad) && (j>npad-1 && j<nrow+npad) ) {
            int idxI = idxD(nchl, nrow, ncol, n, j-npad, i-npad);
            imgPad[idxP] = img[idxI];
        } else {
            imgPad[idxP] = 0.f;
        }
    }
    }
}

__global__ void convl(int const nFilter, int const nchl, int const rowP, int const colP, int const rowF, int const colF, float* imgPad, float* imgR, float* filter){

    int i = blockIdx.x*blockDim.x+threadIdx.x;
    int j = blockIdx.y*blockDim.y+threadIdx.y;

    __shared__ float tmpFilter[];
    if (i<colP-colF && j<rowP-colF){
        for (int n=0; n<nFilter; n++){
        for (int c=0; c<nchl; c++){
            for (int jj=threadIdx.y; jj<rowF; jj += blockDim.y){
                for (int ii=threadIdx.x; ii<colF; ii += blockDim.x){
                    int idxF = idxD4(nFilter, nchl, rowF, colF, n, c, jj, ii);
                    tmpFilter[jj*colF+ii] = filter[idxF];
                }
            }
            
            int idxR = idxD4(nFilter, nchl, rowP-rowF, colP-colF, n, c, j, i); 
            imgR[idxR] = 0.0f;
            for (int jj=0; jj<rowF; jj++){
                for (int ii=0; ii<colF; ii++){
                    int idxP = idxD(nchl, rowP, colP, c, j+jj, i+ii);
                    imgR[idxR] += imgPad[idxP]*tmpFilter[jj*colF+ii]; 
                }
            } 
        }
        }
    }
}
