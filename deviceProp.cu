#include<stdio.h>
#include<iostream>
using namespace std;


int main(int argc, char* argv[]){

    cudaDeviceProp property;

    cudaGetDeviceProperties(&property, 0);

    cout << property.name << endl;
    cout << property.major << endl;
    cout << property.minor << endl;
    cout << property.totalGlobalMem << endl;

    return 0;
}
