#include<stdio.h>
#include<iostream>
using namespace std;

int main(){

    int n = 1<<4;
    int* ptr = &n;
    cout << n << endl;
    cout << *ptr << endl;
    cout << ptr << endl;
    cout << &ptr << endl;
    cout << *(&ptr) << endl;

    return 0;
}
