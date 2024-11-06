#include "test.h"

int main() {
  ASSERT(1, ({ char x; sizeof(x); }));
  ASSERT(2, ({ short int x; sizeof(x); }));
  ASSERT(2, ({ int short x; sizeof(x); }));
  ASSERT(4, ({ int x; sizeof(x); }));
  ASSERT(8, ({ long int x; sizeof(x); }));
  ASSERT(8, ({ int long x; sizeof(x); }));

  ASSERT(8, ({ long long x; sizeof(x); }));

  ASSERT(false, ({ bool x=0; x; }));
  ASSERT(true, ({ bool x=1; x; }));
  ASSERT(true, ({ bool x=2; x; }));
  ASSERT(true, (bool)1);
  ASSERT(true, (bool)2);
  ASSERT(false, (bool)(char)256);

  printf("OK\n");
  return 0;
}
