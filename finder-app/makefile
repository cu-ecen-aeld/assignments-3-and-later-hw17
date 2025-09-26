# Simply expanded variables
# ARCH:=$(shell arch)
# CWD:=$(shell pwd)
# OS:=$(shell uname)
# Recursively Expanded Variables
ifndef CROSS_COMPILE
override CROSS_COMPILE=
endif
CFLAGS = -g -Wall

all: clean writer
writer:
	$(CROSS_COMPILE)gcc $(CFLAGS) -o writer writer.c

clean:
	rm -f writer
