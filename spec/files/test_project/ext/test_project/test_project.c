#include <ruby.h>

static VALUE bad_method()
{
  int *foo = malloc(sizeof(int));
  *foo = 0 ;
  
  printf("Hoedebuggingtest: running %d\n", *(foo + 512));
  printf("Hoedebuggingtest: running %d\n", *(foo + 1024));
  printf("Hoedebuggingtest: running %d\n", *(foo + 2048));
  return Qnil;
}


void Init_test_project()
{
  VALUE mHoedebuggingtest = rb_define_module("Hoedebuggingtest");

  rb_define_singleton_method(mHoedebuggingtest, "bad_method", bad_method, 0);
}
