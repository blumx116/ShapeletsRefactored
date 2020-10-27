/********************************/
/* Update at 4/6/2012   (Minor) */
/* Create at 3/12/2012 			*/
/********************************/

#include "FastShapelet.h"

#define INF 1e20 // Pseudo Infitinte number for this code

int m, M; // Length of each time series
double bsf;

typedef struct Index {
  double value;
  int index;
} Index;

int comp(const void *a, const void *b) {
  Index *x = (Index *)a;
  Index *y = (Index *)b;
  return abs((int)(y->value)) - abs((int)(x->value)); // high to low
}

// double distance(double *Q, double *T, int j, int m, double mean, double std,
//                 bool cid) {
//   int i;
//   double sum = 0;
//   for (i = 0; i < m && sum < bsf2; i++) {
//     double x = (T[i + j] - mean) / std;
//     sum += (x - Q[i]) * (x - Q[i]);
//   }
//   return cid ? sqrt(sum) * CIDCorrectionFactor(Q, T, m, j) : sqrt(sum);
// }

double NearestNeighborSearch(vector<double> const &query,
                             vector<double> const &data, int obj_id, double *Q,
                             distfunc dist_func, bool cid, bool norm) {
  double d;
  long long i;
  int j;
  double bsf;
  double cf = 1;
  // long long loc = 0;
  m = query.size();
  M = data.size();

  bsf = INF;
  i = 0;
  j = 0;
  // ex = ex2 = 0;

  if (obj_id == 0) {
    for (i = 0; i < m; i++) {
      d = query[i];
      // ex += d;
      // ex2 += d * d;
      Q[i] = d;
    }
    if (norm)
      normalize(Q, m, 0, Q);

    // mean = ex / m;
    // std = ex2 / m;
    // std = sqrt(std - mean * mean);

    // for (i = 0; i < m; i++)
    //   Q[i] = (Q[i] - mean) / std;

    // Index *Q_tmp = (Index *)malloc(sizeof(Index)*m);
    // if( Q_tmp == NULL )
    //     error(3);
    // for( i = 0 ; i < m ; i++ )
    // {
    //     Q_tmp[i].value = Q[i];
    //     Q_tmp[i].index = i;
    // }
    // qsort(Q_tmp, m, sizeof(Index),comp);
    // for( i=0; i<m; i++)
    // {   Q[i] = Q_tmp[i].value;
    //     order[i] = Q_tmp[i].index;
    // }
    // free(Q_tmp);
  }

  i = 0;
  j = 0;
  // ex = ex2 = 0;

  double *T = (double *)malloc(sizeof(double) * 2 * m);
  if (T == NULL)
    error(3);
  double *T_tmp = (double *)malloc(sizeof(double) * m);

  double dist = 0;
  while (i < M) {
    d = data[i];
    // ex += d;
    // ex2 += d * d;
    T[i % m] = d;
    T[(i % m) + m] = d;

    if (i >= m - 1) {
      // mean = ex / m;
      // std = ex2 / m;
      // std = sqrt(std - mean * mean);

      j = (i + 1) % m;
      // dist = distance(Q,order,T,j,m,mean,std,bsf);
      if (norm) {
        normalize(T, m, j, T_tmp);

        dist = dist_func(Q, T_tmp, m, 0);
        cf = cid ? CIDCorrectionFactor(Q, T_tmp, m, 0) : cf;
      } else {
        dist = dist_func(Q, T, m, j);
        cf = cid ? CIDCorrectionFactor(Q, T, m, j) : cf;
      }
      dist *= cf;

      if (dist < bsf) {
        bsf = dist;
        // loc = i - m + 1;
      }
      //   ex -= T[j];
      //   ex2 -= T[j] * T[j];
    }
    i++;
  }
  free(T);
  free(T_tmp);
  return bsf;
}
