#ARCH=none-eabi
ARCH=linux-gnueabi
#ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=-nostdlib

DAY1_1=util.o syscalls.o day1_1.o
DAY1_2=util.o syscalls.o day1_2.o

all: init day1_1 day1_2

init:
	mkdir -p bin

day1_1: $(DAY1_1)
	$(LD) $(LDFLAGS) $(UTIL) $(DAY1_1) -o bin/$@

day1_2: $(DAY1_2)
	$(LD) $(LDFLAGS) $(UTIL) $(DAY1_2) -o bin/$@

.o:
	$(AS) $(ASFLAGS) $<.s -o $@

clean:
	rm -f *.o bin/*
