#include "ClassShapelet.h"
#include "Utils.h"

#include <functional>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unordered_map>
#include <vector>

#define min(x, y) ((x) < (y) ? (x) : (y))
#define max(x, y) ((x) > (y) ? (x) : (y))
#define abs(x) ((x) > 0 ? (x) : -(x))

using namespace std;

typedef double (*distfunc)(double *, double *, int, int);

/**************************************/
/*******  Function  Prototype *********/
/**************************************/

void error(int);
double NearestNeighbor(int, int, int);
double NearestNeighborSearch(vector<double> const &, vector<double> const &,
                             int, double *, distfunc, bool, bool);
void ReadData(char *);
