// --------------------------------
// projects/c++/collatz/Collatz.c++
// Copyright (C) 2017
// Juan Trejo
// --------------------------------

// --------
// includes
// --------

#include <cassert>  // assert
#include <iostream> // endl, istream, ostream

#include "Collatz.h"

using namespace std;

// ------------
// collatz_read
// ------------

int collatz_read (istream& r) {
    int n;
    r >> n;
    assert(n > 0);
    return n;}

// ------------
// collatz_eval
// ------------

int collatz_eval (long long n) {
    assert(n > 0);
    int m = 1;
    while(n != 1){
        if(n % 2 == 0){
            n = n / 2;
        }else{
            n = n * 3 + 1;
        }
        m++;
    }
    assert(m > 0);
    return m;}

// -------------
// collatz_print
// -------------

void collatz_print (ostream& w, int m) {
    assert(m > 0);
    w << m << endl;}

// -------------
// collatz_solve
// -------------

void collatz_solve (istream& r, ostream& w) {
    int t;
    r >> t;
    for (int _ = 0; _ != t; ++_) {
        const int n = collatz_read(r);
        const int m = collatz_eval(n);
        collatz_print(w, m);}}
