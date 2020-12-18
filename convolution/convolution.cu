#include <stdio.h>
#include <iostream>
#include <algorithm>
#include <opencv2/opencv.hpp>

#define ROW_F 17
#define COL_F 17

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
    int const nchl = imageFloat.channels();
    printf( " size of the image %d times  %d times  %d\n", nchl, nrow, ncol);

    float *h_img;
    h_img = new float[nchl*nrow*ncol];

    int np = 0;
    for (int c=0; c<nchl; c++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                np = c*(nrow*ncol)+i*ncol+j;
                h_img[np] = imageFloat.at<Vec3f>(i,j)[c]; 
            }
        }
    }

    int nElem;
    int const nFilter=2;
    nElem = nFilter*nchl*ROW_F*COL_F;
    float *h_filter;
    h_filter = new float[nElem];

    for (int n=0; n<nFilter; n++){
        for(int c=0; c<nchl; c++){
            for (int i=0; i<ROW_F; i++){
                for (int j=0; j<COL_F; j++){
                    h_filter[idx(nFilter,nchl,ROW_F,COL_F,n,c,i,j)] = rand()/(RAND_MAX+0.f); 
                }
            } 
        }
    }

    float* d_img;
    nElem = nchl*nrow*ncol;
    cudaMalloc((void**)&d_img, nElem*sizeof(float));

    float* d_filter;
    nElem = nFilter*nchl*ROW_F*COL_F;
    cudaMalloc((void**)&d_filter, nElem*sizeof(float));

    float* d_imgR;
    nElem = nFilter*nchl*nrow*ncol;
    cudaMalloc((void**)&d_imgR, nElem*sizeof(float));

    for (int n=0;n<nchl;n++){
        int stride = n*nrow*ncol;
        cudaMemcpy(h_img+stride, d_img+stride, (nrow*ncol)*sizeof(float), cudaMemcpyHostToDevice);
    }

    float* test;
    nElem = nchl*nrow*ncol;
    test = new float[nElem];
    cudaMemcpy(test, d_img, nElem*sizeof(float), cudaMemcpyDeviceToHost);

    for (int i=0; i<nElem; i++){
        if ( abs(test[i] - h_img[i]) > 0.0001f ) {
            cout << i << ' ' << test[i] << h_img[i] << endl;
            exit(0);
        }
    }


/*

    gridX = colR/32 + 1;
    gridY = rowR/32 + 1;
    dim3 grid1(gridX,gridY);

    nElem = nFilter*nchl*rowR*colR;
    float* imageR;
    imageR = new float[nElem];

    for (int n=0; n<nFilter; n++){
        for(int c=0; c<nchl; c++){
            for (int i=0; i<rowR; i++){
                for (int j=0; j<colR; j++){

                    imageR[idx(nFilter,nchl,rowR,colR,n,c,i,j)] = 0.0;
                    for(int ii=0; ii<rowF; ii++){
                        for(int jj=0; jj<colF; jj++){
                            imageR[idx(nFilter,nchl,rowR,colR,n,c,i,j)] +=
                                h_filter[idx(nFilter,nchl,rowF,colF,n,c,ii,jj)]
                                *h_imgPad[idx(nchl, rowP, colP, c, i+ii, j+jj)];
                        }
                    }

                }
            }
        }
    }


    for (int n=0; n<nFilter; n++){
    for (int c=0; c<nchl; c++){
        for (int i=0; i<rowR; i++){
            for (int j=0; j<colR; j++){
                int np = idx(nFilter, nchl, rowR, colR, n, c, i, j);
                if ( abs(test[np] - imageR[np]) > 0.001 ) {
                    cout << n << ' ' << c << ' ' << i << ' ' << j << ' ' << test[np] << ' ' << imageR[np] << endl;
                    exit(0);
                };
            }
        }
    }
    }

    for (int c=0; c<nchl; c++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                imageFloat.at<Vec3f>(i,j)[c] = imageR[idx(nFilter,nchl,rowR,colR,0,c,i,j)]/250.;
            }
        }
    }
    namedWindow("Display Image", WINDOW_AUTOSIZE );
    imshow("Display Image", imageFloat);
    waitKey(0);

*/
    return 0;
}

