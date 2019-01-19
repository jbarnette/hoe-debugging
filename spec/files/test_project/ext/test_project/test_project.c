#include <ruby.h>

static VALUE bad_method()
{
  int *foo = malloc(sizeof(int));
  *foo = 0 ;
  
  for (long int offset = 8 ; offset <= 65536 ; offset = offset * 2 ) {
    printf("Hoedebuggingtest: running: offset %ld, value %d\n", offset, *(foo + offset));
    printf("Hoedebuggingtest: running: offset %ld, value %d\n", -offset, *(foo - offset));
  }
  return Qnil;
}


void Init_test_project()
{
  VALUE mHoedebuggingtest = rb_define_module("Hoedebuggingtest");

  rb_define_singleton_method(mHoedebuggingtest, "bad_method", bad_method, 0);
}
