CC	= vc
CFLAGS   = -O2 -+ -sc -DVBCC -c -I..
LDFLAGS  = -nostdlib -lamiga -lmieee -cpu=68030
LDLIBS	=

OBJS	= obj/exit.o obj/StartUp.o obj/LibInit.o obj/SampleFuncs.o obj/matrix.o

matrix.library: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LDLIBS)

obj/exit.o: exit.c
	$(CC) $(CFLAGS) exit.c -o $@

obj/StartUp.o: StartUp.c
	$(CC) $(CFLAGS) StartUp.c -o $@

obj/LibInit.o: LibInit.c
	$(CC) $(CFLAGS) LibInit.c -o $@

obj/SampleFuncs.o: SampleFuncs.c
	$(CC) $(CFLAGS) SampleFuncs.c -o $@

obj/matrix.o: matrix.c
	$(CC) $(CFLAGS) matrix.c -o $@
