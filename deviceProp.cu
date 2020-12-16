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
    cout << property.clockRate << endl;
    cout << property.sharedMemPerBlock << endl;
    cout << property.regsPerBlock << endl;
    cout << "warpSize" << endl;
    cout << property.warpSize << endl;
    cout << "Maximum thread" << endl;
    cout << property.maxThreadsPerMultiProcessor << endl;
    cout << "number of MP" << endl;
    cout << property.multiProcessorCount<< endl;

    return 0;
}
