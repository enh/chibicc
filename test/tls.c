#include "test.h"
#include <stdio.h>
#include <pthread.h>

__thread int v0;
_Thread_local int v1;
thread_local int v2 = 5;
int non_thread_local = 7;

int thread_main(void *unused) {
  ASSERT(0, v0);
  ASSERT(0, v1);
  ASSERT(5, v2);
  ASSERT(7, non_thread_local);

  v0 = 1;
  v1 = 1;
  v2 = 2;
  non_thread_local = 3;

  ASSERT(1, v0);
  ASSERT(1, v1);
  ASSERT(2, v2);
  ASSERT(3, non_thread_local);

  return 0;
}

int main() {
  pthread_t thr;

  ASSERT(0, v0);
  ASSERT(0, v1);
  ASSERT(5, v2);
  ASSERT(7, non_thread_local);

  ASSERT(0, pthread_create(&thr, NULL, thread_main, NULL));
  ASSERT(0, pthread_join(thr, NULL));

  ASSERT(0, v0);
  ASSERT(0, v1);
  ASSERT(5, v2);
  ASSERT(3, non_thread_local);

  printf("OK\n");
  return 0;
}
