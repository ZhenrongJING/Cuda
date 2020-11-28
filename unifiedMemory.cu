#include<stdio.h>

struct dataElem {
    int val;
    char* name;
};

__global__ void kernal(dataElem* e){
    printf("From the device %s\n", e->name);
};

int main() {

    dataElem* e;
    cudaMallocManaged((void**)&e, sizeof(dataElem) );
    e->val = 10;

    cudaMallocManaged((void**)&(e->name), sizeof(char)*(strlen("hello")+1), 0);
    strcpy(e->name, "hello");

    kernal<<<1,1>>>(e);

    printf("From the host %s\n", e->name);
    return 0;
}
