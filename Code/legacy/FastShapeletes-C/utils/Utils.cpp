#include "Utils.h"
#define min(x, y) ((x) < (y) ? (x) : (y))
#define max(x, y) ((x) > (y) ? (x) : (y))
#define abs(x) ((x) > 0 ? (x) : -(x))

double mean(double *A, int m, int j) {
  int i;
  double s = 0;
  for (i = 0; i < m; i++)
    s += A[i + j];
  return s / m;
}

double var(double *A, int m, int j) {
  int i;
  double d, mu;
  double s = 0;
  mu = mean(A, m, j);
  for (i = 0; i < m; i++) {
    d = mu - A[i + j];
    s += d * d;
  }
  return s / m;
}

double stddev(double *A, int m, int j) { return sqrt(var(A, m, j)); }

void normalize(double *A, int m, int j, double *out) {
  int i;
  double mu = mean(A, m, j);
  double sd = stddev(A, m, j);
  if (sd <= TINY) {
    for (i = 0; i < m; i++)
      out[i] = 0;
  } else {
    for (i = 0; i < m; i++)
      out[i] = (A[i + j] - mu) / sd;
  }
  return;
}

double correlation_distance(double *Q, double *T, int m, int j) {
  int i;
  double r = 0;
  double sd = stddev(Q, m, 0) * stddev(T, m, j);
  double mu_q = mean(Q, m, 0);
  double mu_t = mean(T, m, j);
  if (sd <= TINY) {
    r = 0;
  } else {
    for (i = 0; i < m; i++)
      r += (Q[i] - mu_q) * (T[(i + j)] - mu_t);
    r /= (m * sd + TINY);
  }
  return 1 - r;
}

double euclidean_distance(double *Q, double *T, int m, int j) {
  int i;
  double s = 0, x;
  for (i = 0; i < m; i++) {
    x = (T[i + j] - Q[i]);
    s += x * x;
  }
  return sqrt(s);
}

double manhattan_distance(double *Q, double *T, int m, int j) {
  double d = 0;
  for (int i = 0; i < m; i++)
    d += abs(Q[i] - T[i + j]);
  return d;
}

double *Diff(double *A, int m, int j) {
  double *diff = (double *)malloc(sizeof(double) * (m - 1));
  int i;
  for (i = 0; i < (m - 1); i++)
    diff[i] = A[i + j] - A[i + j + 1];
  return diff;
}

double ComplexityEstimate(double *A, int m, int j) {
  double *diff;
  double ce = 0;
  int i;
  diff = Diff(A, m, j);
  for (i = 0; i < (m - 1); i++)
    ce += diff[i] * diff[i];
  free(diff);
  return sqrt(ce);
}

double CIDCorrectionFactor(double *Q, double *T, int m, int j) {
  double cf, ce_t, ce_q;
  ce_t = ComplexityEstimate(T, m, j);
  ce_q = ComplexityEstimate(Q, m, 0);
  if ((ce_q <= TINY) || (ce_t <= TINY))
    return 1;
  return max(ce_q, ce_t) / min(ce_q, ce_t);
}

distfunc get_distance_function(char *dist_name) {
  if (strcmp(dist_name, "correlation") == 0) {
    // printf("correlation distance chosen\n");
    return correlation_distance;
  }else if (strcmp(dist_name, "manhattan") == 0){
    // printf("manhattan distance chosen\n");
    return manhattan_distance;
  } else {
    // printf("euclidean distance chosen");
    return euclidean_distance;
  }
}
