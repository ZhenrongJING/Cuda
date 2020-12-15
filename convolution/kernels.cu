__global__ void padding(int const nchl, int const nrow, int const ncol,int const npad,
        float* img, float* imgPad){

    int i = blockIdx.x*blockDim.x+threadIdx.x;
    int j = blockIdx.y*blockDim.y+threadIdx.y;
    int const rowP = nrow + 2*npad;
    int const colP = ncol + 2*npad;

    if ( (i<ncol+2*npad) && (i<ncol+2*npad) ){
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

    if (i<colP-colF && j<rowP-colF){
        for (int c=0; c<nchl; c++){
            int idxR = idxD(nchl, rowP-rowF, colP-colF, c, i, j); 
            imgR[idxR] = 0.0f;
            for (int ii=0; ii<rowF; ii++){
                for (int jj=0; jj<colF; jj++){
                    int idxF = idxD4(nFilter, nchl, rowF, colF, 0, c, ii, jj);
                    int idxP = idxD(nchl, rowP, colP, c, i+ii, j+jj);
                    imgR[idxR] += imgPad[idxP]*filter[idxF]; 
                }
            } 
        }
    }

}
