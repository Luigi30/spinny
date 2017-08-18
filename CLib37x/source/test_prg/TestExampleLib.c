/*
**      $VER: TextExampleLib.c 37.30 (7.3.98)
**
**      Demo program for example.library
**
**      (C) Copyright 1996-98 Andreas R. Kleinert
**      All Rights Reserved.
*/

#include <exec/types.h>
#include <exec/memory.h>

#include <example/example.h>

#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <pragma/example_lib.h>
#else
#include <proto/exec.h>
#include <proto/example.h>
#endif

#include <stdio.h>
#include <stdlib.h>

struct ExampleBase *ExampleBase = NULL;

void main(long argc, char **argv)
{
 ExampleBase = (APTR) OpenLibrary("example.library", 37);
 if(ExampleBase)
  {
   EXF_TestRequest("Test Message", "It works!", "OK");

   CloseLibrary((APTR) ExampleBase);

   exit(0);
  }

 printf("\nLibrary opening failed\n");

 exit(20);
}
