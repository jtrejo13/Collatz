// ------------------------------
// projects/c++/collatz/Collatz.h
// Copyright (C) 2017
// Glenn P. Downing
// ------------------------------

#ifndef Collatz_h
#define Collatz_h

// --------
// includes
// --------

#include <iostream> // istream, ostream
#include <string>   // string
#include <utility>  // pair

using namespace std;

// ------------
// collatz_read
// ------------

/**
 * read an int from r
 * @param r an istream
 * @return the int
 */
int collatz_read (istream& r);

// ------------
// collatz_eval
// ------------

/**
 * @param n the end of the range [1, n], inclusive
 * @return the value that produces the max cycle length of the range [1, n]
 */
int collatz_eval (long long n);

// -------------
// collatz_print
// -------------

/**
 * print an int to w
 * @param w an ostream
 * @param m the max cycle length
 */
void collatz_print (ostream& w, int m);

// -------------
// collatz_solve
// -------------

/**
 * @param r an istream
 * @param w an ostream
 */
void collatz_solve (istream& r, ostream& w);

#endif // Collatz_h