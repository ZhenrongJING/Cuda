int idx(int const nrow, int const ncol, int const i, int const j);
int idx(int const channels, int const nrow, int const ncol, int const c, int const i, int const j);
int idx(int const nImage, int const channels, int const nrow, int const ncol, int const n, int const c, int const i, int const j);

__device__ int idxD(int const channels, int const nrow, int const ncol, int const c, int const i, int const j);
__device__ int idxD4(int const nImage, int const channels, int const nrow, int const ncol, int const n, int const c, int const i, int const j);

int idx(int const nrow, int const ncol, int const i, int const j){
    int index = i*ncol+j;
    return index;
}

int idx(int const channels, int const nrow, int const ncol, int const c, int const i, int const j){
    int index = c*(nrow*ncol)+i*ncol+j;
    return index;
}

int idx(int const nImage, int const channels, int const nrow, int const ncol, int const n, int const c, int const i, int const j){
    int index = n*(channels*nrow*ncol)+c*(nrow*ncol)+i*ncol+j;
    return index;
}

__device__ int idxD(int const channels, int const nrow, int const ncol, int const c, int const i, int const j){
    int index = c*(nrow*ncol)+i*ncol+j;
    return index;
}

__device__ int idxD4(int const nImage, int const channels, int const nrow, int const ncol, int const n, int const c, int const i, int const j){
    int index = n*(channels*nrow*ncol)+c*(nrow*ncol)+i*ncol+j;
    return index;
}
