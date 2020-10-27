#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TINY 1.0e-20
//using namespace std;

typedef double (*distfunc)(double *, double *, int, int);

void normalize(double *, int, int, double *);
double correlation_distance(double *, double *, int, int);
double euclidean_distance(double *, double *, int, int);
double manhattan_distance(double *, double * , int, int);

double mean(double *, int, int);
double var(double *, int, int);
double stddev(double *, int, int);
double *Diff(double *, int, int);

double ComplexityEstimate(double *, int, int);
double CIDCorrectionFactor(double *, double *, int, int);
distfunc get_distance_function(char *dist_name);
