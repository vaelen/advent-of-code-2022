#ARCH=none-eabi
ARCH=linux-gnueabi
#ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=-nostdlib

DAY1_1=util.o syscalls.o day1_1.o
DAY1_2=util.o syscalls.o day1_2.o
DAY2_1=util.o syscalls.o day2_1.o
DAY2_2=util.o syscalls.o day2_2.o

all: init day1_1 day1_2 day2_1 day2_2

init:
	mkdir -p bin

day1_1: $(DAY1_1)
	$(LD) $(LDFLAGS) $(DAY1_1) -o bin/$@

day1_2: $(DAY1_2)
	$(LD) $(LDFLAGS) $(DAY1_2) -o bin/$@

day2_1: $(DAY2_1)
	$(LD) $(LDFLAGS) $(DAY2_1) -o bin/$@

day2_2: $(DAY2_2)
	$(LD) $(LDFLAGS) $(DAY2_2) -o bin/$@

.o:
	$(AS) $(ASFLAGS) $<.s -o $@

clean:
	rm -f *.o bin/*
