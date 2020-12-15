#include <stdio.h>
#include <iostream>
#include <algorithm>
#include <opencv2/opencv.hpp>

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

    float* d_img;
    int nElem;
    nElem = nchl*nrow*ncol;
    cudaMalloc((void**)&d_img, nElem*sizeof(float));
    cudaMemcpy(d_img, h_img, nElem*sizeof(float), cudaMemcpyHostToDevice);

    int const npad = 16;
    int const rowP= nrow+2*npad; 
    int const colP= ncol+2*npad; 

    float* h_imgPad;
    nElem = nchl*rowP*colP;
    h_imgPad = new float[nElem];
    for (int i=0; i<nElem; i++)
        h_imgPad[i] = 0.f;

    for (int c=0; c<nchl; c++){
        for (int i=0; i<nrow; i++){
            for (int j=0; j<ncol; j++){
                h_imgPad[idx(nchl, rowP, colP, c, i+npad, j+npad)]= h_img[c*(nrow*ncol)+i*ncol+j]; 
            }
        }
    }

    float* d_imgPad;
    nElem = nchl*rowP*colP;
    cudaMalloc((void**)&d_imgPad, nElem*sizeof(float));
    int blockX=32;
    int blockY=32;
    dim3 block(blockX, blockY);
    int gridX = colP/32 + 1;
    int gridY = rowP/32 + 1;
    dim3 grid(gridX, gridY);
    padding<<<block,grid>>>(nchl, nrow, ncol, npad, d_img, d_imgPad);

    float* test;
    nElem = nchl*rowP*colP;
    test = new float[nElem];
    cudaMemcpy(test, d_imgPad, nElem*sizeof(float), cudaMemcpyDeviceToHost);

    for (int i=0; i<nElem; i++)
        if ( abs( test[i] - h_imgPad[i]) > 0.0001 ) {
            cout << i << " wrong" << endl;
            break;
        };

/*

    int const colF=2*npad, rowF=2*npad, nFilter=2;
    nElem = nFilter*nchl*rowF*colF;
    float *h_filter;
    h_filter = new float[nElem];
    for (int i=0; i<nElem; i++)
        h_filter[i] = 0.f;

    for (int n=0; n<nFilter; n++){
        for(int c=0; c<nchl; c++){
            for (int i=0; i<rowF; i++){
                for (int j=0; j<colF; j++){
                    h_filter[idx(nFilter,nchl,rowF,colF,n,c,i,j)] = rand()/(RAND_MAX+0.f); 
                }
            } 
        }
    }

    int const rowR= nrow+2*npad-rowF; 
    int const colR= ncol+2*npad-colF; 
    nElem = nFilter*nchl*rowR*colR;
    float* imageR;
    imageR = new float[nElem];



    float* d_filter;
    nElem = nFilter*nchl*rowF*colF;
    cudaMalloc((void**)&d_filter, nElem*sizeof(float));
    cudaMemcpy(d_filter, h_filter, nElem*sizeof(float), cudaMemcpyHostToDevice);

    float* d_imgR;
    nElem = nFilter*nchl*rowR*colR;
    cudaMalloc((void**)&d_imgR, nElem*sizeof(float));

    gridX = colR/32 + 1;
    gridY = rowR/32 + 1;
    dim3 grid1(gridX,gridY);

    convl<<<block, grid1>>>(nFilter, nchl, rowP, colP, rowF, colF, d_imgPad, d_imgR, d_filter);

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

