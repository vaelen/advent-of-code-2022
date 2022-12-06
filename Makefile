#ARCH=none-eabi
ARCH=linux-gnueabi
#ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=-nostdlib

DAY1=util.o syscalls.o day1.o

all: init day1

init:
	mkdir -p bin

day1: $(UTIL) $(DAY1)
	$(LD) $(LDFLAGS) $(UTIL) $(DAY1) -o bin/$@

.o:
	$(AS) $(ASFLAGS) $<.s -o $@

clean:
	rm -f *.o bin/*