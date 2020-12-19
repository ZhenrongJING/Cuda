#include <stdio.h>
#include <iostream>
#include <algorithm>
#include <opencv2/opencv.hpp>

#define ROW_F 7
#define COL_F 7
#define CHN   3

#include "index.hpp"
#include "kernels.cu"
using namespace cv;
using namespace std;


int main(int argc, char** argv )
{
    if ( argc != 2 )
    {
        printf("usage: DisplayImage.out <Image_Path>\n");
        return -1;
    }

    Mat image;
    image = imread( argv[1], 1 );
    Mat imageFloat;
    image.convertTo(imageFloat, CV_32FC3, 1.0/255.0);

    if ( !image.data )
    {
        printf("No image data \n");
        return -1;
    }

    printf( " image type %d\n", image.type() );
    printf( " image type %d\n", imageFloat.type() );

    int const nrow = imageFloat.rows;
    int const ncol = imageFloat.cols;
    printf( " size of the image %d times  %d times  %d\n", CHN, nrow, ncol);

    float *h_img;
    h_img = new float[CHN*nrow*ncol];

    int np = 0;
    for (int c=0; c<CHN; c++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                np = c*(nrow*ncol)+i*ncol+j;
                h_img[np] = imageFloat.at<Vec3f>(i,j)[c]; 
            }
        }
    }

    int nElem;
    int const nFilter=2;
    nElem = CHN*nFilter*ROW_F*COL_F;
    float *h_filter;
    h_filter = new float[nElem];

    for(int c=0; c<CHN; c++){
        for (int n=0; n<nFilter; n++){
            for (int i=0; i<ROW_F; i++){
                for (int j=0; j<COL_F; j++){
                    h_filter[idx(CHN,nFilter,ROW_F,COL_F,c,n,i,j)] = rand()/(RAND_MAX+0.f); 
                }
            } 
        }
    }

    float* d_img;
    nElem = CHN*nrow*ncol;
    cudaMalloc((void**)&d_img, nElem*sizeof(float));

    float* d_imgR;
    nElem = CHN*nFilter*nrow*ncol;
    cudaMalloc((void**)&d_imgR, nElem*sizeof(float));

    float* d_filter[CHN];
    nElem = ROW_F*COL_F;
    
    for (int i=0;i<CHN;i++){
        cudaMalloc((void**)&d_filter[i], nElem*sizeof(float));
    }

    for (int c=0;c<2;c++){
        int size = nrow*ncol;
        int offset = c*size;
        cudaMemcpy(&d_img[offset], &h_img[offset], size*sizeof(float), cudaMemcpyHostToDevice);

        for (int f=0;f<nFilter;f++){
            size = ROW_F*COL_F;
            offset = (c*nFilter+f)*size;
            cudaMemcpy(d_filter[c], &h_filter[offset], size*sizeof(float), cudaMemcpyHostToDevice);

            int const bx=32, by=32;
            int const gx=ncol/bx+1, gy=nrow/by+1;
            dim3 block(bx,by);
            dim3 grid (gx,gy);
            offset = (c*nFilter+f)*ncol*nrow;
            convl<<<block, grid>>>(nrow, ncol, d_filter[c], &d_img[c*nrow*ncol], &d_imgR[offset]);
        }
    }

/*
    float* test;
    nElem = CHN*nrow*ncol;
    test = new float[nElem];
    cudaMemcpy(test, d_img, nElem*sizeof(float), cudaMemcpyDeviceToHost);

    for (int i=0; i<nElem; i++){
        if ( abs(test[i] - h_img[i]) > 0.0001f ) {
            cout << i << ' ' << test[i] << ' ' << h_img[i] << endl;
            exit(0);
        }
    }

*/

    nElem = CHN*nFilter*nrow*ncol;
    float* imageR;
    imageR = new float[nElem];

    for(int c=0; c<CHN; c++){
        for (int n=0; n<nFilter; n++){
            for (int i=0; i<nrow; i++){
                for (int j=0; j<ncol; j++){
                    imageR[idx(CHN,nFilter,nrow,ncol,c,n,i,j)] = 0.0;

                    int id = i*ncol + j;
                    float tmp;
                    if (id<0 ||id>ncol*nrow-1){
                        tmp = 0.0f;
                    }else{
                        id += c*nrow*ncol;
                        tmp = h_img[id];
                    }
                    imageR[idx(CHN,nFilter,nrow,ncol,c,n,i,j)] = tmp;
                }
            }
        }
    }

    float* test;
    nElem = CHN*nFilter*nrow*ncol;
    test = new float[nElem];
    cudaMemcpy(test, d_imgR, nElem*sizeof(float), cudaMemcpyDeviceToHost);

    for (int c=0; c<CHN; c++){
    for (int n=0; n<nFilter; n++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                int np = idx(CHN, nFilter, nrow, ncol, c, n, i, j);
                if ( abs(test[np] - imageR[np]) > 0.001 ) {
                    cout << n << ' ' << c << ' ' << i << ' ' << j << ' ' << test[np] << ' ' << imageR[np] << endl;
                    exit(0);
                };
            }
        }
    }
    }


/*
    for (int c=0; c<CHN; c++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                imageFloat.at<Vec3f>(i,j)[c] = imageR[idx(CHN,nFilter,nrow,ncol,c,0,i,j)]/20.;
            }
        }
    }
    namedWindow("Display Image", WINDOW_AUTOSIZE );
    imshow("Display Image", imageFloat);
    waitKey(0);
*/

    return 0;
}

